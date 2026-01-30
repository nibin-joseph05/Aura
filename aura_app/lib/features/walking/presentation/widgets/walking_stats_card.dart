import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../data/model/walking_session_model.dart';

class WalkingStatsCard extends StatelessWidget {
  final List<WalkingSessionModel> sessions;

  const WalkingStatsCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalDistance = sessions.fold<double>(
      0.0,
      (sum, s) => sum + s.distanceMeters,
    );
    final totalDuration = sessions.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );
    final totalCalories = sessions.fold<double>(
      0.0,
      (sum, s) => sum + s.caloriesBurned,
    );

    return Container(
      padding: EdgeInsets.all(responsive.space(4)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: responsive.space(3)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.route,
                  label: 'Distance',
                  value: _formatDistance(totalDistance),
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.timer,
                  label: 'Duration',
                  value: _formatDuration(totalDuration),
                  color: AppColors.accent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: '${totalCalories.toInt()}',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
