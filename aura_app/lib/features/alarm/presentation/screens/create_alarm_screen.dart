import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../data/service/alarm_native_service.dart';
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
  String _tone = 'default';
  List<Map<String, String>> _availableTones = [
    {'title': 'Default', 'uri': 'default'},
  ];
  bool _isPreviewing = false;
  Timer? _previewTimer;

  final _labelController = TextEditingController();
  bool _isEditing = false;

  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadTones();
    if (widget.editAlarmId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAlarm());
    } else {
      _repeatDays = [DateTime.now().weekday - 1];
    }
  }

  Future<void> _loadTones() async {
    try {
      final tones = await AlarmNativeService.getAvailableTones();
      if (mounted) {
        setState(() => _availableTones = tones);
      }
    } catch (_) {}
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
      _tone = alarm.tone;
    });
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    AlarmNativeService.stopAlarmSound();
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
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
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
                        const SizedBox(height: 28),
                        _buildCard(
                          children: [
                            _buildSectionHeader('Label'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _labelController,
                              onChanged: (v) => _label = v,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. Wake up, Meeting...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCard(
                          children: [
                            _buildSectionHeader('Repeat'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(7, (index) {
                                final isSelected = _repeatDays.contains(index);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _repeatDays.remove(index);
                                      } else {
                                        _repeatDays.add(index);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.accent
                                          : Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.accent
                                            : Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _days[index].substring(0, 2),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.7,
                                                ),
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCard(
                          children: [
                            _buildSectionHeader('Alarm Tone'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButton<String>(
                                      value:
                                          _availableTones.any(
                                            (t) => t['uri'] == _tone,
                                          )
                                          ? _tone
                                          : 'default',
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF1a1a2e),
                                      underline: const SizedBox.shrink(),
                                      icon: Icon(
                                        Icons.music_note_rounded,
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      items: _availableTones.map((t) {
                                        final uri = t['uri'] ?? 'default';
                                        final title = t['title'] ?? 'Unknown';
                                        return DropdownMenuItem<String>(
                                          value: uri,
                                          child: Text(
                                            title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (v) => setState(
                                        () => _tone = v ?? 'default',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                GestureDetector(
                                  onTap: _previewTone,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      _isPreviewing
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                      color: AppColors.accent,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCard(
                          children: [
                            _buildSectionHeader('Dismiss Type'),
                            const SizedBox(height: 4),
                            _buildDismissOption(
                              'button',
                              'Button',
                              'Simple dismiss button',
                              Icons.touch_app_rounded,
                            ),
                            _buildDismissOption(
                              'math',
                              'Math Problem',
                              'Solve to dismiss',
                              Icons.calculate_rounded,
                            ),
                            if (_dismissType == 'math') ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    'Difficulty: ',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: AppColors.accent,
                                        inactiveTrackColor: Colors.white
                                            .withValues(alpha: 0.15),
                                        thumbColor: AppColors.accent,
                                        overlayColor: AppColors.accent
                                            .withValues(alpha: 0.2),
                                      ),
                                      child: Slider(
                                        value: _mathDifficulty.toDouble(),
                                        min: 1,
                                        max: 3,
                                        divisions: 2,
                                        label: _mathDifficulty == 1
                                            ? 'Easy'
                                            : _mathDifficulty == 2
                                            ? 'Medium'
                                            : 'Hard',
                                        onChanged: (v) => setState(
                                          () => _mathDifficulty = v.round(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _mathDifficulty == 1
                                        ? 'Easy'
                                        : _mathDifficulty == 2
                                        ? 'Medium'
                                        : 'Hard',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCard(
                          children: [
                            _buildSectionHeader('Options'),
                            const SizedBox(height: 4),
                            _buildToggleRow(
                              Icons.vibration_rounded,
                              'Vibrate',
                              _vibrate,
                              (v) => setState(() => _vibrate = v),
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.snooze_rounded,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Snooze',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: DropdownButton<int>(
                                      value: _snoozeMinutes,
                                      dropdownColor: const Color(0xFF1a1a2e),
                                      underline: const SizedBox.shrink(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      items: [5, 10, 15, 20, 30].map((m) {
                                        return DropdownMenuItem(
                                          value: m,
                                          child: Text('$m min'),
                                        );
                                      }).toList(),
                                      onChanged: (v) => setState(
                                        () => _snoozeMinutes = v ?? 5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.5),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildDismissOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _dismissType == value;
    return GestureDetector(
      onTap: () => setState(() => _dismissType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.accent
                    : Colors.white.withValues(alpha: 0.4),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: isSelected ? AppColors.accent : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  Future<void> _previewTone() async {
    if (_isPreviewing) {
      _previewTimer?.cancel();
      await AlarmNativeService.stopAlarmSound();
      if (mounted) setState(() => _isPreviewing = false);
      return;
    }

    setState(() => _isPreviewing = true);

    final previewId = 'preview_${DateTime.now().millisecondsSinceEpoch}';
    await AlarmNativeService.scheduleAlarm(
      alarmId: previewId,
      triggerTime: DateTime.now().add(const Duration(seconds: 1)),
      label: 'Tone Preview',
      tone: _tone,
      vibrate: false,
      dismissType: 'button',
      mathDifficulty: 1,
    );

    _previewTimer = Timer(const Duration(seconds: 4), () async {
      await AlarmNativeService.stopAlarmSound();
      await AlarmNativeService.cancelAlarm(previewId);
      if (mounted) setState(() => _isPreviewing = false);
    });
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
      alarm.tone = _tone;
      success = await notifier.updateAlarm(alarm);
    } else {
      success = await notifier.createAlarm(
        hour: _hour,
        minute: _minute,
        label: _label,
        repeatDays: _repeatDays,
        tone: _tone,
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
