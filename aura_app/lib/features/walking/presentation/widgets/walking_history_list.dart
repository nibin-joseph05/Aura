import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../data/model/walking_session_model.dart';
import 'route_visualization.dart';

class WalkingHistoryList extends StatelessWidget {
  final List<WalkingSessionModel> sessions;

  const WalkingHistoryList({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (sessions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(responsive.space(6)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.directions_walk,
              size: 48,
              color: isDark ? Colors.grey : AppColors.textSecondary,
            ),
            SizedBox(height: responsive.space(3)),
            Text(
              'No walking sessions yet',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: responsive.space(1)),
            Text(
              'Start walking to track your progress',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(responsive.space(4)),
            child: Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessions.take(5).length,
            separatorBuilder: (_, __) => Divider(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              height: 1,
            ),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionTile(context, session, responsive);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(
    BuildContext context,
    WalkingSessionModel session,
    Responsive responsive,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsive.space(4),
            vertical: responsive.space(2),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_walk, color: AppColors.success),
          ),
          title: Text(
            _formatDate(session.startTime),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${_formatDistance(session.distanceMeters)} • ${_formatDuration(session.durationSeconds)}',
            style: TextStyle(
              color: isDark ? Colors.grey : AppColors.textSecondary,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.caloriesBurned.toInt()} cal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        if (session.routePoints.length >= 2)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.space(4),
            ).copyWith(bottom: responsive.space(3)),
            child: RouteVisualization(
              routePoints: session.routePoints,
              height: 120,
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
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
