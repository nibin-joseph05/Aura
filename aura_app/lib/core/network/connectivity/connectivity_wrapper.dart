import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/snackbar/app_snackbar.dart';
import '../../state/app_ui_ready_provider.dart';
import '../../widgets/screens/no_internet_screen.dart';
import 'internet_status_provider.dart';
import 'network_quality_provider.dart';
import 'offline_mode_provider.dart';

class ConnectivityWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  ConsumerState<ConnectivityWrapper> createState() =>
      _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends ConsumerState<ConnectivityWrapper> {
  @override
  Widget build(BuildContext context) {
    final hasInternet = ref.watch(internetStatusProvider).value ?? true;
    final offlineMode = ref.watch(offlineModeProvider);
    final uiReady = ref.watch(appUiReadyProvider);

    ref.listen(networkQualityProvider, (prev, next) {
      if (!mounted) return;

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
        widget.child,
        if (!hasInternet && offlineMode)
          const NoInternetScreen(isOverlay: true),
      ],
    );
  }
}
