package com.example.flutter_tv

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            launchIntent?.let {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(it)
            }
        }
    }
}
