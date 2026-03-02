package com.example.aura_app.alarm

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.activity.compose.setContent
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.text.SimpleDateFormat
import java.util.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class AlarmRingActivity : ComponentActivity() {

        private val volumeHandler = Handler(Looper.getMainLooper())
        private val volumeRunnable =
                object : Runnable {
                        override fun run() {
                                enforceMaxVolume()
                                volumeHandler.postDelayed(this, 500)
                        }
                }

        override fun onCreate(savedInstanceState: Bundle?) {
                super.onCreate(savedInstanceState)

                window.addFlags(
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                                WindowManager.LayoutParams.FLAG_FULLSCREEN
                )

                onBackPressedDispatcher.addCallback(
                        this,
                        object : OnBackPressedCallback(true) {
                                override fun handleOnBackPressed() {}
                        }
                )

                volumeHandler.post(volumeRunnable)

                val alarmId = intent.getStringExtra(AlarmReceiver.EXTRA_ALARM_ID) ?: ""
                val label = intent.getStringExtra(AlarmReceiver.EXTRA_LABEL) ?: "Alarm"
                val dismissType =
                        intent.getStringExtra(AlarmReceiver.EXTRA_DISMISS_TYPE) ?: "button"
                val mathDifficulty = intent.getIntExtra(AlarmReceiver.EXTRA_MATH_DIFFICULTY, 1)
                val snoozeMinutes = intent.getIntExtra(AlarmReceiver.EXTRA_SNOOZE_MINUTES, 5)
                val tone = intent.getStringExtra(AlarmReceiver.EXTRA_TONE) ?: "default"
                val vibrate = intent.getBooleanExtra(AlarmReceiver.EXTRA_VIBRATE, true)

                setContent {
                        AlarmRingScreen(
                                label = label,
                                dismissType = dismissType,
                                mathDifficulty = mathDifficulty,
                                snoozeMinutes = snoozeMinutes,
                                onDismiss = { dismissAlarm() },
                                onSnooze = {
                                        snoozeAlarm(
                                                alarmId,
                                                label,
                                                tone,
                                                vibrate,
                                                dismissType,
                                                mathDifficulty,
                                                snoozeMinutes
                                        )
                                }
                        )
                }
        }

        override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
                return when (keyCode) {
                        KeyEvent.KEYCODE_BACK, KeyEvent.KEYCODE_HOME, KeyEvent.KEYCODE_APP_SWITCH ->
                                true
                        else -> super.onKeyDown(keyCode, event)
                }
        }

        private fun enforceMaxVolume() {
                try {
                        val am = getSystemService(AUDIO_SERVICE) as android.media.AudioManager
                        val max = am.getStreamMaxVolume(android.media.AudioManager.STREAM_ALARM)
                        am.setStreamVolume(android.media.AudioManager.STREAM_ALARM, max, 0)
                } catch (_: Exception) {}
        }

        private fun dismissAlarm() {
                volumeHandler.removeCallbacks(volumeRunnable)
                stopService(Intent(this, AlarmService::class.java))
                finish()
        }

        private fun snoozeAlarm(
                alarmId: String,
                label: String,
                tone: String,
                vibrate: Boolean,
                dismissType: String,
                mathDifficulty: Int,
                snoozeMinutes: Int
        ) {
                volumeHandler.removeCallbacks(volumeRunnable)
                val snoozeMillis = System.currentTimeMillis() + (snoozeMinutes * 60 * 1000L)
                val scheduler = AlarmScheduler(this)
                scheduler.schedule(
                        alarmId = alarmId,
                        triggerTimeMillis = snoozeMillis,
                        label = label,
                        tone = tone,
                        vibrate = vibrate,
                        dismissType = dismissType,
                        mathDifficulty = mathDifficulty,
                        snoozeMinutes = snoozeMinutes
                )
                stopService(Intent(this, AlarmService::class.java))
                finish()
        }

        override fun onDestroy() {
                super.onDestroy()
                volumeHandler.removeCallbacks(volumeRunnable)
        }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlarmRingScreen(
        label: String,
        dismissType: String,
        mathDifficulty: Int,
        snoozeMinutes: Int,
        onDismiss: () -> Unit,
        onSnooze: () -> Unit
) {
        val coroutineScope = rememberCoroutineScope()
        val focusManager = LocalFocusManager.current

        var currentTime by remember {
                mutableStateOf(SimpleDateFormat("hh:mm", Locale.getDefault()).format(Date()))
        }
        var amPm by remember {
                mutableStateOf(SimpleDateFormat("a", Locale.getDefault()).format(Date()))
        }
        var answerText by remember { mutableStateOf("") }
        var currentProblem by remember {
                mutableStateOf(MathDismissHelper.generate(mathDifficulty))
        }
        var isError by remember { mutableStateOf(false) }
        var shakeOffset by remember { mutableStateOf(0f) }

        val infiniteTransition = rememberInfiniteTransition(label = "pulse")
        val pulseScale by
                infiniteTransition.animateFloat(
                        initialValue = 1f,
                        targetValue = 1.15f,
                        animationSpec =
                                infiniteRepeatable(
                                        animation = tween(900, easing = FastOutSlowInEasing),
                                        repeatMode = RepeatMode.Reverse
                                ),
                        label = "scale"
                )
        val glowAlpha by
                infiniteTransition.animateFloat(
                        initialValue = 0.15f,
                        targetValue = 0.4f,
                        animationSpec =
                                infiniteRepeatable(
                                        animation = tween(900, easing = FastOutSlowInEasing),
                                        repeatMode = RepeatMode.Reverse
                                ),
                        label = "glow"
                )

        val errorColor by
                animateColorAsState(
                        targetValue = if (isError) Color(0xFFFF4444) else Color(0xFF00E5D4),
                        animationSpec = tween(200),
                        label = "errorColor"
                )

        val shakeAnim = remember { Animatable(0f) }

        LaunchedEffect(isError) {
                if (isError) {
                        shakeAnim.animateTo(
                                targetValue = 0f,
                                animationSpec =
                                        keyframes {
                                                durationMillis = 400
                                                -20f at 50
                                                20f at 100
                                                -20f at 150
                                                20f at 200
                                                -10f at 250
                                                10f at 300
                                                0f at 400
                                        }
                        )
                }
        }

        LaunchedEffect(Unit) {
                while (true) {
                        delay(1000)
                        val now = Date()
                        currentTime = SimpleDateFormat("hh:mm", Locale.getDefault()).format(now)
                        amPm = SimpleDateFormat("a", Locale.getDefault()).format(now)
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
                                                                        Color(0xFF050D1A),
                                                                        Color(0xFF0B2240),
                                                                        Color(0xFF0D3A6B)
                                                                )
                                                )
                                )
        ) {
                Column(
                        modifier = Modifier.fillMaxSize().padding(horizontal = 28.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                ) {
                        Spacer(modifier = Modifier.height(64.dp))

                        Box(contentAlignment = Alignment.Center, modifier = Modifier.size(140.dp)) {
                                Box(
                                        modifier =
                                                Modifier.size(140.dp)
                                                        .scale(pulseScale)
                                                        .clip(CircleShape)
                                                        .background(
                                                                Color(0xFF00E5D4)
                                                                        .copy(alpha = glowAlpha)
                                                        )
                                )
                                Box(
                                        modifier =
                                                Modifier.size(100.dp)
                                                        .clip(CircleShape)
                                                        .background(
                                                                Color(0xFF00E5D4).copy(alpha = 0.2f)
                                                        )
                                )
                                Text(
                                        text = "\uD83D\uDD14",
                                        fontSize = 48.sp,
                                )
                        }

                        Spacer(modifier = Modifier.height(28.dp))

                        Row(verticalAlignment = Alignment.Bottom) {
                                Text(
                                        text = currentTime,
                                        fontSize = 80.sp,
                                        fontWeight = FontWeight.ExtraLight,
                                        color = Color.White,
                                        letterSpacing = (-2).sp
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                        text = amPm,
                                        fontSize = 28.sp,
                                        fontWeight = FontWeight.Light,
                                        color = Color(0xFF00E5D4),
                                        modifier = Modifier.padding(bottom = 14.dp)
                                )
                        }

                        if (label.isNotEmpty()) {
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                        text = label,
                                        fontSize = 20.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = Color.White.copy(alpha = 0.65f),
                                        textAlign = TextAlign.Center
                                )
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        if (dismissType == "math") {
                                Box(
                                        modifier =
                                                Modifier.fillMaxWidth()
                                                        .offset(x = shakeAnim.value.dp)
                                                        .clip(RoundedCornerShape(28.dp))
                                                        .background(Color(0xFF0D2235))
                                                        .padding(24.dp)
                                ) {
                                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                                Text(
                                                        text = "SOLVE TO DISMISS",
                                                        fontSize = 11.sp,
                                                        fontWeight = FontWeight.Bold,
                                                        color = Color(0xFF00E5D4),
                                                        letterSpacing = 2.sp
                                                )
                                                Spacer(modifier = Modifier.height(20.dp))
                                                Text(
                                                        text = currentProblem.question,
                                                        fontSize = 44.sp,
                                                        fontWeight = FontWeight.Bold,
                                                        color = Color.White,
                                                        textAlign = TextAlign.Center
                                                )
                                                Spacer(modifier = Modifier.height(20.dp))
                                                OutlinedTextField(
                                                        value = answerText,
                                                        onValueChange = { answerText = it },
                                                        keyboardOptions =
                                                                KeyboardOptions(
                                                                        keyboardType =
                                                                                KeyboardType
                                                                                        .NumberPassword
                                                                ),
                                                        placeholder = {
                                                                Text(
                                                                        "Answer...",
                                                                        color =
                                                                                Color.White.copy(
                                                                                        alpha = 0.3f
                                                                                )
                                                                )
                                                        },
                                                        colors =
                                                                OutlinedTextFieldDefaults.colors(
                                                                        focusedBorderColor =
                                                                                errorColor,
                                                                        unfocusedBorderColor =
                                                                                Color.White.copy(
                                                                                        alpha =
                                                                                                0.25f
                                                                                ),
                                                                        focusedContainerColor =
                                                                                Color.White.copy(
                                                                                        alpha = 0.1f
                                                                                ),
                                                                        unfocusedContainerColor =
                                                                                Color.White.copy(
                                                                                        alpha =
                                                                                                0.06f
                                                                                ),
                                                                        focusedTextColor =
                                                                                Color.White,
                                                                        unfocusedTextColor =
                                                                                Color.White
                                                                ),
                                                        shape = RoundedCornerShape(14.dp),
                                                        modifier = Modifier.fillMaxWidth(),
                                                        singleLine = true
                                                )
                                                Spacer(modifier = Modifier.height(16.dp))
                                                Button(
                                                        onClick = {
                                                                val input =
                                                                        answerText
                                                                                .trim()
                                                                                .toIntOrNull()
                                                                if (input == currentProblem.answer
                                                                ) {
                                                                        onDismiss()
                                                                } else {
                                                                        answerText = ""
                                                                        isError = true
                                                                        coroutineScope.launch {
                                                                                delay(700)
                                                                                isError = false
                                                                                currentProblem =
                                                                                        MathDismissHelper
                                                                                                .generate(
                                                                                                        mathDifficulty
                                                                                                )
                                                                        }
                                                                }
                                                        },
                                                        modifier =
                                                                Modifier.fillMaxWidth()
                                                                        .height(54.dp),
                                                        colors =
                                                                ButtonDefaults.buttonColors(
                                                                        containerColor =
                                                                                Color(0xFF00E5D4)
                                                                ),
                                                        shape = RoundedCornerShape(14.dp)
                                                ) {
                                                        Text(
                                                                "Submit",
                                                                fontSize = 17.sp,
                                                                fontWeight = FontWeight.Bold,
                                                                color = Color(0xFF050D1A)
                                                        )
                                                }
                                        }
                                }
                        } else {
                                Button(
                                        onClick = onDismiss,
                                        modifier = Modifier.fillMaxWidth().height(58.dp),
                                        colors =
                                                ButtonDefaults.buttonColors(
                                                        containerColor = Color(0xFF00E5D4)
                                                ),
                                        shape = RoundedCornerShape(16.dp),
                                        elevation =
                                                ButtonDefaults.buttonElevation(
                                                        defaultElevation = 8.dp
                                                )
                                ) {
                                        Text(
                                                "DISMISS",
                                                fontSize = 18.sp,
                                                fontWeight = FontWeight.ExtraBold,
                                                color = Color(0xFF050D1A),
                                                letterSpacing = 2.sp
                                        )
                                }
                        }

                        Spacer(modifier = Modifier.height(14.dp))

                        TextButton(
                                onClick = onSnooze,
                                modifier = Modifier.fillMaxWidth().height(50.dp)
                        ) {
                                Text(
                                        "Snooze $snoozeMinutes min",
                                        fontSize = 15.sp,
                                        color = Color.White.copy(alpha = 0.5f)
                                )
                        }

                        Spacer(modifier = Modifier.height(36.dp))
                }
        }
}
