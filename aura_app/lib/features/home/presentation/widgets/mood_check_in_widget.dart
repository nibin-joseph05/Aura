import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/ui/responsive/responsive.dart';

class MoodCheckInWidget extends StatefulWidget {
  const MoodCheckInWidget({super.key});

  @override
  State<MoodCheckInWidget> createState() => _MoodCheckInWidgetState();
}

class _MoodCheckInWidgetState extends State<MoodCheckInWidget>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  late AnimationController _popController;

  static const _moods = [
    _Mood('😔', 'Rough', Color(0xFF6B7280)),
    _Mood('😐', 'Meh', Color(0xFFF59E0B)),
    _Mood('🙂', 'Okay', Color(0xFF10B981)),
    _Mood('😊', 'Good', Color(0xFF3B82F6)),
    _Mood('🤩', 'Amazing', Color(0xFF8B5CF6)),
  ];

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _selectMood(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
    _popController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Container(
      padding: EdgeInsets.all(responsive.w(4.5)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'How are you feeling?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_selectedIndex != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _moods[_selectedIndex!].color.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _moods[_selectedIndex!].label,
                      style: TextStyle(
                        color: _moods[_selectedIndex!].color,
                        fontSize: responsive.isTablet ? 12 : 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: responsive.h(1.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_moods.length, (i) {
              final isSelected = _selectedIndex == i;
              return GestureDetector(
                onTap: () => _selectMood(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  width: responsive.isTablet ? 62 : 52,
                  height: responsive.isTablet ? 62 : 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _moods[i].color.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? _moods[i].color.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _moods[i].color.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _moods[i].emoji,
                        style: TextStyle(
                          fontSize: isSelected
                              ? (responsive.isTablet ? 26 : 22)
                              : (responsive.isTablet ? 22 : 18),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _moods[i].label,
                        style: TextStyle(
                          color: isSelected ? _moods[i].color : Colors.white38,
                          fontSize: responsive.isTablet ? 9 : 8,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Mood {
  final String emoji;
  final String label;
  final Color color;
  const _Mood(this.emoji, this.label, this.color);
}
