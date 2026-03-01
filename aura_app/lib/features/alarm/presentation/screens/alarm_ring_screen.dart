import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/model/alarm_model.dart';
import '../providers/alarm_provider.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  final String alarmId;

  const AlarmRingScreen({super.key, required this.alarmId});

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen>
    with SingleTickerProviderStateMixin {
  AlarmModel? _alarm;
  String? _mathProblem;
  int? _mathAnswer;
  final _answerController = TextEditingController();
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAlarm());
  }

  void _loadAlarm() {
    final state = ref.read(alarmProvider);
    final alarm = state.alarms.firstWhere(
      (a) => a.id == widget.alarmId,
      orElse: () => throw Exception('Alarm not found'),
    );
    setState(() {
      _alarm = alarm;
      if (alarm.hasMathDismiss) {
        _generateMathProblem(alarm.mathDifficulty);
      }
    });
  }

  void _generateMathProblem(int difficulty) {
    final random = Random();
    int a, b;
    String op;
    int answer;

    switch (difficulty) {
      case 1:
        a = random.nextInt(10) + 1;
        b = random.nextInt(10) + 1;
        op = random.nextBool() ? '+' : '-';
        answer = op == '+' ? a + b : a - b;
        break;
      case 2:
        a = random.nextInt(20) + 10;
        b = random.nextInt(10) + 1;
        op = ['+', '-', '×'][random.nextInt(3)];
        answer = op == '+'
            ? a + b
            : op == '-'
            ? a - b
            : a * b;
        break;
      case 3:
      default:
        a = random.nextInt(50) + 20;
        b = random.nextInt(20) + 5;
        op = ['+', '-', '×'][random.nextInt(3)];
        answer = op == '+'
            ? a + b
            : op == '-'
            ? a - b
            : a * b;
        break;
    }

    setState(() {
      _mathProblem = '$a $op $b = ?';
      _mathAnswer = answer;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    Icon(
                      Icons.alarm,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                ),
                if (_alarm?.label.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    _alarm!.label,
                    style: const TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                ],
                const Spacer(),
                if (_alarm?.hasMathDismiss == true && _mathProblem != null) ...[
                  Text(
                    'Solve to dismiss',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _mathProblem!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Answer',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      errorText: _errorMessage,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _checkAnswer(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _dismissAlarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _snoozeAlarm,
                  child: Text(
                    'Snooze ${_alarm?.snoozeMinutes ?? 5} minutes',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    final input = int.tryParse(_answerController.text);
    if (input == _mathAnswer) {
      _dismissAlarm();
    } else {
      setState(() {
        _errorMessage = 'Wrong answer, try again';
        _answerController.clear();
      });
      _generateMathProblem(_alarm!.mathDifficulty);
    }
  }

  void _dismissAlarm() {
    ref.read(alarmProvider.notifier).dismissAlarm(widget.alarmId);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _snoozeAlarm() {
    ref.read(alarmProvider.notifier).snoozeAlarm(widget.alarmId);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
