import 'package:flutter/material.dart';

import '../../../../core/ui/responsive/responsive.dart';

class DailyInsightCard extends StatefulWidget {
  const DailyInsightCard({super.key});

  @override
  State<DailyInsightCard> createState() => _DailyInsightCardState();
}

class _DailyInsightCardState extends State<DailyInsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmer;

  static const _insights = [
    _Insight(
      '💧',
      'Drink more water',
      'Hydration boosts focus and mood by up to 30%.',
      [Color(0xFF00B4DB), Color(0xFF0083B0)],
    ),
    _Insight(
      '🧠',
      'Rest is productive',
      '7–9 hours of sleep rewires your brain for peak performance.',
      [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    _Insight(
      '🌿',
      'Take a breath',
      '5 deep breaths can reduce cortisol and calm your nervous system.',
      [Color(0xFF11998E), Color(0xFF38EF7D)],
    ),
    _Insight(
      '☀️',
      'Morning light heals',
      '10 minutes of sunlight resets your circadian rhythm for the day.',
      [Color(0xFFF7971E), Color(0xFFFFD200)],
    ),
    _Insight(
      '🏃',
      'Move your body',
      'Even a 20-min walk releases endorphins and reduces anxiety.',
      [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    ),
    _Insight(
      '🎯',
      'One small win',
      'Focus on a single achievable goal — progress fuels motivation.',
      [Color(0xFF2196F3), Color(0xFF00BCD4)],
    ),
  ];

  late _Insight _todayInsight;

  @override
  void initState() {
    super.initState();
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    _todayInsight = _insights[dayOfYear % _insights.length];

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        return Container(
          padding: EdgeInsets.all(responsive.w(4.5)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _todayInsight.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _todayInsight.colors[0].withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -16,
                bottom: -16,
                child: Text(
                  _todayInsight.emoji,
                  style: TextStyle(fontSize: responsive.isTablet ? 72 : 58),
                ),
              ),
              ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment(_shimmer.value - 0.8, 0),
                  end: Alignment(_shimmer.value, 0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ).createShader(rect),
                blendMode: BlendMode.srcATop,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Daily Insight',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.isTablet ? 11 : 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.h(1)),
                  Text(
                    _todayInsight.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.isTablet ? 20 : 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.h(0.5)),
                  SizedBox(
                    width: responsive.w(60),
                    child: Text(
                      _todayInsight.body,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: responsive.isTablet ? 13 : 11.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Insight {
  final String emoji;
  final String title;
  final String body;
  final List<Color> colors;

  const _Insight(this.emoji, this.title, this.body, this.colors);
}
