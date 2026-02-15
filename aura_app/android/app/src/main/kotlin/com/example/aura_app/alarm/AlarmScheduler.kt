package com.example.aura_app.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM
import android.util.Log

class AlarmScheduler(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    fun schedule(
        alarmId: String,
        triggerTimeMillis: Long,
        label: String,
        tone: String,
        vibrate: Boolean,
        dismissType: String,
        mathDifficulty: Int
    ): Boolean {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmReceiver.EXTRA_LABEL, label)
            putExtra(AlarmReceiver.EXTRA_TONE, tone)
            putExtra(AlarmReceiver.EXTRA_VIBRATE, vibrate)
            putExtra(AlarmReceiver.EXTRA_DISMISS_TYPE, dismissType)
            putExtra(AlarmReceiver.EXTRA_MATH_DIFFICULTY, mathDifficulty)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setAlarmClock(
                        AlarmManager.AlarmClockInfo(triggerTimeMillis, pendingIntent),
                        pendingIntent
                    )
                    Log.i("AlarmScheduler", "Scheduled alarm: $alarmId at $triggerTimeMillis")
                    true
                } else {
                    Log.w("AlarmScheduler", "Cannot schedule exact alarms")
                    false
                }
            } else {
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(triggerTimeMillis, pendingIntent),
                    pendingIntent
                )
                Log.i("AlarmScheduler", "Scheduled alarm: $alarmId at $triggerTimeMillis")
                true
            }
        } catch (e: Exception) {
            Log.e("AlarmScheduler", "Failed to schedule alarm: ${e.message}")
            false
        }
    }

    fun cancel(alarmId: String): Boolean {
        val intent = Intent(context, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )

        return if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
            Log.i("AlarmScheduler", "Cancelled alarm: $alarmId")
            true
        } else {
            false
        }
    }

    fun cancelAll(): Boolean {
        return true
    }

    fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }

    fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        }
    }
}
