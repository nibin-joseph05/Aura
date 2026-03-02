package com.example.aura_app.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import org.json.JSONArray

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action != Intent.ACTION_BOOT_COMPLETED &&
                        action != "android.intent.action.QUICKBOOT_POWERON" &&
                        action != Intent.ACTION_MY_PACKAGE_REPLACED
        )
                return

        Log.i("BootReceiver", "Device rebooted — rescheduling alarms")
        val prefs = context.getSharedPreferences("aura_alarms", Context.MODE_PRIVATE)
        val json = prefs.getString("scheduled_alarms", "[]") ?: "[]"

        try {
            val array = JSONArray(json)
            val scheduler = AlarmScheduler(context)
            val now = System.currentTimeMillis()

            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                val alarmId = obj.getString("alarmId")
                val triggerTimeMillis = obj.getLong("triggerTimeMillis")
                val label = obj.getString("label")
                val tone = obj.getString("tone")
                val vibrate = obj.getBoolean("vibrate")
                val dismissType = obj.getString("dismissType")
                val mathDifficulty = obj.getInt("mathDifficulty")
                val snoozeMinutes = obj.optInt("snoozeMinutes", 5)
                val repeatDaysJson = obj.optJSONArray("repeatDays")

                if (triggerTimeMillis < now) {
                    if (repeatDaysJson != null && repeatDaysJson.length() > 0) {
                        val repeatDays = mutableListOf<Int>()
                        for (d in 0 until repeatDaysJson.length()) repeatDays.add(
                                repeatDaysJson.getInt(d)
                        )
                        val next =
                                calculateNextRepeating(
                                        repeatDays,
                                        obj.getInt("hour"),
                                        obj.getInt("minute")
                                )
                        scheduler.schedule(
                                alarmId,
                                next,
                                label,
                                tone,
                                vibrate,
                                dismissType,
                                mathDifficulty,
                                snoozeMinutes
                        )
                    }
                } else {
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
                }
            }
        } catch (e: Exception) {
            Log.e("BootReceiver", "Failed to reschedule: ${e.message}")
        }
    }

    private fun calculateNextRepeating(repeatDays: List<Int>, hour: Int, minute: Int): Long {
        val cal = java.util.Calendar.getInstance()
        cal.set(java.util.Calendar.HOUR_OF_DAY, hour)
        cal.set(java.util.Calendar.MINUTE, minute)
        cal.set(java.util.Calendar.SECOND, 0)
        cal.set(java.util.Calendar.MILLISECOND, 0)
        if (cal.timeInMillis < System.currentTimeMillis()) {
            cal.add(java.util.Calendar.DAY_OF_YEAR, 1)
        }
        var tries = 0
        while (!repeatDays.contains(cal.get(java.util.Calendar.DAY_OF_WEEK) - 2) && tries < 7) {
            cal.add(java.util.Calendar.DAY_OF_YEAR, 1)
            tries++
        }
        return cal.timeInMillis
    }
}
