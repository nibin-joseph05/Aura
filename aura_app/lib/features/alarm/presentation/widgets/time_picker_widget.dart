import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TimePickerWidget extends StatefulWidget {
  final int hour; 
  final int minute; 
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const TimePickerWidget({
    super.key,
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late bool _isPm;
  late int _display12Hour;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _isPm = widget.hour >= 12;
    _display12Hour = _to12(widget.hour);
    _hourController = FixedExtentScrollController(
      initialItem: _display12Hour - 1,
    );
    _minuteController = FixedExtentScrollController(initialItem: widget.minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int _to12(int h24) {
    if (h24 == 0) return 12;
    if (h24 > 12) return h24 - 12;
    return h24;
  }

  int _to24(int h12, bool pm) {
    if (pm) {
      return h12 == 12 ? 12 : h12 + 12;
    } else {
      return h12 == 12 ? 0 : h12;
    }
  }

  void _onHour12Changed(int index) {
    final h12 = index + 1; 
    _display12Hour = h12;
    widget.onHourChanged(_to24(h12, _isPm));
  }

  void _toggleAmPm() {
    setState(() {
      _isPm = !_isPm;
    });
    widget.onHourChanged(_to24(_display12Hour, _isPm));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 180,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 56,
              perspective: 0.003,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              controller: _hourController,
              onSelectedItemChanged: _onHour12Changed,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 12,
                builder: (context, index) {
                  final h = index + 1;
                  final isSelected = h == _display12Hour;
                  return _buildWheelItem(
                    h.toString().padLeft(2, '0'),
                    isSelected,
                  );
                },
              ),
            ),
          ),
         
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        
          SizedBox(
            width: 80,
            height: 180,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 56,
              perspective: 0.003,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              controller: _minuteController,
              onSelectedItemChanged: widget.onMinuteChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 60,
                builder: (context, index) {
                  final isSelected = index == widget.minute;
                  return _buildWheelItem(
                    index.toString().padLeft(2, '0'),
                    isSelected,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAmPmButton('AM', !_isPm),
              const SizedBox(height: 8),
              _buildAmPmButton('PM', _isPm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWheelItem(String text, bool isSelected) {
    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: isSelected ? 38 : 22,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.35),
          fontFamily: 'monospace',
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildAmPmButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if ((label == 'AM' && _isPm) || (label == 'PM' && !_isPm)) {
          _toggleAmPm();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
