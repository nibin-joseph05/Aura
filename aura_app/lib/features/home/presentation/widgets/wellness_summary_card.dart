import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/responsive/responsive.dart';
import '../../../daily_activity/presentation/providers/daily_activity_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';

class WellnessSummaryCard extends ConsumerStatefulWidget {
  const WellnessSummaryCard({super.key});

  @override
  ConsumerState<WellnessSummaryCard> createState() =>
      _WellnessSummaryCardState();
}

class _WellnessSummaryCardState extends ConsumerState<WellnessSummaryCard>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _ringAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _ringAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ringController.forward();
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '✨';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final user = ref.watch(userProvider).user;
    final firstName = user?.name?.split(' ').first ?? 'User';
    final activityState = ref.watch(dailyActivityProvider);
    final completed = activityState.todayActivities
        .where((a) => a.completedAt != null)
        .length;
    final total = activityState.todayActivities.length;
    final percentage = total > 0 ? (completed / total) : 0.0;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _ringAnimation,
        _pulseAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(responsive.w(5)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF0A237A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment(_shimmerAnimation.value - 1, 0),
                    end: Alignment(_shimmerAnimation.value, 0),
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getGreetingEmoji(),
                                        style: TextStyle(
                                          fontSize: responsive.isTablet
                                              ? 13
                                              : 11,
                                        ),
                                      ),
                                      SizedBox(width: responsive.w(1)),
                                      Text(
                                        _getGreeting(),
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: responsive.isTablet
                                              ? 12
                                              : 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsive.h(0.8)),
                            Text(
                              firstName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: responsive.h(0.4)),
                            Text(
                              'Your wellness journey today',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: responsive.isTablet ? 13 : 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: responsive.w(4)),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: SizedBox(
                          width: responsive.isTablet ? 90 : 74,
                          height: responsive.isTablet ? 90 : 74,
                          child: CustomPaint(
                            painter: _WellnessRingPainter(
                              progress:
                                  _ringAnimation.value *
                                  (percentage == 0
                                      ? 0
                                      : percentage.clamp(0.0, 1.0).toDouble()),
                              trackColor: Colors.white.withValues(alpha: 0.15),
                              progressColor: const Color(0xFF00E5FF),
                              glowColor: const Color(0xFF00E5FF),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${((_ringAnimation.value * (percentage == 0 ? 0 : percentage)) * 100).round()}%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: responsive.isTablet ? 18 : 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Done',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: responsive.isTablet ? 9 : 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.h(2.5)),
                  Row(
                    children: [
                      _buildStatChip(
                        responsive: responsive,
                        icon: Icons.local_fire_department_rounded,
                        value: '$completed',
                        label: 'Completed',
                        color: Colors.orangeAccent,
                      ),
                      SizedBox(width: responsive.w(2.5)),
                      _buildStatChip(
                        responsive: responsive,
                        icon: Icons.emoji_events_rounded,
                        value: '$total',
                        label: 'Activities',
                        color: Colors.amber,
                      ),
                      SizedBox(width: responsive.w(2.5)),
                      _buildStatChip(
                        responsive: responsive,
                        icon: Icons.favorite_rounded,
                        value: total > 0
                            ? '${(percentage * 100).round()}%'
                            : '0%',
                        label: 'Wellness',
                        color: const Color(0xFFFF4081),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip({
    required Responsive responsive,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: responsive.h(1.2),
          horizontal: responsive.w(1.5),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: responsive.isTablet ? 22 : 18),
            SizedBox(height: responsive.h(0.3)),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white54,
                fontSize: responsive.isTablet ? 10 : 8.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;

  _WellnessRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeWidth = 7.0;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.35)
        ..strokeWidth = strokeWidth + 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        glowPaint,
      );

      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [progressColor, const Color(0xFF00B0FF)],
          startAngle: startAngle,
          endAngle: startAngle + 2 * math.pi * progress,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WellnessRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
