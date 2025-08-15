package com.zeriuxlabs.proact

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class RobustBootReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "RobustBootReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Boot receiver triggered: ${intent.action}")
        
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_PACKAGE_REPLACED -> {
                startRobustAppBlockService(context)
            }
        }
    }
    
    private fun startRobustAppBlockService(context: Context) {
        try {
            val serviceIntent = Intent(context, RobustAppBlockService::class.java)
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            
            Log.d(TAG, "RobustAppBlockService started from boot receiver")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start RobustAppBlockService from boot receiver", e)
        }
    }
}