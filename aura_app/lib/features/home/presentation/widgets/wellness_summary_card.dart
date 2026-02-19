import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/responsive/responsive.dart';
import '../../../daily_activity/presentation/providers/daily_activity_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';

class WellnessSummaryCard extends ConsumerWidget {
  const WellnessSummaryCard({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final user = ref.watch(userProvider).user;
    final firstName = user?.name?.split(' ').first ?? 'User';
    final activityState = ref.watch(dailyActivityProvider);
    final completed = activityState.todayActivities
        .where((a) => a.completedAt != null)
        .length;
    final total = activityState.todayActivities.length;
    final percentage = total > 0 ? ((completed / total) * 100).round() : 0;

    return Container(
      padding: EdgeInsets.all(responsive.w(5)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}, $firstName! 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.isTablet ? 22 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.h(0.5)),
          Text(
            'Here\'s your wellness overview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: responsive.isTablet ? 14 : 12,
            ),
          ),
          SizedBox(height: responsive.h(2)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  responsive,
                  icon: Icons.local_fire_department,
                  value: '$completed',
                  label: 'Done Today',
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: responsive.w(3)),
              Expanded(
                child: _buildStatItem(
                  responsive,
                  icon: Icons.favorite,
                  value: '$percentage%',
                  label: 'Wellness',
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(width: responsive.w(3)),
              Expanded(
                child: _buildStatItem(
                  responsive,
                  icon: Icons.directions_run,
                  value: '$total',
                  label: 'Activities',
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    Responsive responsive, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: responsive.h(1.5),
        horizontal: responsive.w(2),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: responsive.isTablet ? 28 : 24),
          SizedBox(height: responsive.h(0.5)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white54,
              fontSize: responsive.isTablet ? 11 : 10,
            ),
          ),
        ],
      ),
    );
  }
}
