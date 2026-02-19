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
                        color: Colors.white,
                        backgroundColor: AppColors.primary,
                        child: state.alarms.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.alarm_off,
                                title: 'No alarms set',
                                description: 'Tap + to create your first alarm',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: state.alarms.length,
                                itemBuilder: (context, index) {
                                  // Fix: capture alarm in local variable to avoid closure bug
                                  final alarm = state.alarms[index];
                                  final alarmId =
                                      alarm.id; // capture id, not index
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
                                    onDelete: () {
                                      ref
                                          .read(alarmProvider.notifier)
                                          .deleteAlarm(alarmId);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Alarm deleted'),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.alarmCreate),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Alarms need the exact alarm permission to work reliably. '
          'Please grant this permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              ref.read(alarmProvider.notifier).requestPermission();
              Navigator.pop(context);
            },
            child: const Text('Grant'),
          ),
        ],
      ),
    );
  }
}
