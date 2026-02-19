package com.example.aura_app

import android.media.RingtoneManager
import com.example.aura_app.alarm.AlarmScheduler
import com.example.aura_app.alarm.AlarmService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aura.alarm/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            val scheduler = AlarmScheduler(this)

            when (call.method) {
                "scheduleAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")!!
                    // Dart int can arrive as Int or Long depending on platform — Number handles
                    // both
                    val rawMillis = call.argument<Number>("triggerTimeMillis")
                    if (rawMillis == null) {
                        result.error("MISSING_ARG", "triggerTimeMillis required", null)
                        return@setMethodCallHandler
                    }
                    val triggerTimeMillis = rawMillis.toLong()
                    val label = call.argument<String>("label") ?: ""
                    val tone = call.argument<String>("tone") ?: "default"
                    val vibrate = call.argument<Boolean>("vibrate") ?: true
                    val dismissType = call.argument<String>("dismissType") ?: "button"
                    val mathDifficulty = call.argument<Int>("mathDifficulty") ?: 1

                    val success =
                            scheduler.schedule(
                                    alarmId,
                                    triggerTimeMillis,
                                    label,
                                    tone,
                                    vibrate,
                                    dismissType,
                                    mathDifficulty
                            )
                    result.success(success)
                }
                "cancelAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")!!
                    result.success(scheduler.cancel(alarmId))
                }
                "cancelAllAlarms" -> {
                    result.success(scheduler.cancelAll())
                }
                "checkExactAlarmPermission" -> {
                    result.success(scheduler.canScheduleExactAlarms())
                }
                "requestExactAlarmPermission" -> {
                    scheduler.requestExactAlarmPermission()
                    result.success(null)
                }
                "getAvailableTones" -> {
                    val tones = getSystemAlarmTones()
                    result.success(tones)
                }
                "stopAlarmSound" -> {
                    val service = AlarmService.instance
                    service?.stopAlarm()
                    result.success(null)
                }
                "snoozeAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")!!
                    val snoozeMinutes = call.argument<Int>("snoozeMinutes") ?: 5
                    val snoozeMillis = System.currentTimeMillis() + (snoozeMinutes * 60 * 1000L)
                    val success =
                            scheduler.schedule(
                                    alarmId,
                                    snoozeMillis,
                                    "Snoozed Alarm",
                                    "default",
                                    true,
                                    "button",
                                    1
                            )
                    result.success(success)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getSystemAlarmTones(): List<String> {
        val tones = mutableListOf("default")
        try {
            val manager = RingtoneManager(this)
            manager.setType(RingtoneManager.TYPE_ALARM)
            val cursor = manager.cursor
            while (cursor.moveToNext()) {
                val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                tones.add(title)
            }
        } catch (e: Exception) {
            // fallback to just default
        }
        return tones
    }
}
