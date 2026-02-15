import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screens/empty_state_widget.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(alarmProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        elevation: 0,
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
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.alarms.isEmpty
            ? EmptyStateWidget(
                icon: Icons.alarm_off,
                title: 'No alarms set',
                description: 'Tap + to create your first alarm',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.alarms.length,
                itemBuilder: (context, index) {
                  final alarm = state.alarms[index];
                  return AlarmCard(
                    alarm: alarm,
                    onToggle: (enabled) {
                      ref
                          .read(alarmProvider.notifier)
                          .toggleAlarm(alarm.id, enabled);
                    },
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.alarmEdit,
                        arguments: alarm.id,
                      );
                    },
                    onDelete: () {
                      ref.read(alarmProvider.notifier).deleteAlarm(alarm.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alarm deleted')),
                      );
                    },
                  );
                },
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
