import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../widgets/common/screens/no_internet_screen.dart';
import 'internet_status_provider.dart';
import 'offline_mode_provider.dart';

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet = ref.watch(internetStatusProvider).value ?? true;
    final offlineMode = ref.watch(offlineModeProvider);

    return Stack(
      children: [
        child,

        if (!hasInternet && offlineMode)
          const NoInternetScreen(isOverlay: true),
      ],
    );
  }
}
