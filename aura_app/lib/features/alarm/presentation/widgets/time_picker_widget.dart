import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TimePickerWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListWheelScrollView.useDelegate(
              itemExtent: 60,
              perspective: 0.005,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: hour),
              onSelectedItemChanged: onHourChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 24,
                builder: (context, index) {
                  final isSelected = index == hour;
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: isSelected ? 40 : 24,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.grey : Colors.grey[400]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              itemExtent: 60,
              perspective: 0.005,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: minute),
              onSelectedItemChanged: onMinuteChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 60,
                builder: (context, index) {
                  final isSelected = index == minute;
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: isSelected ? 40 : 24,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.grey : Colors.grey[400]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
