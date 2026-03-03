import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/navigation/app_header.dart';
import '../../user/presentation/providers/user_provider.dart';
import '../presentation/providers/sos_provider.dart';
import 'live_location_provider.dart';
import 'live_map_widget.dart';

class LiveLocationScreen extends ConsumerStatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  ConsumerState<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends ConsumerState<LiveLocationScreen> {
  int _selectedDuration = 15;
  Timer? _uiTimer;

  final _durations = [
    {'label': '15 min', 'value': 15},
    {'label': '1 hour', 'value': 60},
    {'label': 'Until stopped', 'value': 0},
  ];

  @override
  void initState() {
    super.initState();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final liveState = ref.watch(liveLocationProvider(user.uid));
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
              const AppHeader(title: 'Live Location'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: liveState.isSharing
                      ? _buildActiveSession(liveState, user.uid, brightness)
                      : _buildStartSession(user.uid, brightness),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartSession(String userId, Brightness brightness) {
    final contacts = ref.watch(trustedContactsProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.containerFill(brightness),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.containerBorder(brightness)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.share_location,
                size: 56,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              Text(
                'Share Live Location',
                style: TextStyle(
                  color: AppColors.onSurface(brightness),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your trusted contacts will see your real-time location',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceMuted(brightness),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Duration',
          style: TextStyle(
            color: AppColors.onSurfaceMuted(brightness),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _durations.map((d) {
            final isSelected = _selectedDuration == d['value'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedDuration = d['value'] as int),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.3)
                          : AppColors.iconButtonFill(brightness),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.iconButtonBorder(brightness),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      d['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.onSurface(brightness)
                            : AppColors.onSurfaceMuted(brightness),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        contacts.when(
          data: (contactList) {
            if (contactList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add trusted contacts in SOS Settings first',
                        style: TextStyle(
                          color: AppColors.onSurfaceMuted(brightness),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Text(
              '${contactList.length} trusted contact(s) will be notified',
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: 13,
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              final contactList =
                  ref.read(trustedContactsProvider(userId)).valueOrNull ?? [];
              final contactIds = contactList.map((c) => c.id).toList();
              ref
                  .read(liveLocationProvider(userId).notifier)
                  .startSharing(
                    durationMinutes: _selectedDuration,
                    contactIds: contactIds,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share_location, size: 20),
                SizedBox(width: 8),
                Text(
                  'Start Sharing',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSession(
    LiveLocationState liveState,
    String userId,
    Brightness brightness,
  ) {
    final remaining = liveState.remainingSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.share_location,
                size: 40,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Sharing Live Location',
                style: TextStyle(
                  color: AppColors.onSurface(brightness),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (liveState.durationMinutes != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} remaining',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        LiveMapWidget(points: liveState.points, height: 280),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.containerFill(brightness),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.containerBorder(brightness)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Points tracked',
                style: TextStyle(
                  color: AppColors.onSurfaceMuted(brightness),
                  fontSize: 14,
                ),
              ),
              Text(
                '${liveState.points.length}',
                style: TextStyle(
                  color: AppColors.onSurface(brightness),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              ref.read(liveLocationProvider(userId).notifier).stopSharing();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.containerFill(brightness),
              foregroundColor: AppColors.onSurface(brightness),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Stop Sharing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
