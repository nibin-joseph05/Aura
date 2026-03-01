package com.example.aura_app.alarm

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class AlarmRingActivity : ComponentActivity() {

        override fun onCreate(savedInstanceState: Bundle?) {
                super.onCreate(savedInstanceState)

                window.addFlags(
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                )

                val alarmId = intent.getStringExtra(AlarmReceiver.EXTRA_ALARM_ID) ?: ""
                val label = intent.getStringExtra(AlarmReceiver.EXTRA_LABEL) ?: "Alarm"
                val dismissType =
                        intent.getStringExtra(AlarmReceiver.EXTRA_DISMISS_TYPE) ?: "button"
                val mathDifficulty = intent.getIntExtra(AlarmReceiver.EXTRA_MATH_DIFFICULTY, 1)

                setContent {
                        AlarmRingScreen(
                                label = label,
                                dismissType = dismissType,
                                mathDifficulty = mathDifficulty,
                                onDismiss = { dismissAlarm() },
                                onSnooze = { snoozeAlarm() }
                        )
                }
        }

        private fun dismissAlarm() {
                stopService(Intent(this, AlarmService::class.java))
                finish()
        }

        private fun snoozeAlarm() {
                stopService(Intent(this, AlarmService::class.java))
                finish()
        }

        @Deprecated("Deprecated in Java")
        override fun onBackPressed() {
                super.onBackPressed()
        }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmRingScreen(
        label: String,
        dismissType: String,
        mathDifficulty: Int,
        onDismiss: () -> Unit,
        onSnooze: () -> Unit
) {
        var currentTime by remember {
                mutableStateOf(SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date()))
        }
        var currentProblem by remember {
                mutableStateOf(MathDismissHelper.generate(mathDifficulty))
        }
        var answerText by remember { mutableStateOf("") }

        var isError by remember { mutableStateOf(false) }
        val focusManager = LocalFocusManager.current
        val coroutineScope = rememberCoroutineScope()

        val infiniteTransition = rememberInfiniteTransition(label = "pulse")
        val scale by
                infiniteTransition.animateFloat(
                        initialValue = 1f,
                        targetValue = 1.1f,
                        animationSpec =
                                infiniteRepeatable(
                                        animation = tween(1000, easing = FastOutSlowInEasing),
                                        repeatMode = RepeatMode.Reverse
                                ),
                        label = "scale"
                )

        LaunchedEffect(Unit) {
                while (true) {
                        delay(1000)
                        currentTime = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
                }
        }

        Box(
                modifier =
                        Modifier.fillMaxSize()
                                .pointerInput(Unit) {
                                        detectTapGestures(onTap = { focusManager.clearFocus() })
                                }
                                .background(
                                        brush =
                                                Brush.verticalGradient(
                                                        colors =
                                                                listOf(
                                                                        Color(0xFF0A1A2F),
                                                                        Color(0xFF134B73)
                                                                )
                                                )
                                )
        ) {
                Column(
                        modifier = Modifier.fillMaxSize().padding(32.dp),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                ) {
                        Spacer(modifier = Modifier.weight(1f))

                        Box(contentAlignment = Alignment.Center, modifier = Modifier.size(120.dp)) {
                                Box(
                                        modifier =
                                                Modifier.size(120.dp)
                                                        .scale(scale)
                                                        .background(
                                                                Color.White.copy(alpha = 0.1f),
                                                                shape =
                                                                        RoundedCornerShape(
                                                                                percent = 50
                                                                        )
                                                        )
                                )
                                Icon(
                                        painter = rememberVectorPainter(Icons.Filled.Notifications),
                                        contentDescription = null,
                                        modifier = Modifier.size(60.dp),
                                        tint = Color.White.copy(alpha = 0.9f)
                                )
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        Text(
                                text = currentTime,
                                fontSize = 72.sp,
                                fontWeight = FontWeight.Light,
                                color = Color.White
                        )

                        if (label.isNotEmpty()) {
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                        text = label,
                                        fontSize = 20.sp,
                                        color = Color.White.copy(alpha = 0.7f)
                                )
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        if (dismissType == "math") {
                                Box(
                                        modifier =
                                                Modifier.clip(RoundedCornerShape(24.dp))
                                                        .background(Color.White.copy(alpha = 0.1f))
                                                        .padding(24.dp)
                                ) {
                                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                                Text(
                                                        text = "Solve to dismiss",
                                                        fontSize = 16.sp,
                                                        color = Color.White.copy(alpha = 0.7f)
                                                )
                                                Spacer(modifier = Modifier.height(16.dp))
                                                Text(
                                                        text = currentProblem.question,
                                                        fontSize = 32.sp,
                                                        fontWeight = FontWeight.Bold,
                                                        color = Color.White
                                                )
                                                Spacer(modifier = Modifier.height(16.dp))
                                                OutlinedTextField(
                                                        value = answerText,
                                                        onValueChange = { answerText = it },
                                                        keyboardOptions =
                                                                KeyboardOptions(
                                                                        keyboardType =
                                                                                KeyboardType.Number
                                                                ),
                                                        colors =
                                                                OutlinedTextFieldDefaults.colors(
                                                                        focusedBorderColor =
                                                                                if (isError)
                                                                                        Color.Red
                                                                                else
                                                                                        Color.Transparent,
                                                                        unfocusedBorderColor =
                                                                                if (isError)
                                                                                        Color.Red
                                                                                else
                                                                                        Color.Transparent,
                                                                        focusedContainerColor =
                                                                                Color.White.copy(
                                                                                        alpha =
                                                                                                0.15f
                                                                                ),
                                                                        unfocusedContainerColor =
                                                                                Color.White.copy(
                                                                                        alpha =
                                                                                                0.15f
                                                                                ),
                                                                        focusedTextColor =
                                                                                if (isError)
                                                                                        Color.Red
                                                                                else Color.White,
                                                                        unfocusedTextColor =
                                                                                if (isError)
                                                                                        Color.Red
                                                                                else Color.White
                                                                ),
                                                        shape = RoundedCornerShape(12.dp),
                                                        modifier = Modifier.fillMaxWidth()
                                                )
                                                Spacer(modifier = Modifier.height(16.dp))
                                                Button(
                                                        onClick = {
                                                                val input = answerText.toIntOrNull()
                                                                if (input == currentProblem.answer
                                                                ) {
                                                                        onDismiss()
                                                                } else {
                                                                        answerText = ""
                                                                        isError = true
                                                                        coroutineScope.launch {
                                                                                delay(600)
                                                                                isError = false
                                                                        }
                                                                        currentProblem =
                                                                                MathDismissHelper
                                                                                        .generate(
                                                                                                mathDifficulty
                                                                                        )
                                                                }
                                                        },
                                                        modifier =
                                                                Modifier.fillMaxWidth()
                                                                        .height(56.dp),
                                                        colors =
                                                                ButtonDefaults.buttonColors(
                                                                        containerColor =
                                                                                Color(0xFF00BCD4)
                                                                ),
                                                        shape = RoundedCornerShape(12.dp)
                                                ) {
                                                        Text(
                                                                text = "Submit",
                                                                fontSize = 18.sp,
                                                                color = Color.White
                                                        )
                                                }
                                        }
                                }
                        } else {
                                Button(
                                        onClick = onDismiss,
                                        modifier = Modifier.fillMaxWidth().height(56.dp),
                                        colors =
                                                ButtonDefaults.buttonColors(
                                                        containerColor = Color(0xFF00BCD4)
                                                ),
                                        shape = RoundedCornerShape(12.dp)
                                ) { Text(text = "Dismiss", fontSize = 18.sp, color = Color.White) }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        TextButton(
                                onClick = onSnooze,
                                modifier = Modifier.fillMaxWidth().height(48.dp)
                        ) {
                                Text(
                                        text = "Snooze 5 minutes",
                                        fontSize = 16.sp,
                                        color = Color.White.copy(alpha = 0.7f)
                                )
                        }

                        Spacer(modifier = Modifier.height(32.dp))
                }
        }
}
