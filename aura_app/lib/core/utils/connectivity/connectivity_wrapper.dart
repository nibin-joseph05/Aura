import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/connectivity/network_quality_provider.dart';

import '../../widgets/common/screens/no_internet_screen.dart';
import '../app_snackbar.dart';
import '../app_ui_ready_provider.dart';
import 'internet_status_provider.dart';
import 'offline_mode_provider.dart';

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet = ref.watch(internetStatusProvider).value ?? true;
    final offlineMode = ref.watch(offlineModeProvider);
    final uiReady = ref.watch(appUiReadyProvider);

    ref.listen(networkQualityProvider, (prev, next) {
      final quality = next.value;
      if (!uiReady) return;

      if (quality == null) return;

      if (quality == NetworkQuality.slow) {
        AppSnackbar.showInfo(
          context: context,
          message: "Your connection is a bit slow.",
        );
      }

      if (quality == NetworkQuality.verySlow) {
        AppSnackbar.showWarning(
          context: context,
          message: "Your internet is very slow.",
        );
      }
    });

    return Stack(
      children: [
        child,
        if (!hasInternet && offlineMode)
          const NoInternetScreen(isOverlay: true),
      ],
    );
  }
}
