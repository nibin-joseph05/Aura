import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../providers/daily_activity_provider.dart';
import '../screens/daily_activity_screen.dart';

class DailyActivityTrackerWidget extends ConsumerStatefulWidget {
  const DailyActivityTrackerWidget({super.key});

  @override
  ConsumerState<DailyActivityTrackerWidget> createState() =>
      _DailyActivityTrackerWidgetState();
}

class _DailyActivityTrackerWidgetState
    extends ConsumerState<DailyActivityTrackerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyActivityProvider.notifier).loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final state = ref.watch(dailyActivityProvider);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DailyActivityScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.space(20)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.track_changes_rounded,
                      color: AppColors.accent,
                      size: responsive.icon(24),
                    ),
                    SizedBox(width: responsive.space(10)),
                    Text(
                      'Daily Activity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.text(18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                _buildSyncIndicator(state, responsive),
              ],
            ),
            SizedBox(height: responsive.space(16)),
            if (state.isLoading)
              _buildLoadingState(responsive)
            else
              _buildActivitySummary(state, responsive),
            SizedBox(height: responsive.space(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tap to view all activities',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: responsive.text(12),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: responsive.icon(14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncIndicator(DailyActivityState state, Responsive responsive) {
    if (state.isSyncing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: responsive.icon(14),
            height: responsive.icon(14),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                AppColors.accent.withValues(alpha: 0.8),
              ),
            ),
          ),
          SizedBox(width: responsive.space(6)),
          Text(
            'Syncing...',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: responsive.text(11),
            ),
          ),
        ],
      );
    }

    if (state.pendingSyncCount > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: AppColors.warning,
            size: responsive.icon(16),
          ),
          SizedBox(width: responsive.space(4)),
          Text(
            '${state.pendingSyncCount} pending',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: responsive.text(11),
            ),
          ),
        ],
      );
    }

    return Icon(
      Icons.cloud_done_rounded,
      color: AppColors.success,
      size: responsive.icon(18),
    );
  }

  Widget _buildLoadingState(Responsive responsive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: responsive.space(10)),
        child: SizedBox(
          width: responsive.icon(24),
          height: responsive.icon(24),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySummary(
    DailyActivityState state,
    Responsive responsive,
  ) {
    final completed = state.todayActivities
        .where((a) => a.completedAt != null)
        .length;
    final total = state.todayActivities.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatItem(
              icon: Icons.check_circle_outline_rounded,
              label: 'Done',
              value: '$completed',
              color: AppColors.success,
              responsive: responsive,
            ),
            SizedBox(width: responsive.space(20)),
            _buildStatItem(
              icon: Icons.pending_outlined,
              label: 'Pending',
              value: '${total - completed}',
              color: AppColors.warning,
              responsive: responsive,
            ),
            SizedBox(width: responsive.space(20)),
            _buildStatItem(
              icon: Icons.list_alt_rounded,
              label: 'Total',
              value: '$total',
              color: AppColors.info,
              responsive: responsive,
            ),
          ],
        ),
        if (total > 0) ...[
          SizedBox(height: responsive.space(14)),
          ClipRRect(
            borderRadius: BorderRadius.circular(responsive.radius(4)),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
              minHeight: responsive.space(5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Responsive responsive,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: responsive.icon(18)),
        SizedBox(width: responsive.space(6)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.text(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: responsive.text(10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
