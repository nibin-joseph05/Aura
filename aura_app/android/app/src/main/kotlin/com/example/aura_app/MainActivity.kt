package com.example.aura_app

import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import com.example.aura_app.alarm.AlarmReceiver
import com.example.aura_app.alarm.AlarmScheduler
import com.example.aura_app.alarm.AlarmService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aura.alarm/native"
    private var ringtonePendingResult: MethodChannel.Result? = null
    private val RINGTONE_REQUEST_CODE = 9999

    @Suppress("DEPRECATION", "OVERRIDE_DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == RINGTONE_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                @Suppress("DEPRECATION")
                val uri: Uri? = data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                ringtonePendingResult?.success(uri?.toString())
            } else {
                ringtonePendingResult?.success(null)
            }
            ringtonePendingResult = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            val scheduler = AlarmScheduler(this)

            when (call.method) {
                "scheduleAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")!!
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
                    val snoozeMinutes = call.argument<Int>("snoozeMinutes") ?: 5
                    val hour = call.argument<Int>("hour") ?: 0
                    val minute = call.argument<Int>("minute") ?: 0
                    val repeatDaysRaw = call.argument<List<Int>>("repeatDays") ?: emptyList()

                    val success =
                            scheduler.schedule(
                                    alarmId,
                                    triggerTimeMillis,
                                    label,
                                    tone,
                                    vibrate,
                                    dismissType,
                                    mathDifficulty,
                                    snoozeMinutes
                            )
                    if (success)
                            persistAlarm(
                                    alarmId,
                                    triggerTimeMillis,
                                    label,
                                    tone,
                                    vibrate,
                                    dismissType,
                                    mathDifficulty,
                                    snoozeMinutes,
                                    hour,
                                    minute,
                                    repeatDaysRaw
                            )
                    result.success(success)
                }
                "cancelAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")!!
                    removePersistedAlarm(alarmId)
                    result.success(scheduler.cancel(alarmId))
                }
                "cancelAllAlarms" -> {
                    clearPersistedAlarms()
                    result.success(scheduler.cancelAll())
                }
                "checkExactAlarmPermission" -> result.success(scheduler.canScheduleExactAlarms())
                "requestExactAlarmPermission" -> {
                    scheduler.requestExactAlarmPermission()
                    result.success(null)
                }
                "getAvailableTones" -> {
                    Thread {
                                val tones = getSystemAlarmTones()
                                android.os.Handler(android.os.Looper.getMainLooper()).post {
                                    result.success(tones)
                                }
                            }
                            .start()
                }
                "stopAlarmSound" -> {
                    AlarmService.instance?.stopAlarm()
                    result.success(null)
                }
                "playAlarmSound" -> {
                    val tone = call.argument<String>("tone") ?: "default"
                    val intent =
                            Intent(this, AlarmService::class.java).apply {
                                putExtra(AlarmReceiver.EXTRA_ALARM_ID, "preview")
                                putExtra(AlarmReceiver.EXTRA_LABEL, "Preview")
                                putExtra(AlarmReceiver.EXTRA_TONE, tone)
                                putExtra(AlarmReceiver.EXTRA_VIBRATE, false)
                                putExtra(AlarmReceiver.EXTRA_DISMISS_TYPE, "button")
                                putExtra(AlarmReceiver.EXTRA_MATH_DIFFICULTY, 1)
                                putExtra(AlarmReceiver.EXTRA_SNOOZE_MINUTES, 5)
                                putExtra(AlarmService.EXTRA_IS_PREVIEW, true)
                            }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                "pickCustomRingtone" -> {
                    ringtonePendingResult = result
                    val intent =
                            Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                                putExtra(
                                        RingtoneManager.EXTRA_RINGTONE_TYPE,
                                        RingtoneManager.TYPE_ALL
                                )
                                putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Select Alarm Tone")
                                putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                                putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            }
                    @Suppress("DEPRECATION") startActivityForResult(intent, RINGTONE_REQUEST_CODE)
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
                                    1,
                                    snoozeMinutes
                            )
                    result.success(success)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun persistAlarm(
            alarmId: String,
            triggerTimeMillis: Long,
            label: String,
            tone: String,
            vibrate: Boolean,
            dismissType: String,
            mathDifficulty: Int,
            snoozeMinutes: Int,
            hour: Int,
            minute: Int,
            repeatDays: List<Int>
    ) {
        val prefs = getSharedPreferences("aura_alarms", MODE_PRIVATE)
        val json = prefs.getString("scheduled_alarms", "[]") ?: "[]"
        val array =
                try {
                    JSONArray(json)
                } catch (e: Exception) {
                    JSONArray()
                }

        val obj =
                JSONObject().apply {
                    put("alarmId", alarmId)
                    put("triggerTimeMillis", triggerTimeMillis)
                    put("label", label)
                    put("tone", tone)
                    put("vibrate", vibrate)
                    put("dismissType", dismissType)
                    put("mathDifficulty", mathDifficulty)
                    put("snoozeMinutes", snoozeMinutes)
                    put("hour", hour)
                    put("minute", minute)
                    val daysArr = JSONArray()
                    repeatDays.forEach { daysArr.put(it) }
                    put("repeatDays", daysArr)
                }

        for (i in 0 until array.length()) {
            if (array.getJSONObject(i).getString("alarmId") == alarmId) {
                array.remove(i)
                break
            }
        }
        array.put(obj)
        prefs.edit().putString("scheduled_alarms", array.toString()).apply()
    }

    private fun removePersistedAlarm(alarmId: String) {
        val prefs = getSharedPreferences("aura_alarms", MODE_PRIVATE)
        val json = prefs.getString("scheduled_alarms", "[]") ?: "[]"
        val array =
                try {
                    JSONArray(json)
                } catch (e: Exception) {
                    JSONArray()
                }
        val newArray = JSONArray()
        for (i in 0 until array.length()) {
            val obj = array.getJSONObject(i)
            if (obj.getString("alarmId") != alarmId) newArray.put(obj)
        }
        prefs.edit().putString("scheduled_alarms", newArray.toString()).apply()
    }

    private fun clearPersistedAlarms() {
        getSharedPreferences("aura_alarms", MODE_PRIVATE).edit().remove("scheduled_alarms").apply()
    }

    private fun getSystemAlarmTones(): List<Map<String, String>> {
        val tones = mutableListOf<Map<String, String>>()
        tones.add(mapOf("title" to "Default", "uri" to "default"))
        try {
            val manager = RingtoneManager(this)
            manager.setType(RingtoneManager.TYPE_ALARM)
            val cursor = manager.cursor
            while (cursor.moveToNext()) {
                val title = manager.getRingtone(cursor.position).getTitle(this) ?: "Unknown"
                val uriStr = manager.getRingtoneUri(cursor.position).toString()
                tones.add(mapOf("title" to title, "uri" to uriStr))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return tones
    }
}
