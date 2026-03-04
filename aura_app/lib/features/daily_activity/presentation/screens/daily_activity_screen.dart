import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/buttons/floating_action_btn.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/widgets/wrappers/app_bottom_sheet.dart';
import '../../data/models/user_activity_model.dart';
import '../providers/daily_activity_provider.dart';
import '../../../activity_types/state/activity_type_providers.dart';
import '../../../activity_types/data/models/activity_type.dart';
import '../../../activity_types/data/models/activity_metric.dart';
import 'package:permission_handler/permission_handler.dart';

final selectedActivityTypeProvider = StateProvider<ActivityType?>(
  (ref) => null,
);

class DailyActivityScreen extends ConsumerStatefulWidget {
  const DailyActivityScreen({super.key});

  @override
  ConsumerState<DailyActivityScreen> createState() =>
      _DailyActivityScreenState();
}

class _DailyActivityScreenState extends ConsumerState<DailyActivityScreen> {
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
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient(brightness),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Daily Activity',
                subtitle: _getFormattedDate(),
                actions: [_buildSyncButton(state, responsive)],
              ),
              _buildProgressCard(state, responsive, brightness),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref
                      .read(dailyActivityProvider.notifier)
                      .forceRefreshActivities(),
                  color: AppColors.accent,
                  child: state.isLoading
                      ? _buildLoadingState(brightness)
                      : state.todayActivities.isEmpty
                      ? _buildEmptyState(responsive, brightness)
                      : _buildActivityList(state, responsive, brightness),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionBtn(
          onPressed: () => _showAddActivitySheet(context),
          label: 'Add Activity',
        ),
      ),
    );
  }

  Widget _buildSyncButton(DailyActivityState state, Responsive responsive) {
    return GestureDetector(
      onTap:
          (state.pendingSyncCount > 0 || state.pendingLogCount > 0) &&
              !state.isSyncing
          ? () {
              ref.read(dailyActivityProvider.notifier).syncPendingActivities();
              ref.read(dailyActivityProvider.notifier).syncPendingLogs();
            }
          : null,
      child: state.isSyncing
          ? SizedBox(
              width: responsive.icon(20),
              height: responsive.icon(20),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.accent),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  (state.pendingSyncCount > 0 || state.pendingLogCount > 0)
                      ? Icons.cloud_sync_rounded
                      : Icons.cloud_done_rounded,
                  color:
                      (state.pendingSyncCount > 0 || state.pendingLogCount > 0)
                      ? AppColors.warning
                      : AppColors.success,
                  size: responsive.icon(20),
                ),
                if (state.pendingSyncCount > 0 ||
                    state.pendingLogCount > 0) ...[
                  SizedBox(width: responsive.space(4)),
                  Text(
                    '${state.pendingSyncCount + state.pendingLogCount}',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: responsive.text(12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildProgressCard(
    DailyActivityState state,
    Responsive responsive,
    Brightness brightness,
  ) {
    int totalTarget = 0;
    int totalDone = 0;
    for (final a in state.todayActivities) {
      totalTarget += a.targetCompletions;
      totalDone +=
          (a.isRepeating
                  ? a.completionTimes.length
                  : (a.completedAt != null ? 1 : 0))
              as int;
    }
    final progress = totalTarget > 0 ? totalDone / totalTarget : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.w(4)),
      padding: EdgeInsets.all(responsive.space(16)),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: AppColors.containerBorder(brightness)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: responsive.space(56),
            height: responsive.space(56),
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 5,
                  backgroundColor: AppColors.iconButtonFill(brightness),
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt().clamp(0, 100)}%',
                    style: TextStyle(
                      color: AppColors.onSurface(brightness),
                      fontSize: responsive.text(13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.space(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    color: AppColors.onSurface(brightness),
                    fontSize: responsive.text(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.space(4)),
                Text(
                  '$totalDone of $totalTarget completions',
                  style: TextStyle(
                    color: AppColors.onSurfaceMuted(brightness),
                    fontSize: responsive.text(13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Brightness brightness) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppColors.onSurface(brightness)),
      ),
    );
  }

  Widget _buildEmptyState(Responsive responsive, Brightness brightness) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(
                padding: responsive.horizontal(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.track_changes_rounded,
                      size: responsive.icon(56),
                      color: AppColors.accent,
                    ),
                    SizedBox(height: responsive.space(20)),
                    Text(
                      'No activities yet',
                      style: TextStyle(
                        color: AppColors.onSurface(brightness),
                        fontSize: responsive.text(20),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: responsive.space(8)),
                    Text(
                      'Start tracking your daily activities\nby adding your first one!\n\nPull down to refresh',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onSurfaceMuted(brightness),
                        fontSize: responsive.text(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityList(
    DailyActivityState state,
    Responsive responsive,
    Brightness brightness,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(4),
        vertical: responsive.space(16),
      ),
      itemCount: state.todayActivities.length,
      itemBuilder: (context, index) {
        final activity = state.todayActivities[index];
        return _buildActivityCard(activity, responsive, brightness);
      },
    );
  }

  Widget _buildActivityCard(
    UserActivityModel activity,
    Responsive responsive,
    Brightness brightness,
  ) {
    return _ActivityCard(
      key: ValueKey(activity.id),
      activity: activity,
      responsive: responsive,
      brightness: brightness,
      activityColor: _getActivityColor(activity.activityType),
      activityIcon: _getActivityIcon(activity.activityType),
      onComplete: () async {
        if (activity.metrics.isNotEmpty) {
          final metricValues = await AppBottomSheet.show<Map<String, String>>(
            context: context,
            title: 'Log ${activity.title}',
            child: _DynamicMetricsDialog(activity: activity),
          );
          if (metricValues == null) return;
          if (activity.isRepeating) {
            ref
                .read(dailyActivityProvider.notifier)
                .recordCompletion(activity.id, metricValues: metricValues);
          } else {
            ref
                .read(dailyActivityProvider.notifier)
                .completeActivity(activity.id, metricValues: metricValues);
          }
        } else {
          if (activity.isRepeating) {
            ref
                .read(dailyActivityProvider.notifier)
                .recordCompletion(activity.id);
          } else {
            ref
                .read(dailyActivityProvider.notifier)
                .completeActivity(activity.id);
          }
        }
      },
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'exercise':
        return Icons.fitness_center_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'reading':
        return Icons.menu_book_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'social':
        return Icons.people_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'exercise':
        return const Color(0xFFFF6B6B);
      case 'meditation':
        return const Color(0xFF9B59B6);
      case 'reading':
        return const Color(0xFF3498DB);
      case 'work':
        return const Color(0xFFF39C12);
      case 'health':
        return const Color(0xFF2ECC71);
      case 'social':
        return const Color(0xFFE91E63);
      default:
        return AppColors.accent;
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _showAddActivitySheet(BuildContext context) {
    ref.read(selectedActivityTypeProvider.notifier).state = null;
    AppBottomSheet.show(
      context: context,
      title: 'Add New Activity',
      child: _AddActivityContent(
        onAdd:
            (
              type,
              title,
              description,
              intervalMinutes,
              targetCompletions,
              isAlarmEnabled,
              isPushEnabled,
            ) {
              ref
                  .read(dailyActivityProvider.notifier)
                  .addActivity(
                    activityType: type.name,
                    activityTypeId: type.id,
                    title: title,
                    description: description,
                    intervalMinutes: intervalMinutes,
                    targetCompletions: targetCompletions,
                    isAlarmEnabled: isAlarmEnabled,
                    isPushEnabled: isPushEnabled,
                    metrics: type.metrics,
                  );
            },
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final UserActivityModel activity;
  final Responsive responsive;
  final Brightness brightness;
  final Color activityColor;
  final IconData activityIcon;
  final VoidCallback onComplete;

  const _ActivityCard({
    super.key,
    required this.activity,
    required this.responsive,
    required this.brightness,
    required this.activityColor,
    required this.activityIcon,
    required this.onComplete,
  });

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _isDueNow = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _recalc();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _recalc();
    });
  }

  void _recalc() {
    final activity = widget.activity;
    final now = DateTime.now();

    if (activity.isRepeating && activity.intervalMinutes != null) {
      final lastDone = activity.completionTimes.isNotEmpty
          ? activity.completionTimes.last
          : activity.date;
      final next = lastDone.add(Duration(minutes: activity.intervalMinutes!));
      final diff = next.difference(now);
      final due = !diff.isNegative;
      setState(() {
        _remaining = due ? diff : Duration.zero;
        _isDueNow = !due;
      });
    } else if (!activity.isRepeating && activity.completedAt == null) {
      final midnight = DateTime(now.year, now.month, now.day + 1);
      setState(() {
        _remaining = midnight.difference(now);
        _isDueNow = true;
      });
    } else {
      setState(() {
        _remaining = Duration.zero;
        _isDueNow = true;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    if (d == Duration.zero) return 'Due now!';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final r = widget.responsive;
    final br = widget.brightness;
    final color = widget.activityColor;

    final isCompleted = activity.isRepeating
        ? activity.isFullyCompleted
        : activity.completedAt != null;

    Color borderColor;
    if (isCompleted) {
      borderColor = AppColors.success.withValues(alpha: 0.35);
    } else if (_isDueNow) {
      borderColor = color.withValues(alpha: 0.55);
    } else {
      borderColor = AppColors.containerBorder(br);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: r.space(10)),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.06)
            : AppColors.containerFill(br),
        borderRadius: BorderRadius.circular(r.radius(14)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(r.radius(14)),
                bottom: isCompleted || (!_isDueNow && activity.isRepeating)
                    ? Radius.circular(r.radius(14))
                    : Radius.zero,
              ),
              onTap: isCompleted
                  ? null
                  : () {
                      if (activity.isRepeating && !_isDueNow) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.containerFill(br),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  r.radius(12),
                                ),
                              ),
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: color,
                                    size: r.icon(18),
                                  ),
                                  SizedBox(width: r.space(10)),
                                  Expanded(
                                    child: Text(
                                      'Next session in ${_fmt(_remaining)}',
                                      style: TextStyle(
                                        color: AppColors.onSurface(br),
                                        fontSize: r.text(13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        return;
                      }
                      widget.onComplete();
                    },
              child: Padding(
                padding: EdgeInsets.all(r.space(14)),
                child: Row(
                  children: [
                    Container(
                      width: r.space(44),
                      height: r.space(44),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(r.radius(12)),
                      ),
                      child: Icon(
                        widget.activityIcon,
                        color: color,
                        size: r.icon(22),
                      ),
                    ),
                    SizedBox(width: r.space(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: TextStyle(
                              color: AppColors.onSurface(br),
                              fontSize: r.text(15),
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.onSurfaceMuted(br),
                            ),
                          ),
                          SizedBox(height: r.space(4)),
                          Row(
                            children: [
                              Text(
                                activity.activityType,
                                style: TextStyle(
                                  color: color,
                                  fontSize: r.text(11),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (activity.intervalMinutes != null) ...[
                                SizedBox(width: r.space(6)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: r.space(6),
                                    vertical: r.space(2),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.iconButtonFill(br),
                                    borderRadius: BorderRadius.circular(
                                      r.radius(6),
                                    ),
                                  ),
                                  child: Text(
                                    _formatInterval(activity.intervalMinutes!),
                                    style: TextStyle(
                                      color: AppColors.onSurfaceMuted(br),
                                      fontSize: r.text(10),
                                    ),
                                  ),
                                ),
                              ],
                              if (activity.isRepeating) ...[
                                SizedBox(width: r.space(6)),
                                Text(
                                  '${activity.completionTimes.length}/${activity.targetCompletions}',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: r.text(11),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (activity.isRepeating) ...[
                            SizedBox(height: r.space(8)),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(r.radius(3)),
                              child: LinearProgressIndicator(
                                value: activity.completionProgress.clamp(
                                  0.0,
                                  1.0,
                                ),
                                backgroundColor: AppColors.iconButtonFill(br),
                                valueColor: AlwaysStoppedAnimation(
                                  isCompleted ? AppColors.success : color,
                                ),
                                minHeight: r.space(4),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: r.space(10)),
                    if (isCompleted)
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: r.icon(28),
                      )
                    else if (_isDueNow)
                      FadeTransition(
                        opacity: _pulseAnim,
                        child: Container(
                          width: r.icon(28),
                          height: r.icon(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2.5),
                            color: color.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            Icons.touch_app_rounded,
                            color: color,
                            size: r.icon(14),
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.lock_clock_outlined,
                        color: AppColors.onSurfaceFaint(br),
                        size: r.icon(22),
                      ),
                  ],
                ),
              ),
            ),
          ),

          if (!isCompleted)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _isDueNow
                    ? color.withValues(alpha: 0.12)
                    : AppColors.iconButtonFill(br),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(r.radius(13)),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: r.space(14),
                vertical: r.space(9),
              ),
              child: _isDueNow
                  ? Row(
                      children: [
                        FadeTransition(
                          opacity: _pulseAnim,
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            color: color,
                            size: r.icon(16),
                          ),
                        ),
                        SizedBox(width: r.space(8)),
                        Expanded(
                          child: Text(
                            'Time\'s up! Have you done it?',
                            style: TextStyle(
                              color: color,
                              fontSize: r.text(12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Tap to mark →',
                          style: TextStyle(
                            color: color.withValues(alpha: 0.8),
                            fontSize: r.text(11),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: AppColors.onSurfaceFaint(br),
                          size: r.icon(14),
                        ),
                        SizedBox(width: r.space(6)),
                        Text(
                          'Next in ',
                          style: TextStyle(
                            color: AppColors.onSurfaceFaint(br),
                            fontSize: r.text(11),
                          ),
                        ),
                        Text(
                          _fmt(_remaining),
                          style: TextStyle(
                            color: AppColors.onSurfaceMuted(br),
                            fontSize: r.text(12),
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.lock_clock_outlined,
                          color: AppColors.onSurfaceFaint(br),
                          size: r.icon(12),
                        ),
                        SizedBox(width: r.space(4)),
                        Text(
                          'Not due yet',
                          style: TextStyle(
                            color: AppColors.onSurfaceFaint(br),
                            fontSize: r.text(10),
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  String _formatInterval(int minutes) {
    if (minutes >= 60) {
      final hrs = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? 'every ${hrs}h ${mins}m' : 'every ${hrs}h';
    }
    return 'every ${minutes}m';
  }
}

class _DynamicMetricsDialog extends StatefulWidget {
  final UserActivityModel activity;

  const _DynamicMetricsDialog({required this.activity});

  @override
  State<_DynamicMetricsDialog> createState() => _DynamicMetricsDialogState();
}

class _DynamicMetricsDialogState extends State<_DynamicMetricsDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    for (var metric in widget.activity.metrics) {
      _controllers[metric.id ?? metric.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.space(24),
        vertical: responsive.space(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.activity.metrics.map((metric) {
              final isBoolean = metric.metricType == MetricType.boolean;
              final controller = _controllers[metric.id ?? metric.name]!;
              final label =
                  metric.name +
                  (metric.unit.isNotEmpty ? ' (${metric.unit})' : '');

              return Padding(
                padding: EdgeInsets.only(bottom: responsive.space(16)),
                child: isBoolean
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: AppColors.onSurface(brightness),
                              fontSize: responsive.text(14),
                            ),
                          ),
                          Switch(
                            value: controller.text == 'true',
                            onChanged: (val) {
                              setState(() {
                                controller.text = val.toString();
                              });
                            },
                            activeThumbColor: AppColors.accent,
                            inactiveTrackColor: AppColors.iconButtonFill(
                              brightness,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: AppColors.onSurfaceMuted(brightness),
                              fontSize: responsive.text(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: responsive.space(8)),
                          TextFormField(
                            controller: controller,
                            keyboardType: _getKeyboardType(metric.metricType),
                            style: TextStyle(
                              color: AppColors.onSurface(brightness),
                              fontSize: responsive.text(15),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.iconButtonFill(brightness),
                              hintText: 'Enter value...',
                              hintStyle: TextStyle(
                                color: AppColors.onSurfaceFaint(brightness),
                                fontSize: responsive.text(14),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  responsive.radius(12),
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.iconButtonBorder(brightness),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  responsive.radius(12),
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.iconButtonBorder(brightness),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  responsive.radius(12),
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.accent,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: responsive.space(16),
                                vertical: responsive.space(14),
                              ),
                            ),
                            validator: (value) {
                              if (metric.isRequired &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'This field is required';
                              }
                              if (value != null && value.isNotEmpty) {
                                if (metric.metricType == MetricType.integer &&
                                    int.tryParse(value) == null) {
                                  return 'Must be an integer';
                                }
                                if ((metric.metricType == MetricType.decimal ||
                                        metric.metricType ==
                                            MetricType.timeMinutes) &&
                                    double.tryParse(value) == null) {
                                  return 'Must be a number';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
              );
            }),
            SizedBox(height: responsive.space(8)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final result = <String, String>{};
                    for (var metric in widget.activity.metrics) {
                      final key = metric.id ?? metric.name;
                      result[key] = _controllers[key]!.text;
                    }
                    Navigator.pop(context, result);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: responsive.space(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(14)),
                  ),
                ),
                child: Text(
                  'Log Activity',
                  style: TextStyle(
                    fontSize: responsive.text(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.space(16)),
          ],
        ),
      ),
    );
  }

  TextInputType _getKeyboardType(MetricType type) {
    if (type == MetricType.integer || type == MetricType.timeMinutes) {
      return TextInputType.number;
    }
    if (type == MetricType.decimal) {
      return const TextInputType.numberWithOptions(decimal: true);
    }
    return TextInputType.text;
  }
}

class _AddActivityContent extends ConsumerStatefulWidget {
  final void Function(
    ActivityType type,
    String title,
    String? description,
    int? intervalMinutes,
    int targetCompletions,
    bool isAlarmEnabled,
    bool isPushEnabled,
  )
  onAdd;

  const _AddActivityContent({required this.onAdd});

  @override
  ConsumerState<_AddActivityContent> createState() =>
      _AddActivityContentState();
}

class _AddActivityContentState extends ConsumerState<_AddActivityContent> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isRepeating = false;
  int _targetCompletions = 1;
  int _intervalHours = 2;
  int _intervalMinutes = 0;
  bool _isAlarmEnabled = false;
  bool _isPushEnabled = false;
  bool _isCustomActivity = false;
  final _customTypeController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final selectedType = ref.watch(selectedActivityTypeProvider);
    final brightness = Theme.of(context).brightness;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.space(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Type',
            style: TextStyle(
              color: AppColors.onSurfaceMuted(brightness),
              fontSize: responsive.text(14),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: responsive.space(10)),
          ref
              .watch(activityTypesProvider)
              .when(
                data: (types) {
                  if (types.isEmpty && !_isCustomActivity) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _isCustomActivity = true);
                    });
                  }
                  if (!_isCustomActivity &&
                      selectedType == null &&
                      types.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(selectedActivityTypeProvider.notifier).state =
                          types.first;
                    });
                  }
                  return Wrap(
                    spacing: responsive.space(8),
                    runSpacing: responsive.space(8),
                    children: [
                      ...types.map((type) {
                        final isSelected =
                            !_isCustomActivity && selectedType?.id == type.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCustomActivity = false;
                              if (type.defaultIntervalMinutes != null &&
                                  type.defaultIntervalMinutes! > 0) {
                                _isRepeating = true;
                                _intervalHours =
                                    type.defaultIntervalMinutes! ~/ 60;
                                _intervalMinutes =
                                    type.defaultIntervalMinutes! % 60;
                                _targetCompletions =
                                    type.defaultTargetCompletions ?? 1;
                              } else {
                                _isRepeating = false;
                              }
                              _isAlarmEnabled = type.allowAlarm;
                              _isPushEnabled = type.allowNotes;
                            });
                            ref
                                    .read(selectedActivityTypeProvider.notifier)
                                    .state =
                                type;
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.space(14),
                              vertical: responsive.space(8),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _colorFromHex(type.color)
                                  : AppColors.iconButtonFill(brightness),
                              borderRadius: BorderRadius.circular(
                                responsive.radius(20),
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? _colorFromHex(type.color)
                                    : AppColors.iconButtonBorder(brightness),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  type.icon.isNotEmpty ? type.icon : '🎯',
                                  style: TextStyle(
                                    fontSize: responsive.text(14),
                                  ),
                                ),
                                SizedBox(width: responsive.space(6)),
                                Text(
                                  type.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.onSurfaceMuted(brightness),
                                    fontSize: responsive.text(13),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () {
                          setState(() => _isCustomActivity = true);
                          ref
                                  .read(selectedActivityTypeProvider.notifier)
                                  .state =
                              null;
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.space(14),
                            vertical: responsive.space(8),
                          ),
                          decoration: BoxDecoration(
                            color: _isCustomActivity
                                ? AppColors.accent
                                : AppColors.iconButtonFill(brightness),
                            borderRadius: BorderRadius.circular(
                              responsive.radius(20),
                            ),
                            border: Border.all(
                              color: _isCustomActivity
                                  ? AppColors.accent
                                  : AppColors.iconButtonBorder(brightness),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: _isCustomActivity
                                    ? Colors.white
                                    : AppColors.accent,
                                size: responsive.icon(15),
                              ),
                              SizedBox(width: responsive.space(6)),
                              Text(
                                'Custom',
                                style: TextStyle(
                                  color: _isCustomActivity
                                      ? Colors.white
                                      : AppColors.accent,
                                  fontSize: responsive.text(13),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
                error: (err, stack) => Text(
                  'Failed to load types',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
          SizedBox(height: responsive.space(20)),
          if (_isCustomActivity) ...[
            _buildTextField(
              controller: _customTypeController,
              label: 'Activity Name / Type',
              hint: 'e.g. Yoga, Cold Shower, Journaling...',
              responsive: responsive,
              brightness: brightness,
            ),
            SizedBox(height: responsive.space(16)),
          ],
          _buildTextField(
            controller: _titleController,
            label: 'Title',
            hint: 'Enter activity title',
            responsive: responsive,
            brightness: brightness,
          ),
          SizedBox(height: responsive.space(16)),
          _buildTextField(
            controller: _descController,
            label: 'Description (optional)',
            hint: 'Add some details...',
            maxLines: 3,
            responsive: responsive,
            brightness: brightness,
          ),
          SizedBox(height: responsive.space(20)),
          _buildRepeatSection(responsive, brightness),
          SizedBox(height: responsive.space(20)),
          _buildNotificationSection(responsive, brightness),
          SizedBox(height: responsive.space(24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final hasType = _isCustomActivity
                    ? _customTypeController.text.trim().isNotEmpty
                    : selectedType != null;

                if (_titleController.text.trim().isNotEmpty && hasType) {
                  final totalMin = _isRepeating
                      ? (_intervalHours * 60 + _intervalMinutes)
                      : null;

                  final effectiveType = _isCustomActivity
                      ? ActivityType(
                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                          categoryId: '',
                          categoryName: 'Custom',
                          name: _customTypeController.text.trim(),
                          description: '',
                          icon: '🎯',
                          color: '#7C3AED',
                          isActive: true,
                          isGymActivity: false,
                          allowAlarm: true,
                          allowNotes: true,
                          metrics: const [],
                        )
                      : selectedType!;

                  widget.onAdd(
                    effectiveType,
                    _titleController.text.trim(),
                    _descController.text.trim().isNotEmpty
                        ? _descController.text.trim()
                        : null,
                    totalMin != null && totalMin > 0 ? totalMin : null,
                    _isRepeating ? _targetCompletions : 1,
                    _isAlarmEnabled,
                    _isPushEnabled,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a type and enter a title'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: responsive.space(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(14)),
                ),
              ),
              child: Text(
                'Add Activity',
                style: TextStyle(
                  fontSize: responsive.text(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.space(16)),
        ],
      ),
    );
  }

  Widget _buildRepeatSection(Responsive responsive, Brightness brightness) {
    return Container(
      padding: EdgeInsets.all(responsive.space(16)),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(responsive.radius(14)),
        border: Border.all(
          color: _isRepeating
              ? AppColors.accent.withValues(alpha: 0.3)
              : AppColors.containerBorder(brightness),
        ),
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
                    Icons.repeat_rounded,
                    color: _isRepeating
                        ? AppColors.accent
                        : AppColors.onSurfaceFaint(brightness),
                    size: responsive.icon(20),
                  ),
                  SizedBox(width: responsive.space(10)),
                  Text(
                    'Repeat Activity',
                    style: TextStyle(
                      color: AppColors.onSurface(brightness),
                      fontSize: responsive.text(15),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isRepeating,
                onChanged: (v) => setState(() {
                  _isRepeating = v;
                  if (v && _targetCompletions < 2) _targetCompletions = 2;
                }),
                activeThumbColor: AppColors.accent,
                inactiveTrackColor: AppColors.iconButtonFill(brightness),
              ),
            ],
          ),
          if (_isRepeating) ...[
            SizedBox(height: responsive.space(16)),
            Text(
              'How many times?',
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: responsive.text(13),
              ),
            ),
            SizedBox(height: responsive.space(8)),
            Row(
              children: [
                _buildCounterBtn(
                  Icons.remove,
                  () {
                    if (_targetCompletions > 2) {
                      setState(() => _targetCompletions--);
                    }
                  },
                  responsive,
                  brightness,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.space(20),
                  ),
                  child: Text(
                    '$_targetCompletions times',
                    style: TextStyle(
                      color: AppColors.onSurface(brightness),
                      fontSize: responsive.text(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCounterBtn(
                  Icons.add,
                  () {
                    if (_targetCompletions < 20) {
                      setState(() => _targetCompletions++);
                    }
                  },
                  responsive,
                  brightness,
                ),
              ],
            ),
            SizedBox(height: responsive.space(16)),
            Text(
              'Interval between each',
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: responsive.text(13),
              ),
            ),
            SizedBox(height: responsive.space(8)),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _intervalHours,
                    items: {
                      ...List.generate(13, (i) => i),
                      _intervalHours,
                    }.toList()..sort(),
                    suffix: 'hrs',
                    onChanged: (v) => setState(() => _intervalHours = v),
                    responsive: responsive,
                    brightness: brightness,
                  ),
                ),
                SizedBox(width: responsive.space(12)),
                Expanded(
                  child: _buildDropdown(
                    value: _intervalMinutes,
                    items: {0, 15, 30, 45, _intervalMinutes}.toList()..sort(),
                    suffix: 'min',
                    onChanged: (v) => setState(() => _intervalMinutes = v),
                    responsive: responsive,
                    brightness: brightness,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.space(8)),
            Text(
              'e.g. Drink water every ${_intervalHours}h${_intervalMinutes > 0 ? "${_intervalMinutes}m" : ""}, $_targetCompletions times/day',
              style: TextStyle(
                color: AppColors.onSurfaceFaint(brightness),
                fontSize: responsive.text(11),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationSection(
    Responsive responsive,
    Brightness brightness,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.space(16)),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(responsive.radius(14)),
        border: Border.all(color: AppColors.containerBorder(brightness)),
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
                    Icons.notifications_active_rounded,
                    color: _isPushEnabled
                        ? AppColors.accent
                        : AppColors.onSurfaceFaint(brightness),
                    size: responsive.icon(20),
                  ),
                  SizedBox(width: responsive.space(10)),
                  Text(
                    'Push Notifications',
                    style: TextStyle(
                      color: AppColors.onSurface(brightness),
                      fontSize: responsive.text(15),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isPushEnabled,
                onChanged: (v) async {
                  if (v) {
                    final status = await Permission.notification.request();
                    if (!status.isGranted) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notification permission denied. Enable it in Settings.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                  }
                  setState(() => _isPushEnabled = v);
                },
                activeThumbColor: AppColors.accent,
                inactiveTrackColor: AppColors.iconButtonFill(brightness),
              ),
            ],
          ),
          SizedBox(height: responsive.space(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.alarm_rounded,
                    color: _isAlarmEnabled
                        ? AppColors.accent
                        : AppColors.onSurfaceFaint(brightness),
                    size: responsive.icon(20),
                  ),
                  SizedBox(width: responsive.space(10)),
                  Text(
                    'Alarm Notifications',
                    style: TextStyle(
                      color: AppColors.onSurface(brightness),
                      fontSize: responsive.text(15),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isAlarmEnabled,
                onChanged: (v) async {
                  if (v) {
                    final status = await Permission.scheduleExactAlarm
                        .request();
                    if (!status.isGranted) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Alarm permission denied. Enable it in Settings.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                  }
                  setState(() => _isAlarmEnabled = v);
                },
                activeThumbColor: AppColors.accent,
                inactiveTrackColor: AppColors.iconButtonFill(brightness),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBtn(
    IconData icon,
    VoidCallback onTap,
    Responsive responsive,
    Brightness brightness,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.space(8)),
        decoration: BoxDecoration(
          color: AppColors.iconButtonFill(brightness),
          borderRadius: BorderRadius.circular(responsive.radius(8)),
          border: Border.all(color: AppColors.iconButtonBorder(brightness)),
        ),
        child: Icon(
          icon,
          color: AppColors.onSurface(brightness),
          size: responsive.icon(18),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required int value,
    required List<int> items,
    required String suffix,
    required ValueChanged<int> onChanged,
    required Responsive responsive,
    required Brightness brightness,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.space(12)),
      decoration: BoxDecoration(
        color: AppColors.inputFill(brightness),
        borderRadius: BorderRadius.circular(responsive.radius(10)),
        border: Border.all(color: AppColors.inputBorder(brightness)),
      ),
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: brightness == Brightness.dark
            ? const Color(0xFF1A2A3F)
            : Colors.white,
        style: TextStyle(
          color: AppColors.onSurface(brightness),
          fontSize: responsive.text(14),
        ),
        items: items
            .map((v) => DropdownMenuItem(value: v, child: Text('$v $suffix')))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Responsive responsive,
    required Brightness brightness,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.onSurfaceMuted(brightness),
            fontSize: responsive.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: responsive.space(8)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: AppColors.onSurface(brightness),
            fontSize: responsive.text(15),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.onSurfaceFaint(brightness)),
            filled: true,
            fillColor: AppColors.inputFill(brightness),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              borderSide: BorderSide(color: AppColors.inputBorder(brightness)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              borderSide: BorderSide(color: AppColors.inputBorder(brightness)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.space(16),
              vertical: responsive.space(14),
            ),
          ),
        ),
      ],
    );
  }

  Color _colorFromHex(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
    } catch (_) {
      return AppColors.accent;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'exercise':
        return Icons.fitness_center_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'reading':
        return Icons.menu_book_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'social':
        return Icons.people_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'exercise':
        return const Color(0xFFFF6B6B);
      case 'meditation':
        return const Color(0xFF9B59B6);
      case 'reading':
        return const Color(0xFF3498DB);
      case 'work':
        return const Color(0xFFF39C12);
      case 'health':
        return const Color(0xFF2ECC71);
      case 'social':
        return const Color(0xFFE91E63);
      default:
        return AppColors.accent;
    }
  }
}
