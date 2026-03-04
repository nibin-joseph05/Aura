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
      'Stay Hydrated',
      'Drinking 8 glasses of water daily boosts your focus, energy, and mood by up to 30%.',
      [Color(0xFF00B4DB), Color(0xFF0083B0)],
    ),
    _Insight(
      '🧠',
      'Sleep to Succeed',
      '7–9 hours of quality sleep rewires your brain for peak daily performance.',
      [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    _Insight(
      '🌿',
      'Take a Breath',
      '5 slow deep breaths reduce cortisol and calm your nervous system instantly.',
      [Color(0xFF11998E), Color(0xFF38EF7D)],
    ),
    _Insight(
      '☀️',
      'Morning Light',
      '10 minutes of morning sunlight resets your circadian rhythm for the whole day.',
      [Color(0xFFF7971E), Color(0xFFFFD200)],
    ),
    _Insight(
      '🏃',
      'Move Daily',
      'A 20-minute walk releases endorphins, reduces anxiety, and sharpens focus.',
      [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    ),
    _Insight(
      '🎯',
      'One Small Win',
      'Focus on one achievable goal today — steady progress fuels lasting motivation.',
      [Color(0xFF2196F3), Color(0xFF00BCD4)],
    ),
    _Insight(
      '🧘',
      'Mindful Moment',
      'Five minutes of mindfulness daily reduces stress and improves emotional balance.',
      [Color(0xFF9333EA), Color(0xFFDB2777)],
    ),
    _Insight(
      '🥦',
      'Eat the Rainbow',
      'Colorful vegetables provide diverse antioxidants that protect your cells and brain.',
      [Color(0xFF059669), Color(0xFF10B981)],
    ),
    _Insight(
      '📵',
      'Screen Detox',
      'A 30-minute phone-free break each day reduces eye strain and mental fatigue.',
      [Color(0xFF374151), Color(0xFF6B7280)],
    ),
    _Insight(
      '🎵',
      'Mood Music',
      'Listening to music you love triggers dopamine, elevating your mood within seconds.',
      [Color(0xFFEC4899), Color(0xFFF97316)],
    ),
    _Insight(
      '🤝',
      'Connect Today',
      'One genuine conversation with a friend can significantly reduce feelings of loneliness.',
      [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
    ),
    _Insight(
      '✍️',
      'Journal It',
      'Writing 3 things you are grateful for daily rewires your brain toward positivity.',
      [Color(0xFFD97706), Color(0xFFF59E0B)],
    ),
    _Insight(
      '🌙',
      'Wind Down',
      'A consistent bedtime routine signals your brain to prepare for restorative sleep.',
      [Color(0xFF1E3A5F), Color(0xFF2563EB)],
    ),
    _Insight(
      '💪',
      'Strength Builds',
      'Regular strength training not only builds muscle but also improves bone density and mood.',
      [Color(0xFFDC2626), Color(0xFFEF4444)],
    ),
    _Insight(
      '🌱',
      'Progress Not Perfection',
      'Growth comes from small daily improvements, not from waiting to be perfect.',
      [Color(0xFF16A34A), Color(0xFF4ADE80)],
    ),
    _Insight(
      '🫀',
      'Heart Health',
      'Thirty minutes of moderate activity most days dramatically lowers heart disease risk.',
      [Color(0xFFE11D48), Color(0xFFFB7185)],
    ),
    _Insight(
      '👁️',
      'Eye Rest',
      'Every 20 minutes, look at something 20 feet away for 20 seconds to protect your eyes.',
      [Color(0xFF0284C7), Color(0xFF38BDF8)],
    ),
    _Insight(
      '🧊',
      'Cold Exposure',
      'Brief cold showers boost alertness, sharpen focus, and increase resilience over time.',
      [Color(0xFF0E7490), Color(0xFF22D3EE)],
    ),
    _Insight(
      '🍵',
      'Herbal Calm',
      'Chamomile or lavender tea before bed lowers anxiety and prepares you for deep sleep.',
      [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    ),
    _Insight(
      '🦋',
      'Embrace Change',
      'Psychological flexibility — accepting change — is one of the strongest predictors of wellbeing.',
      [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ),
    _Insight(
      '🌊',
      'Flow State',
      'Doing activities that fully absorb you creates flow, reducing stress and boosting happiness.',
      [Color(0xFF0369A1), Color(0xFF06B6D4)],
    ),
    _Insight(
      '🧴',
      'Skin & Wellness',
      'Staying hydrated and moisturizing reduces inflammation signals that affect your whole body.',
      [Color(0xFFBE185D), Color(0xFFF472B6)],
    ),
    _Insight(
      '🏕️',
      'Nature Resets',
      'Even 20 minutes in a park lowers cortisol and improves attention and creativity.',
      [Color(0xFF166534), Color(0xFF22C55E)],
    ),
    _Insight(
      '🤲',
      'Acts of Kindness',
      'Helping others releases oxytocin in you too, measurably improving your own mood.',
      [Color(0xFFFB923C), Color(0xFFFDE68A)],
    ),
    _Insight(
      '💤',
      'Nap Smart',
      'A 20-minute power nap boosts alertness and performance without causing grogginess.',
      [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
    ),
    _Insight(
      '🏊',
      'Swim & Stretch',
      'Swimming works all major muscle groups and also has powerful stress-relief benefits.',
      [Color(0xFF0891B2), Color(0xFF67E8F9)],
    ),
    _Insight(
      '🍎',
      'Apple a Day',
      'Quercetin and fiber in apples support gut health, which directly impacts mental health.',
      [Color(0xFFB91C1C), Color(0xFFF87171)],
    ),
    _Insight(
      '🧩',
      'Challenge Your Brain',
      'Puzzles, reading, and learning new skills build cognitive reserve and delay mental aging.',
      [Color(0xFF7E22CE), Color(0xFFC084FC)],
    ),
    _Insight(
      '🌅',
      'Start Intentionally',
      'The first 10 minutes of your day set the tone. Start calm, not with a phone scroll.',
      [Color(0xFFD97706), Color(0xFFFCA5A5)],
    ),
    _Insight(
      '🩺',
      'Preventive Care',
      'Regular health checkups catch issues early — investing in prevention saves years of life.',
      [Color(0xFF065F46), Color(0xFF6EE7B7)],
    ),
  ];

  late _Insight _todayInsight;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
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
