import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkQuality { fast, slow, verySlow, offline }

final networkQualityProvider = StreamProvider.autoDispose<NetworkQuality>((
  ref,
) async* {
  yield await _checkQuality();

  final stream = Stream.periodic(const Duration(seconds: 3), (_) async {
    return await _checkQuality();
  }).asyncMap((event) async => await event);

  yield* stream;
});

Future<NetworkQuality> _checkQuality() async {
  final stopwatch = Stopwatch()..start();

  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 2));

    if (result.isEmpty || result[0].rawAddress.isEmpty) {
      return NetworkQuality.offline;
    }

    final ping = stopwatch.elapsedMilliseconds;

    if (ping < 150) return NetworkQuality.fast;
    if (ping < 600) return NetworkQuality.slow;
    return NetworkQuality.verySlow;
  } catch (_) {
    return NetworkQuality.offline;
  }
}
