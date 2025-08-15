package com.zeriuxlabs.proact

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.*
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.core.content.ContextCompat
import org.json.JSONArray
import java.util.*

@SuppressLint("InflateParams")
class RobustBlockWindow(private val context: Context) {
    
    companion object {
        private const val TAG = "RobustBlockWindow"
    }
    
    private var windowManager: WindowManager? = null
    private var blockView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null
    private var isWindowVisible = false
    private var saveAppData: SharedPreferences? = null
    
    // UI elements
    private var passwordInput: EditText? = null
    private var unlockButton: Button? = null
    private var errorText: TextView? = null
    private var messageText: TextView? = null
    
    // Security measures
    private var lastShowTime = 0L
    private var failedAttempts = 0
    private val maxFailedAttempts = 3
    private var lockoutEndTime = 0L
    
    init {
        initializeWindow()
    }
    
    private fun initializeWindow() {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        saveAppData = context.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        
        createBlockView()
        setupLayoutParams()
    }
    
    private fun createBlockView() {
        val layoutInflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        blockView = layoutInflater.inflate(R.layout.robust_block_layout, null)
        
        // Initialize UI elements
        passwordInput = blockView?.findViewById(R.id.password_input)
        unlockButton = blockView?.findViewById(R.id.unlock_button)
        errorText = blockView?.findViewById(R.id.error_text)
        messageText = blockView?.findViewById(R.id.message_text)
        
        setupUIListeners()
        updateMessageText()
    }
    
    private fun setupLayoutParams() {
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        } else {
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        }
        
        val windowType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        
        layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            windowType,
            flags,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }
    }
    
    private fun setupUIListeners() {
        unlockButton?.setOnClickListener {
            handleUnlockAttempt()
        }
        
        passwordInput?.setOnEditorActionListener { _, _, _ ->
            handleUnlockAttempt()
            true
        }
        
        // Prevent back button from closing
        blockView?.setOnKeyListener { _, keyCode, event ->
            if (keyCode == KeyEvent.KEYCODE_BACK && event.action == KeyEvent.ACTION_UP) {
                Log.d(TAG, "Back button pressed - ignoring")
                true // Consume the event
            } else {
                false
            }
        }
        
        // Make the view focusable to capture key events
        blockView?.isFocusableInTouchMode = true
        blockView?.requestFocus()
    }
    
    private fun handleUnlockAttempt() {
        val currentTime = System.currentTimeMillis()
        
        // Check if in lockout period
        if (currentTime < lockoutEndTime) {
            val remainingSeconds = (lockoutEndTime - currentTime) / 1000
            showError("Too many failed attempts. Try again in ${remainingSeconds}s")
            return
        }
        
        val enteredPassword = passwordInput?.text?.toString() ?: ""
        val correctPassword = saveAppData?.getString("password", "") ?: ""
        
        if (enteredPassword == correctPassword && correctPassword.isNotEmpty()) {
            Log.d(TAG, "Correct password entered")
            failedAttempts = 0
            hide()
        } else {
            failedAttempts++
            Log.d(TAG, "Incorrect password attempt $failedAttempts")
            
            if (failedAttempts >= maxFailedAttempts) {
                lockoutEndTime = currentTime + (30 * 1000) // 30 second lockout
                showError("Too many failed attempts. Locked for 30 seconds.")
            } else {
                showError("Incorrect password. ${maxFailedAttempts - failedAttempts} attempts remaining.")
            }
            
            passwordInput?.text?.clear()
        }
    }
    
    private fun showError(message: String) {
        errorText?.text = message
        errorText?.visibility = View.VISIBLE
        
        // Hide error after 3 seconds
        Handler(Looper.getMainLooper()).postDelayed({
            errorText?.visibility = View.GONE
        }, 3000)
    }
    
    private fun updateMessageText() {
        val message = getCurrentTaskMessage()
        messageText?.text = message
    }
    
    private fun getCurrentTaskMessage(): String {
        try {
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
                        val taskName = event.optString("name", "Focus Time")
                        val endTimeFormatted = event.getString("endTime")
                        return "🎯 $taskName\n\nStay focused! This task ends at $endTimeFormatted\n\nEnter your password to unlock:"
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting task message", e)
        }
        
        return "🎯 Focus Time\n\nStay focused on your current task!\n\nEnter your password to unlock:"
    }
    
    fun show() {
        if (isWindowVisible) return
        
        try {
            val currentTime = System.currentTimeMillis()
            
            // Prevent rapid show/hide cycles
            if (currentTime - lastShowTime < 500) {
                return
            }
            
            lastShowTime = currentTime
            
            blockView?.let { view ->
                if (view.windowToken == null && view.parent == null) {
                    windowManager?.addView(view, layoutParams)
                    isWindowVisible = true
                    
                    // Update message and clear previous input
                    updateMessageText()
                    passwordInput?.text?.clear()
                    errorText?.visibility = View.GONE
                    
                    // Request focus to capture key events
                    view.requestFocus()
                    
                    Log.d(TAG, "Block window shown")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error showing block window", e)
            isWindowVisible = false
        }
    }
    
    fun hide() {
        if (!isWindowVisible) return
        
        try {
            blockView?.let { view ->
                if (view.windowToken != null && view.parent != null) {
                    windowManager?.removeView(view)
                    isWindowVisible = false
                    Log.d(TAG, "Block window hidden")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error hiding block window", e)
        }
    }
    
    fun isVisible(): Boolean = isWindowVisible
    
    // Force show with additional security measures
    fun forceShow() {
        hide() // First hide if already visible
        
        Handler(Looper.getMainLooper()).postDelayed({
            show()
        }, 100)
    }
    
    // Handle system UI changes that might affect the window
    fun onSystemUiVisibilityChange() {
        if (isWindowVisible) {
            // Re-apply security flags
            blockView?.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            )
        }
    }
}