import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/buttons/floating_action_btn.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/widgets/wrappers/app_bottom_sheet.dart';
import '../../data/models/daily_activity_model.dart';
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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
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
              _buildProgressCard(state, responsive),
              Expanded(
                child: state.isLoading
                    ? _buildLoadingState()
                    : state.todayActivities.isEmpty
                    ? _buildEmptyState(responsive)
                    : _buildActivityList(state, responsive),
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

  Widget _buildProgressCard(DailyActivityState state, Responsive responsive) {
    final completed = state.todayActivities
        .where((a) => a.completedAt != null)
        .length;
    final total = state.todayActivities.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.w(4)),
      padding: EdgeInsets.all(responsive.space(16)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: responsive.space(56),
            height: responsive.space(56),
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
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
                    color: Colors.white,
                    fontSize: responsive.text(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.space(4)),
                Text(
                  '$completed of $total activities completed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(Responsive responsive) {
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
                color: Colors.white,
                fontSize: responsive.text(20),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: responsive.space(8)),
            Text(
              'Start tracking your daily activities\nby adding your first one!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: responsive.text(14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(DailyActivityState state, Responsive responsive) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(4),
        vertical: responsive.space(16),
      ),
      itemCount: state.todayActivities.length,
      itemBuilder: (context, index) {
        final activity = state.todayActivities[index];
        return _buildActivityCard(activity, responsive);
      },
    );
  }

  Widget _buildActivityCard(
    DailyActivityModel activity,
    Responsive responsive,
  ) {
    final isCompleted = activity.completedAt != null;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.space(10)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isCompleted ? 0.05 : 0.08),
        borderRadius: BorderRadius.circular(responsive.radius(14)),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(responsive.radius(14)),
          onTap: isCompleted
              ? null
              : () => ref
                    .read(dailyActivityProvider.notifier)
                    .completeActivity(activity.id),
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
                          color: Colors.white,
                          fontSize: responsive.text(15),
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      if (activity.description != null) ...[
                        SizedBox(height: responsive.space(3)),
                        Text(
                          activity.description!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
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
                        color: Colors.white.withValues(alpha: 0.3),
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
        onAdd: (type, title, description) {
          ref
              .read(dailyActivityProvider.notifier)
              .addActivity(
                activityType: type,
                title: title,
                description: description,
              );
        },
      ),
    );
  }
}

class _AddActivityContent extends ConsumerStatefulWidget {
  final void Function(String type, String title, String? description) onAdd;

  const _AddActivityContent({required this.onAdd});

  @override
  ConsumerState<_AddActivityContent> createState() =>
      _AddActivityContentState();
}

class _AddActivityContentState extends ConsumerState<_AddActivityContent> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.space(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Type',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
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
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          responsive.radius(20),
                        ),
                        border: Border.all(
                          color: isSelected
                              ? _getActivityColor(type)
                              : Colors.white.withValues(alpha: 0.2),
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
                              color: Colors.white,
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
          ),
          SizedBox(height: responsive.space(16)),
          _buildTextField(
            controller: _descController,
            label: 'Description (optional)',
            hint: 'Add some details...',
            maxLines: 3,
            responsive: responsive,
          ),
          SizedBox(height: responsive.space(24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.trim().isNotEmpty) {
                  widget.onAdd(
                    selectedType,
                    _titleController.text.trim(),
                    _descController.text.trim().isNotEmpty
                        ? _descController.text.trim()
                        : null,
                  );
                  Navigator.pop(context);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Responsive responsive,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: responsive.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: responsive.space(8)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: Colors.white, fontSize: responsive.text(15)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
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
