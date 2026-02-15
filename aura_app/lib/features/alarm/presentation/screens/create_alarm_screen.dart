import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Alarm' : 'New Alarm'),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
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
              _buildSection('Label', isDark),
              TextField(
                controller: _labelController,
                onChanged: (v) => _label = v,
                decoration: InputDecoration(
                  hintText: 'Alarm label (optional)',
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection('Repeat', isDark),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final isSelected = _repeatDays.contains(index);
                  return FilterChip(
                    label: Text(_days[index]),
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
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }),
              ),
              const SizedBox(height: 24),
              _buildSection('Dismiss Type', isDark),
              _buildDismissOption(
                'button',
                'Button',
                'Simple dismiss button',
                isDark,
              ),
              _buildDismissOption(
                'math',
                'Math Problem',
                'Solve to dismiss',
                isDark,
              ),
              if (_dismissType == 'math') ...[
                const SizedBox(height: 16),
                _buildSection('Math Difficulty', isDark),
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
                  onChanged: (v) => setState(() => _mathDifficulty = v.round()),
                ),
              ],
              const SizedBox(height: 24),
              _buildSection('Options', isDark),
              SwitchListTile(
                title: const Text('Vibrate'),
                value: _vibrate,
                onChanged: (v) => setState(() => _vibrate = v),
                activeColor: AppColors.primary,
              ),
              ListTile(
                title: const Text('Snooze duration'),
                trailing: DropdownButton<int>(
                  value: _snoozeMinutes,
                  items: [5, 10, 15, 20, 30].map((m) {
                    return DropdownMenuItem(value: m, child: Text('$m min'));
                  }).toList(),
                  onChanged: (v) => setState(() => _snoozeMinutes = v ?? 5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDismissOption(
    String value,
    String title,
    String subtitle,
    bool isDark,
  ) {
    return RadioListTile<String>(
      value: value,
      groupValue: _dismissType,
      onChanged: (v) => setState(() => _dismissType = v ?? 'button'),
      title: Text(title),
      subtitle: Text(subtitle),
      activeColor: AppColors.primary,
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
