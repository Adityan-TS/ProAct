package com.zeriuxlabs.proact

import android.app.*
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.*
import android.os.*
import android.util.Log
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class RobustAppBlockService : Service() {
    
    companion object {
        private const val TAG = "RobustAppBlockService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "app_block_service"
        private const val CHECK_INTERVAL_MS = 100L // Very frequent checking
        private const val USAGE_STATS_INTERVAL_MS = 200L
    }
    
    private var executor: ScheduledExecutorService? = null
    private var usageStatsManager: UsageStatsManager? = null
    private var windowManager: WindowManager? = null
    private var blockWindow: RobustBlockWindow? = null
    private var saveAppData: SharedPreferences? = null
    private var homeWatcher: HomeWatcher? = null
    
    // Track blocked apps and current state
    private val blockedPackages = mutableSetOf<String>()
    private val activeBlockedApps = mutableSetOf<String>()
    private var isBlockingActive = false
    private var lastUsageCheckTime = 0L
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "RobustAppBlockService created")
        
        initializeService()
        createNotificationChannel()
        startForegroundService()
        setupHomeWatcher()
        startContinuousMonitoring()
    }
    
    private fun initializeService() {
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        saveAppData = getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        blockWindow = RobustBlockWindow(this)
        executor = Executors.newScheduledThreadPool(3)
        lastUsageCheckTime = System.currentTimeMillis()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "App Block Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors and blocks distracting apps during focus time"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ProAct+ Focus Mode")
            .setContentText("Protecting your focus time")
            .setSmallIcon(R.drawable.ic_launcher)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
            
        startForeground(NOTIFICATION_ID, notification)
    }
    
    private fun setupHomeWatcher() {
        homeWatcher = HomeWatcher(this).apply {
            setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
                override fun onHomePressed() {
                    handleHomePressed()
                }
                
                override fun onHomeLongPressed() {
                    handleHomePressed()
                }
            })
            startWatch()
        }
    }
    
    private fun handleHomePressed() {
        Log.d(TAG, "Home button pressed - clearing active blocked apps")
        activeBlockedApps.clear()
        blockWindow?.hide()
    }
    
    private fun startContinuousMonitoring() {
        // High-frequency app usage monitoring
        executor?.scheduleAtFixedRate({
            try {
                checkAppUsageAndBlock()
            } catch (e: Exception) {
                Log.e(TAG, "Error in app usage monitoring", e)
            }
        }, 0, CHECK_INTERVAL_MS, TimeUnit.MILLISECONDS)
        
        // Update blocked apps list periodically
        executor?.scheduleAtFixedRate({
            try {
                updateBlockedAppsList()
            } catch (e: Exception) {
                Log.e(TAG, "Error updating blocked apps list", e)
            }
        }, 0, 5, TimeUnit.SECONDS)
        
        // Verify blocking status periodically
        executor?.scheduleAtFixedRate({
            try {
                verifyBlockingIntegrity()
            } catch (e: Exception) {
                Log.e(TAG, "Error verifying blocking integrity", e)
            }
        }, 1, 1, TimeUnit.SECONDS)
    }
    
    private fun checkAppUsageAndBlock() {
        if (!isTaskTimeActive()) {
            if (isBlockingActive) {
                Log.d(TAG, "Task time ended - disabling blocking")
                isBlockingActive = false
                activeBlockedApps.clear()
                blockWindow?.hide()
            }
            return
        }
        
        isBlockingActive = true
        val currentTime = System.currentTimeMillis()
        
        // Query recent usage events
        val usageEvents = usageStatsManager?.queryEvents(
            lastUsageCheckTime - USAGE_STATS_INTERVAL_MS,
            currentTime
        ) ?: return
        
        val event = UsageEvents.Event()
        val newlyBlockedApps = mutableSetOf<String>()
        
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                val packageName = event.packageName
                
                if (blockedPackages.contains(packageName)) {
                    Log.d(TAG, "Blocked app detected: $packageName")
                    newlyBlockedApps.add(packageName)
                    activeBlockedApps.add(packageName)
                }
            } else if (event.eventType == UsageEvents.Event.ACTIVITY_STOPPED) {
                activeBlockedApps.remove(event.packageName)
            }
        }
        
        // Show block window for any newly detected blocked apps
        if (newlyBlockedApps.isNotEmpty()) {
            blockWindow?.show()
        }
        
        // Hide block window if no blocked apps are active
        if (activeBlockedApps.isEmpty()) {
            blockWindow?.hide()
        }
        
        lastUsageCheckTime = currentTime
    }
    
    private fun updateBlockedAppsList() {
        val appListString = saveAppData?.getString("app_data", "") ?: ""
        val newBlockedPackages = appListString
            .replace("[", "")
            .replace("]", "")
            .split(",")
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .toSet()
            
        if (newBlockedPackages != blockedPackages) {
            blockedPackages.clear()
            blockedPackages.addAll(newBlockedPackages)
            Log.d(TAG, "Updated blocked packages: $blockedPackages")
        }
    }
    
    private fun verifyBlockingIntegrity() {
        if (!isBlockingActive || activeBlockedApps.isEmpty()) return
        
        // Double-check that blocking window is still visible
        if (blockWindow?.isVisible() != true) {
            Log.w(TAG, "Block window lost - reshowing")
            blockWindow?.show()
        }
        
        // Re-check current foreground app
        val currentTime = System.currentTimeMillis()
        val recentEvents = usageStatsManager?.queryEvents(
            currentTime - 1000, // Last 1 second
            currentTime
        )
        
        recentEvents?.let { events ->
            val event = UsageEvents.Event()
            var latestResumedApp: String? = null
            var latestEventTime = 0L
            
            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED && 
                    event.timeStamp > latestEventTime) {
                    latestResumedApp = event.packageName
                    latestEventTime = event.timeStamp
                }
            }
            
            latestResumedApp?.let { packageName ->
                if (blockedPackages.contains(packageName) && !activeBlockedApps.contains(packageName)) {
                    Log.w(TAG, "Missed blocked app: $packageName - adding to active list")
                    activeBlockedApps.add(packageName)
                    blockWindow?.show()
                }
            }
        }
    }
    
    private fun isTaskTimeActive(): Boolean {
        val eventDataStr = saveAppData?.getString("event_data", "[]") ?: "[]"
        val eventDataArr = JSONArray(eventDataStr)
        
        val calendar = Calendar.getInstance()
        val currentDay = calendar.get(Calendar.DAY_OF_MONTH)
        val currentMonth = calendar.get(Calendar.MONTH)
        val currentYear = calendar.get(Calendar.YEAR)
        val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
        val currentMinute = calendar.get(Calendar.MINUTE)
        val currentTimeInt = (currentHour * 100) + currentMinute
        
        for (i in 0 until eventDataArr.length()) {
            try {
                val event = eventDataArr.getJSONObject(i)
                val eventTimeMillis = event.getString("currenttimeinmillis").toLong()
                
                calendar.timeInMillis = eventTimeMillis
                val eventDay = calendar.get(Calendar.DAY_OF_MONTH)
                val eventMonth = calendar.get(Calendar.MONTH)
                val eventYear = calendar.get(Calendar.YEAR)
                
                if (currentDay == eventDay && currentMonth == eventMonth && currentYear == eventYear) {
                    val startTime = event.getString("startTime").replace(":", "").toInt()
                    val endTime = event.getString("endTime").replace(":", "").toInt()
                    
                    if (currentTimeInt in startTime until endTime) {
                        return true
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error parsing event data", e)
            }
        }
        
        return false
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service start command received")
        return START_STICKY // Restart if killed
    }
    
    override fun onDestroy() {
        Log.d(TAG, "Service being destroyed")
        executor?.shutdown()
        homeWatcher?.stopWatch()
        blockWindow?.hide()
        super.onDestroy()
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    // Handle service restart after being killed
    override fun onTaskRemoved(rootIntent: Intent?) {
        Log.d(TAG, "Task removed - scheduling restart")
        val restartIntent = Intent(applicationContext, RobustAppBlockService::class.java)
        val pendingIntent = PendingIntent.getService(
            applicationContext, 1, restartIntent,
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.set(
            AlarmManager.ELAPSED_REALTIME,
            SystemClock.elapsedRealtime() + 1000,
            pendingIntent
        )
        
        super.onTaskRemoved(rootIntent)
    }
}