import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/model/alarm_model.dart';

class AlarmCard extends StatelessWidget {
  final AlarmModel alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.timeString,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        color: alarm.isEnabled
                            ? (isDark ? Colors.white : AppColors.textPrimary)
                            : (isDark ? Colors.grey : Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (alarm.label.isNotEmpty) ...[
                          Text(
                            alarm.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          alarm.repeatLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[600] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (alarm.hasMathDismiss) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Math dismiss',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: alarm.isEnabled,
                onChanged: onToggle,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
