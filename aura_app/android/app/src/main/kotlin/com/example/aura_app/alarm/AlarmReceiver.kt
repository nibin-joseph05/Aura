package com.example.aura_app.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra(EXTRA_ALARM_ID) ?: return
        val label = intent.getStringExtra(EXTRA_LABEL) ?: ""
        val tone = intent.getStringExtra(EXTRA_TONE) ?: "default"
        val vibrate = intent.getBooleanExtra(EXTRA_VIBRATE, true)
        val dismissType = intent.getStringExtra(EXTRA_DISMISS_TYPE) ?: "button"
        val mathDifficulty = intent.getIntExtra(EXTRA_MATH_DIFFICULTY, 1)

        val serviceIntent = Intent(context, AlarmService::class.java).apply {
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(EXTRA_LABEL, label)
            putExtra(EXTRA_TONE, tone)
            putExtra(EXTRA_VIBRATE, vibrate)
            putExtra(EXTRA_DISMISS_TYPE, dismissType)
            putExtra(EXTRA_MATH_DIFFICULTY, mathDifficulty)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }

    companion object {
        const val EXTRA_ALARM_ID = "alarm_id"
        const val EXTRA_LABEL = "label"
        const val EXTRA_TONE = "tone"
        const val EXTRA_VIBRATE = "vibrate"
        const val EXTRA_DISMISS_TYPE = "dismiss_type"
        const val EXTRA_MATH_DIFFICULTY = "math_difficulty"
    }
}
