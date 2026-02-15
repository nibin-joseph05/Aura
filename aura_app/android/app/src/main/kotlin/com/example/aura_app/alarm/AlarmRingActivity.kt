package com.example.aura_app.alarm

import android.app.Activity
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast

class AlarmRingActivity : Activity() {
    private var alarmId: String = ""
    private var dismissType: String = "button"
    private var mathDifficulty: Int = 1
    private var currentProblem: MathDismissHelper.MathProblem? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )

        alarmId = intent.getStringExtra(AlarmReceiver.EXTRA_ALARM_ID) ?: ""
        val label = intent.getStringExtra(AlarmReceiver.EXTRA_LABEL) ?: "Alarm"
        dismissType = intent.getStringExtra(AlarmReceiver.EXTRA_DISMISS_TYPE) ?: "button"
        mathDifficulty = intent.getIntExtra(AlarmReceiver.EXTRA_MATH_DIFFICULTY, 1)

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(48, 96, 48, 48)
            setBackgroundColor(0xFF1a1a2e.toInt())
        }

        val timeText = TextView(this).apply {
            text = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
                .format(java.util.Date())
            textSize = 72f
            setTextColor(0xFFFFFFFF.toInt())
            textAlignment = View.TEXT_ALIGNMENT_CENTER
        }
        layout.addView(timeText)

        val labelText = TextView(this).apply {
            text = label
            textSize = 24f
            setTextColor(0xFFAAAAAA.toInt())
            textAlignment = View.TEXT_ALIGNMENT_CENTER
            setPadding(0, 16, 0, 48)
        }
        layout.addView(labelText)

        if (dismissType == "math") {
            addMathDismissUI(layout)
        } else {
            addButtonDismissUI(layout)
        }

        addSnoozeButton(layout)

        setContentView(layout)
    }

    private fun addButtonDismissUI(layout: LinearLayout) {
        val dismissButton = Button(this).apply {
            text = "Dismiss"
            textSize = 20f
            setBackgroundColor(0xFF6C63FF.toInt())
            setTextColor(0xFFFFFFFF.toInt())
            setPadding(32, 24, 32, 24)
            setOnClickListener { dismissAlarm() }
        }
        layout.addView(dismissButton)
    }

    private fun addMathDismissUI(layout: LinearLayout) {
        currentProblem = MathDismissHelper.generate(mathDifficulty)

        val problemText = TextView(this).apply {
            text = "Solve to dismiss"
            textSize = 16f
            setTextColor(0xFFAAAAAA.toInt())
            textAlignment = View.TEXT_ALIGNMENT_CENTER
            setPadding(0, 0, 0, 16)
        }
        layout.addView(problemText)

        val questionText = TextView(this).apply {
            text = currentProblem?.question ?: ""
            textSize = 32f
            setTextColor(0xFFFFFFFF.toInt())
            textAlignment = View.TEXT_ALIGNMENT_CENTER
            setPadding(0, 0, 0, 24)
            tag = "question"
        }
        layout.addView(questionText)

        val answerInput = EditText(this).apply {
            hint = "Answer"
            textSize = 24f
            setTextColor(0xFFFFFFFF.toInt())
            setHintTextColor(0xFF888888.toInt())
            textAlignment = View.TEXT_ALIGNMENT_CENTER
            setBackgroundColor(0xFF2a2a4e.toInt())
            setPadding(24, 16, 24, 16)
            inputType = android.text.InputType.TYPE_CLASS_NUMBER or 
                        android.text.InputType.TYPE_NUMBER_FLAG_SIGNED
            tag = "answer"
        }
        layout.addView(answerInput)

        val submitButton = Button(this).apply {
            text = "Submit"
            textSize = 20f
            setBackgroundColor(0xFF6C63FF.toInt())
            setTextColor(0xFFFFFFFF.toInt())
            setPadding(32, 24, 32, 24)
            setOnClickListener {
                val input = answerInput.text.toString().toIntOrNull()
                if (input == currentProblem?.answer) {
                    dismissAlarm()
                } else {
                    Toast.makeText(this@AlarmRingActivity, "Wrong answer!", Toast.LENGTH_SHORT).show()
                    answerInput.text.clear()
                    currentProblem = MathDismissHelper.generate(mathDifficulty)
                    (layout.findViewWithTag<TextView>("question"))?.text = currentProblem?.question
                }
            }
        }
        val params = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply { topMargin = 24 }
        layout.addView(submitButton, params)
    }

    private fun addSnoozeButton(layout: LinearLayout) {
        val snoozeButton = Button(this).apply {
            text = "Snooze 5 min"
            textSize = 16f
            setBackgroundColor(0x00000000)
            setTextColor(0xFF6C63FF.toInt())
            setOnClickListener { snoozeAlarm() }
        }
        val params = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply { topMargin = 32 }
        layout.addView(snoozeButton, params)
    }

    private fun dismissAlarm() {
        stopService(android.content.Intent(this, AlarmService::class.java))
        finish()
    }

    private fun snoozeAlarm() {
        stopService(android.content.Intent(this, AlarmService::class.java))
        finish()
    }

    override fun onBackPressed() {
    }
}
