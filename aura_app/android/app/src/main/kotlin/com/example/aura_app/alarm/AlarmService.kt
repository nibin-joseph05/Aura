package com.example.aura_app.alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        acquireWakeLock()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarmId =
                intent?.getStringExtra(AlarmReceiver.EXTRA_ALARM_ID) ?: return START_NOT_STICKY
        val label = intent.getStringExtra(AlarmReceiver.EXTRA_LABEL) ?: "Alarm"
        val tone = intent.getStringExtra(AlarmReceiver.EXTRA_TONE) ?: "default"
        val vibrate = intent.getBooleanExtra(AlarmReceiver.EXTRA_VIBRATE, true)
        val dismissType = intent.getStringExtra(AlarmReceiver.EXTRA_DISMISS_TYPE) ?: "button"
        val mathDifficulty = intent.getIntExtra(AlarmReceiver.EXTRA_MATH_DIFFICULTY, 1)
        val snoozeMinutes = intent.getIntExtra(AlarmReceiver.EXTRA_SNOOZE_MINUTES, 5)
        val isPreview = intent.getBooleanExtra(EXTRA_IS_PREVIEW, false)

        Log.i("AlarmService", "Alarm triggered: $alarmId isPreview=$isPreview")
        instance = this

        if (isPreview) {
            startForeground(PREVIEW_NOTIFICATION_ID, createPreviewNotification())
            forceMaxVolume()
            playAlarmSound(tone)
        } else {
            forceMaxVolume()
            startForeground(NOTIFICATION_ID, createNotification(label, alarmId))
            playAlarmSound(tone)
            if (vibrate) startVibration()
            launchRingActivity(alarmId, label, dismissType, mathDifficulty, snoozeMinutes)
        }

        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel =
                    NotificationChannel(CHANNEL_ID, "Alarm", NotificationManager.IMPORTANCE_HIGH)
                            .apply {
                                description = "Alarm notifications"
                                setSound(null, null)
                                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                            }
            val previewChannel =
                    NotificationChannel(
                                    PREVIEW_CHANNEL_ID,
                                    "Alarm Preview",
                                    NotificationManager.IMPORTANCE_LOW
                            )
                            .apply { setSound(null, null) }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
            manager.createNotificationChannel(previewChannel)
        }
    }

    private fun createNotification(label: String, alarmId: String): Notification {
        val fullScreenIntent =
                Intent(this, AlarmRingActivity::class.java).apply {
                    putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
                    putExtra(AlarmReceiver.EXTRA_LABEL, label)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
        val fullScreenPendingIntent =
                PendingIntent.getActivity(
                        this,
                        0,
                        fullScreenIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

        return NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("⏰ ${label.ifEmpty { "Alarm Ringing" }}")
                .setContentText("Tap to dismiss")
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .setOngoing(true)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .build()
    }

    private fun createPreviewNotification(): Notification {
        return NotificationCompat.Builder(this, PREVIEW_CHANNEL_ID)
                .setContentTitle("Previewing tone...")
                .setSmallIcon(android.R.drawable.ic_media_play)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setOngoing(true)
                .build()
    }

    private fun forceMaxVolume() {
        try {
            val am = getSystemService(AUDIO_SERVICE) as AudioManager
            val max = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            am.setStreamVolume(AudioManager.STREAM_ALARM, max, 0)
        } catch (_: Exception) {}
    }

    private fun playAlarmSound(tone: String) {
        try {
            val alarmUri =
                    if (tone == "default") {
                        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                    } else {
                        try {
                            Uri.parse(tone)
                        } catch (_: Exception) {
                            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        }
                    }

            mediaPlayer =
                    MediaPlayer().apply {
                        setDataSource(this@AlarmService, alarmUri)
                        setAudioAttributes(
                                AudioAttributes.Builder()
                                        .setUsage(AudioAttributes.USAGE_ALARM)
                                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                        .build()
                        )
                        isLooping = true
                        prepare()
                        start()
                    }
        } catch (e: Exception) {
            Log.e("AlarmService", "Failed to play alarm: ${e.message}")
        }
    }

    private fun startVibration() {
        vibrator =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val manager =
                            getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                    manager.defaultVibrator
                } else {
                    @Suppress("DEPRECATION") getSystemService(VIBRATOR_SERVICE) as Vibrator
                }

        val pattern = longArrayOf(0, 600, 400, 600, 400)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION") vibrator?.vibrate(pattern, 0)
        }
    }

    private fun launchRingActivity(
            alarmId: String,
            label: String,
            dismissType: String,
            mathDifficulty: Int,
            snoozeMinutes: Int
    ) {
        val intent =
                Intent(this, AlarmRingActivity::class.java).apply {
                    putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
                    putExtra(AlarmReceiver.EXTRA_LABEL, label)
                    putExtra(AlarmReceiver.EXTRA_DISMISS_TYPE, dismissType)
                    putExtra(AlarmReceiver.EXTRA_MATH_DIFFICULTY, mathDifficulty)
                    putExtra(AlarmReceiver.EXTRA_SNOOZE_MINUTES, snoozeMinutes)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
        startActivity(intent)
    }

    private fun acquireWakeLock() {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock =
                pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "AuraAlarm::WakeLock").apply {
                    acquire(10 * 60 * 1000L)
                }
    }

    fun stopAlarm() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        vibrator?.cancel()
        wakeLock?.release()
        wakeLock = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
        vibrator?.cancel()
        wakeLock?.release()
        instance = null
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        private const val CHANNEL_ID = "alarm_channel"
        private const val PREVIEW_CHANNEL_ID = "alarm_preview_channel"
        private const val NOTIFICATION_ID = 1001
        private const val PREVIEW_NOTIFICATION_ID = 1002

        const val EXTRA_IS_PREVIEW = "is_preview"

        var instance: AlarmService? = null
    }
}
