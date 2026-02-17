import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../providers/alarm_provider.dart';
import '../widgets/time_picker_widget.dart';

class CreateAlarmScreen extends ConsumerStatefulWidget {
  final String? editAlarmId;

  const CreateAlarmScreen({super.key, this.editAlarmId});

  @override
  ConsumerState<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends ConsumerState<CreateAlarmScreen> {
  int _hour = 7;
  int _minute = 0;
  String _label = '';
  List<int> _repeatDays = [];
  String _dismissType = 'button';
  int _mathDifficulty = 1;
  bool _vibrate = true;
  int _snoozeMinutes = 5;

  final _labelController = TextEditingController();
  bool _isEditing = false;

  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    if (widget.editAlarmId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAlarm());
    }
  }

  void _loadAlarm() {
    final state = ref.read(alarmProvider);
    final alarm = state.alarms.firstWhere(
      (a) => a.id == widget.editAlarmId,
      orElse: () => throw Exception('Alarm not found'),
    );
    setState(() {
      _hour = alarm.hour;
      _minute = alarm.minute;
      _label = alarm.label;
      _labelController.text = alarm.label;
      _repeatDays = List.from(alarm.repeatDays);
      _dismissType = alarm.dismissType;
      _mathDifficulty = alarm.mathDifficulty;
      _vibrate = alarm.vibrate;
      _snoozeMinutes = alarm.snoozeMinutes;
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              AppHeader(
                title: _isEditing ? 'Edit Alarm' : 'New Alarm',
                actions: [
                  TextButton(
                    onPressed: _saveAlarm,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TimePickerWidget(
                        hour: _hour,
                        minute: _minute,
                        onHourChanged: (h) => setState(() => _hour = h),
                        onMinuteChanged: (m) => setState(() => _minute = m),
                      ),
                      const SizedBox(height: 32),
                      _buildSection('Label'),
                      TextField(
                        controller: _labelController,
                        onChanged: (v) => _label = v,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Alarm label (optional)',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSection('Repeat'),
                      Wrap(
                        spacing: 8,
                        children: List.generate(7, (index) {
                          final isSelected = _repeatDays.contains(index);
                          return FilterChip(
                            label: Text(
                              _days[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _repeatDays.add(index);
                                } else {
                                  _repeatDays.remove(index);
                                }
                              });
                            },
                            selectedColor: AppColors.accent.withValues(
                              alpha: 0.3,
                            ),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            checkmarkColor: Colors.white,
                            side: BorderSide.none,
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      _buildSection('Dismiss Type'),
                      _buildDismissOption(
                        'button',
                        'Button',
                        'Simple dismiss button',
                      ),
                      _buildDismissOption(
                        'math',
                        'Math Problem',
                        'Solve to dismiss',
                      ),
                      if (_dismissType == 'math') ...[
                        const SizedBox(height: 16),
                        _buildSection('Math Difficulty'),
                        Slider(
                          value: _mathDifficulty.toDouble(),
                          min: 1,
                          max: 3,
                          divisions: 2,
                          label: _mathDifficulty == 1
                              ? 'Easy'
                              : _mathDifficulty == 2
                              ? 'Medium'
                              : 'Hard',
                          activeColor: AppColors.accent,
                          inactiveColor: Colors.white.withValues(alpha: 0.2),
                          onChanged: (v) =>
                              setState(() => _mathDifficulty = v.round()),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildSection('Options'),
                      SwitchListTile(
                        title: const Text(
                          'Vibrate',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: _vibrate,
                        onChanged: (v) => setState(() => _vibrate = v),
                        activeColor: AppColors.accent,
                      ),
                      ListTile(
                        title: const Text(
                          'Snooze duration',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: DropdownButton<int>(
                          value: _snoozeMinutes,
                          dropdownColor: AppColors.surfaceDark,
                          style: const TextStyle(color: Colors.white),
                          items: [5, 10, 15, 20, 30].map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text('$m min'),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _snoozeMinutes = v ?? 5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildDismissOption(String value, String title, String subtitle) {
    return RadioListTile<String>(
      value: value,
      groupValue: _dismissType,
      onChanged: (v) => setState(() => _dismissType = v ?? 'button'),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      ),
      activeColor: AppColors.accent,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _saveAlarm() async {
    final notifier = ref.read(alarmProvider.notifier);
    bool success;

    if (_isEditing) {
      final state = ref.read(alarmProvider);
      final alarm = state.alarms.firstWhere((a) => a.id == widget.editAlarmId);
      alarm.hour = _hour;
      alarm.minute = _minute;
      alarm.label = _label;
      alarm.repeatDays = _repeatDays;
      alarm.dismissType = _dismissType;
      alarm.mathDifficulty = _mathDifficulty;
      alarm.vibrate = _vibrate;
      alarm.snoozeMinutes = _snoozeMinutes;
      success = await notifier.updateAlarm(alarm);
    } else {
      success = await notifier.createAlarm(
        hour: _hour,
        minute: _minute,
        label: _label,
        repeatDays: _repeatDays,
        dismissType: _dismissType,
        mathDifficulty: _mathDifficulty,
        vibrate: _vibrate,
        snoozeMinutes: _snoozeMinutes,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
