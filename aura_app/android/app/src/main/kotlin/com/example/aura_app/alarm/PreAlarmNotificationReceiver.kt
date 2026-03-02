package com.example.aura_app.alarm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class PreAlarmNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val label = intent.getStringExtra(AlarmReceiver.EXTRA_LABEL) ?: "Alarm"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel =
                    NotificationChannel(
                                    "alarm_pre_notify",
                                    "Alarm Reminders",
                                    NotificationManager.IMPORTANCE_HIGH
                            )
                            .apply { description = "Notifications shown before alarm rings" }
            val manager = context.getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        val openIntent =
                Intent(context, Class.forName("com.example.aura_app.MainActivity")).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
        val pendingIntent =
                PendingIntent.getActivity(context, 0, openIntent, PendingIntent.FLAG_IMMUTABLE)

        val notification =
                NotificationCompat.Builder(context, "alarm_pre_notify")
                        .setContentTitle("⏰ Alarm in 5 minutes")
                        .setContentText(label.ifEmpty { "Get ready!" })
                        .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setAutoCancel(true)
                        .setContentIntent(pendingIntent)
                        .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                        .build()

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(2001, notification)
    }
}
