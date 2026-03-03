import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/widgets/screens/empty_state_widget.dart';
import '../../../../core/widgets/loading/ghost_running.dart';
import '../providers/alarm_provider.dart';
import '../widgets/alarm_card.dart';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alarmProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient(Theme.of(context).brightness),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Alarms',
                actions: [
                  if (!state.hasPermission)
                    IconButton(
                      icon: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      onPressed: () => _showPermissionDialog(context),
                    ),
                ],
              ),
              Expanded(
                child: state.isLoading
                    ? const GhostRunning(primaryMessage: 'Loading alarms...')
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(alarmProvider.notifier).init();
                        },
                        color: AppColors.onSurface(brightness),
                        backgroundColor: AppColors.primary,
                        child: state.alarms.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.alarm_off,
                                title: 'No alarms set',
                                description: 'Tap + to create your first alarm',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  100,
                                ),
                                itemCount: state.alarms.length,
                                itemBuilder: (context, index) {
                                  final alarm = state.alarms[index];
                                  final alarmId = alarm.id;
                                  return AlarmCard(
                                    key: ValueKey(alarmId),
                                    alarm: alarm,
                                    onToggle: (enabled) {
                                      ref
                                          .read(alarmProvider.notifier)
                                          .toggleAlarm(alarmId, enabled);
                                    },
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.alarmEdit,
                                        arguments: alarmId,
                                      );
                                    },
                                    onDelete: () =>
                                        _confirmDelete(context, alarmId),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.alarmCreate),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Alarm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 6,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String alarmId) {
    final brightness = Theme.of(context).brightness;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => Dialog(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF1B2B3B)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4444).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Color(0xFFFF4444),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Alarm',
                style: TextStyle(
                  color: AppColors.onSurface(brightness),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this alarm? This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceMuted(brightness),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceMuted(brightness),
                        side: BorderSide(
                          color: AppColors.containerBorder(brightness),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref
                            .read(alarmProvider.notifier)
                            .deleteAlarm(alarmId);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text('Alarm deleted'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1B2B3B),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF1B2B3B)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_clock_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Permission Required',
                style: TextStyle(
                  color: AppColors.onSurface(brightness),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alarms need the exact alarm permission to work reliably. Please grant this permission in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceMuted(brightness),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceMuted(brightness),
                        side: BorderSide(
                          color: AppColors.containerBorder(brightness),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(alarmProvider.notifier).requestPermission();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Grant',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
