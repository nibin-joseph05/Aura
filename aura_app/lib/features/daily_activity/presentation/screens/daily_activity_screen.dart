import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/buttons/floating_action_btn.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/widgets/wrappers/app_bottom_sheet.dart';
import '../../data/models/user_activity_model.dart';
import '../providers/daily_activity_provider.dart';

final selectedActivityTypeProvider = StateProvider<String>((ref) => 'Exercise');

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
                child: state.isLoading
                    ? _buildLoadingState(brightness)
                    : state.todayActivities.isEmpty
                    ? _buildEmptyState(responsive, brightness)
                    : _buildActivityList(state, responsive, brightness),
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
      onTap: state.pendingSyncCount > 0 && !state.isSyncing
          ? () =>
                ref.read(dailyActivityProvider.notifier).syncPendingActivities()
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
                  state.pendingSyncCount > 0
                      ? Icons.cloud_sync_rounded
                      : Icons.cloud_done_rounded,
                  color: state.pendingSyncCount > 0
                      ? AppColors.warning
                      : AppColors.success,
                  size: responsive.icon(20),
                ),
                if (state.pendingSyncCount > 0) ...[
                  SizedBox(width: responsive.space(4)),
                  Text(
                    '${state.pendingSyncCount}',
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
      totalDone += a.isRepeating
          ? a.completionTimes.length
          : (a.completedAt != null ? 1 : 0);
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
    return Center(
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
              'Start tracking your daily activities\nby adding your first one!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: responsive.text(14),
              ),
            ),
          ],
        ),
      ),
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
    final isCompleted = activity.isRepeating
        ? activity.isFullyCompleted
        : activity.completedAt != null;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.space(10)),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(responsive.radius(14)),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : activity.isRepeating && activity.isDueNow
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.containerBorder(brightness),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(responsive.radius(14)),
          onTap: isCompleted
              ? null
              : () {
                  if (activity.isRepeating) {
                    ref
                        .read(dailyActivityProvider.notifier)
                        .recordCompletion(activity.id);
                  } else {
                    ref
                        .read(dailyActivityProvider.notifier)
                        .completeActivity(activity.id);
                  }
                },
          child: Padding(
            padding: EdgeInsets.all(responsive.space(14)),
            child: Row(
              children: [
                Icon(
                  _getActivityIcon(activity.activityType),
                  color: _getActivityColor(activity.activityType),
                  size: responsive.icon(26),
                ),
                SizedBox(width: responsive.space(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          color: AppColors.onSurface(brightness),
                          fontSize: responsive.text(15),
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.onSurfaceMuted(brightness),
                        ),
                      ),
                      if (activity.description != null) ...[
                        SizedBox(height: responsive.space(3)),
                        Text(
                          activity.description!,
                          style: TextStyle(
                            color: AppColors.onSurfaceFaint(brightness),
                            fontSize: responsive.text(12),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: responsive.space(6)),
                      Row(
                        children: [
                          Text(
                            activity.activityType,
                            style: TextStyle(
                              color: _getActivityColor(activity.activityType),
                              fontSize: responsive.text(11),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (activity.isRepeating) ...[
                            SizedBox(width: responsive.space(10)),
                            Icon(
                              Icons.repeat_rounded,
                              color: AppColors.accent,
                              size: responsive.icon(12),
                            ),
                            SizedBox(width: responsive.space(3)),
                            Text(
                              '${activity.completionTimes.length}/${activity.targetCompletions}',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: responsive.text(11),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (activity.intervalMinutes != null) ...[
                              SizedBox(width: responsive.space(6)),
                              Text(
                                _formatInterval(activity.intervalMinutes!),
                                style: TextStyle(
                                  color: AppColors.onSurfaceFaint(brightness),
                                  fontSize: responsive.text(10),
                                ),
                              ),
                            ],
                          ],
                          if (!activity.isSynced) ...[
                            SizedBox(width: responsive.space(10)),
                            Icon(
                              Icons.cloud_off_rounded,
                              color: AppColors.warning,
                              size: responsive.icon(12),
                            ),
                            SizedBox(width: responsive.space(3)),
                            Text(
                              'Offline',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: responsive.text(10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (activity.isRepeating) ...[
                        SizedBox(height: responsive.space(8)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            responsive.radius(3),
                          ),
                          child: LinearProgressIndicator(
                            value: activity.completionProgress.clamp(0.0, 1.0),
                            backgroundColor: AppColors.iconButtonFill(
                              brightness,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              isCompleted
                                  ? AppColors.success
                                  : _getActivityColor(activity.activityType),
                            ),
                            minHeight: responsive.space(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCompleted)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: responsive.icon(26),
                  )
                else
                  Container(
                    width: responsive.icon(24),
                    height: responsive.icon(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.containerBorder(brightness),
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatInterval(int minutes) {
    if (minutes >= 60) {
      final hrs = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? 'every ${hrs}h${mins}m' : 'every ${hrs}h';
    }
    return 'every ${minutes}m';
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
    ref.read(selectedActivityTypeProvider.notifier).state = 'Exercise';
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
                    activityType: type,
                    activityTypeId: type,
                    title: title,
                    description: description,
                    intervalMinutes: intervalMinutes,
                    targetCompletions: targetCompletions,
                    isAlarmEnabled: isAlarmEnabled,
                    isPushEnabled: isPushEnabled,
                  );
            },
      ),
    );
  }
}

class _AddActivityContent extends ConsumerStatefulWidget {
  final void Function(
    String type,
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
  bool _isAlarmEnabled = true;
  bool _isPushEnabled = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
          Wrap(
            spacing: responsive.space(8),
            runSpacing: responsive.space(8),
            children:
                [
                  'Exercise',
                  'Meditation',
                  'Reading',
                  'Work',
                  'Health',
                  'Social',
                  'Other',
                ].map((type) {
                  final isSelected = selectedType == type;
                  return GestureDetector(
                    onTap: () =>
                        ref.read(selectedActivityTypeProvider.notifier).state =
                            type,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.space(14),
                        vertical: responsive.space(8),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getActivityColor(type)
                            : AppColors.iconButtonFill(brightness),
                        borderRadius: BorderRadius.circular(
                          responsive.radius(20),
                        ),
                        border: Border.all(
                          color: isSelected
                              ? _getActivityColor(type)
                              : AppColors.iconButtonBorder(brightness),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getActivityIcon(type),
                            color: isSelected
                                ? Colors.white
                                : _getActivityColor(type),
                            size: responsive.icon(16),
                          ),
                          SizedBox(width: responsive.space(6)),
                          Text(
                            type,
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
                }).toList(),
          ),
          SizedBox(height: responsive.space(20)),
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
                if (_titleController.text.trim().isNotEmpty) {
                  final totalMin = _isRepeating
                      ? (_intervalHours * 60 + _intervalMinutes)
                      : null;
                  widget.onAdd(
                    selectedType,
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
                      content: Text('Please enter an activity title'),
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
                    items: List.generate(13, (i) => i),
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
                    items: [0, 15, 30, 45],
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
                onChanged: (v) => setState(() => _isPushEnabled = v),
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
                onChanged: (v) => setState(() => _isAlarmEnabled = v),
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
