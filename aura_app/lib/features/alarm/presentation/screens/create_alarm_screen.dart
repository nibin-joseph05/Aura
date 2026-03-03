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
  String _toneName = 'Default';
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
        setState(() {
          _availableTones = tones;
          final match = _availableTones.firstWhere(
            (t) => t['uri'] == _tone,
            orElse: () => {'title': 'Default', 'uri': 'default'},
          );
          _toneName = match['title'] ?? 'Default';
        });
      }
    } catch (_) {}
  }

  void _loadAlarm() {
    final state = ref.read(alarmProvider);
    final alarmIndex = state.alarms.indexWhere(
      (a) => a.id == widget.editAlarmId,
    );
    if (alarmIndex == -1) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final alarm = state.alarms[alarmIndex];
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
      final toneEntry = _availableTones.firstWhere(
        (t) => t['uri'] == alarm.tone,
        orElse: () => {'title': 'Default', 'uri': 'default'},
      );
      _toneName = toneEntry['title'] ?? 'Default';
    });
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    if (_isPreviewing) AlarmNativeService.stopAlarmSound();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient(Theme.of(context).brightness),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TimePickerWidget(
                          hour: _hour,
                          minute: _minute,
                          onHourChanged: (h) => setState(() => _hour = h),
                          onMinuteChanged: (m) => setState(() => _minute = m),
                        ),
                        const SizedBox(height: 20),
                        _buildCard(
                          icon: Icons.label_outline_rounded,
                          title: 'Label',
                          brightness: brightness,
                          children: [
                            const SizedBox(height: 10),
                            TextField(
                              controller: _labelController,
                              onChanged: (v) => _label = v,
                              style: TextStyle(
                                color: AppColors.onSurface(brightness),
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. Wake up, Meeting...',
                                hintStyle: TextStyle(
                                  color: AppColors.onSurfaceFaint(brightness),
                                ),
                                filled: true,
                                fillColor: AppColors.inputFill(brightness),
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
                        const SizedBox(height: 14),
                        _buildCard(
                          icon: Icons.repeat_rounded,
                          title: 'Repeat',
                          brightness: brightness,
                          children: [
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.accent
                                          : AppColors.iconButtonFill(
                                              brightness,
                                            ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.accent
                                            : AppColors.iconButtonBorder(
                                                brightness,
                                              ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _days[index].substring(0, 1),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.onSurfaceFaint(
                                                  brightness,
                                                ),
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_repeatDays.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _buildRepeatSummary(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accent.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildCard(
                          icon: Icons.music_note_rounded,
                          title: 'Alarm Tone',
                          brightness: brightness,
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.containerFill(brightness),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.containerBorder(brightness),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.music_note_rounded,
                                    color: AppColors.accent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _toneName,
                                      style: TextStyle(
                                        color: AppColors.onSurface(brightness),
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildToneButton(
                                    icon: Icons.tune_rounded,
                                    label: 'System Tones',
                                    onTap: _showSystemTonePicker,
                                    brightness: brightness,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildToneButton(
                                    icon: Icons.folder_open_rounded,
                                    label: 'Custom Tone',
                                    onTap: _pickCustomTone,
                                    brightness: brightness,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _previewTone,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _isPreviewing
                                          ? AppColors.accent
                                          : AppColors.accent.withValues(
                                              alpha: 0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      _isPreviewing
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                      color: _isPreviewing
                                          ? Colors.white
                                          : AppColors.accent,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildCard(
                          icon: Icons.lock_clock_rounded,
                          title: 'Dismiss Method',
                          brightness: brightness,
                          children: [
                            const SizedBox(height: 6),
                            _buildDismissOption(
                              'button',
                              'Button Dismiss',
                              'Simple one-tap dismiss',
                              Icons.touch_app_rounded,
                              brightness,
                            ),
                            _buildDismissOption(
                              'math',
                              'Math Challenge',
                              'Solve a problem to dismiss',
                              Icons.calculate_rounded,
                              brightness,
                            ),
                            if (_dismissType == 'math') ...[
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Text(
                                    'Difficulty',
                                    style: TextStyle(
                                      color: AppColors.onSurfaceMuted(
                                        brightness,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  ...[
                                    'Easy',
                                    'Medium',
                                    'Hard',
                                  ].asMap().entries.map((e) {
                                    final isActive =
                                        _mathDifficulty == e.key + 1;
                                    return GestureDetector(
                                      onTap: () => setState(
                                        () => _mathDifficulty = e.key + 1,
                                      ),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppColors.accent
                                              : AppColors.iconButtonFill(
                                                  brightness,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          e.value,
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.white
                                                : AppColors.onSurfaceFaint(
                                                    brightness,
                                                  ),
                                            fontSize: 12,
                                            fontWeight: isActive
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildCard(
                          icon: Icons.tune_rounded,
                          title: 'Options',
                          brightness: brightness,
                          children: [
                            _buildToggleRow(
                              Icons.vibration_rounded,
                              'Vibrate',
                              _vibrate,
                              (v) => setState(() => _vibrate = v),
                              brightness,
                            ),
                            Divider(
                              color: AppColors.dividerColor(brightness),
                              height: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.snooze_rounded,
                                    color: AppColors.onSurfaceMuted(brightness),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Snooze duration',
                                    style: TextStyle(
                                      color: AppColors.onSurface(brightness),
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
                                      color: AppColors.inputFill(brightness),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: DropdownButton<int>(
                                      value: _snoozeMinutes,
                                      dropdownColor:
                                          brightness == Brightness.dark
                                          ? const Color(0xFF1a1a2e)
                                          : Colors.white,
                                      underline: const SizedBox.shrink(),
                                      style: TextStyle(
                                        color: AppColors.onSurface(brightness),
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Brightness brightness = Brightness.dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.containerBorder(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceFaint(brightness),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToneButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Brightness brightness = Brightness.dark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.iconButtonFill(brightness),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.iconButtonBorder(brightness)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.onSurfaceMuted(brightness), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissOption(
    String value,
    String title,
    String subtitle,
    IconData icon, [
    Brightness brightness = Brightness.dark,
  ]) {
    final isSelected = _dismissType == value;
    return GestureDetector(
      onTap: () => setState(() => _dismissType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.iconButtonFill(brightness),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.onSurfaceFaint(brightness),
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
                      color: AppColors.onSurface(brightness),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.onSurfaceFaint(brightness),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.containerBorder(brightness),
                  width: 2,
                ),
                color: isSelected ? AppColors.accent : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
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
    ValueChanged<bool> onChanged, [
    Brightness brightness = Brightness.dark,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onSurfaceMuted(brightness), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.onSurface(brightness),
                fontSize: 15,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
            inactiveTrackColor: AppColors.iconButtonFill(brightness),
          ),
        ],
      ),
    );
  }

  String _buildRepeatSummary() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (_repeatDays.length == 7) return 'Every day';
    if (_repeatDays.length == 5 &&
        !_repeatDays.contains(5) &&
        !_repeatDays.contains(6)) {
      return 'Weekdays only';
    }
    if (_repeatDays.length == 2 &&
        _repeatDays.contains(5) &&
        _repeatDays.contains(6)) {
      return 'Weekends only';
    }
    final sorted = List<int>.from(_repeatDays)..sort();
    return sorted.map((d) => days[d]).join(', ');
  }

  void _showSystemTonePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Alarm Tone',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _availableTones.length,
              itemBuilder: (ctx, index) {
                final t = _availableTones[index];
                final isSelected = (t['uri'] ?? 'default') == _tone;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.music_note_rounded
                        : Icons.music_note_outlined,
                    color: isSelected
                        ? AppColors.accent
                        : Colors.white.withValues(alpha: 0.4),
                    size: 20,
                  ),
                  title: Text(
                    t['title'] ?? 'Unknown',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accent,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _tone = t['uri'] ?? 'default';
                      _toneName = t['title'] ?? 'Default';
                    });
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomTone() async {
    final uri = await AlarmNativeService.pickCustomRingtone();
    if (uri != null && mounted) {
      setState(() {
        _tone = uri;
        _toneName = 'Custom Tone';
      });
    }
  }

  Future<void> _previewTone() async {
    if (_isPreviewing) {
      _previewTimer?.cancel();
      await AlarmNativeService.stopAlarmSound();
      if (mounted) setState(() => _isPreviewing = false);
      return;
    }

    setState(() => _isPreviewing = true);
    await AlarmNativeService.playAlarmSound(_tone);

    _previewTimer = Timer(const Duration(seconds: 8), () async {
      await AlarmNativeService.stopAlarmSound();
      if (mounted) setState(() => _isPreviewing = false);
    });
  }

  Future<void> _saveAlarm() async {
    final notifier = ref.read(alarmProvider.notifier);
    bool success;

    if (_isEditing) {
      final state = ref.read(alarmProvider);
      final alarm = state.alarms.firstWhere(
        (a) => a.id == widget.editAlarmId,
        orElse: () =>
            state.alarms.first, // fallback; _loadAlarm already checked
      );
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
