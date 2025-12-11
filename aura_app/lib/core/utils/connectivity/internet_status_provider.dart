import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final internetStatusProvider = StreamProvider<bool>((ref) async* {
  yield await _checkInternet();

  final stream = Stream.periodic(const Duration(seconds: 1), (_) async {
    return await _checkInternet();
  }).asyncMap((event) async => await event);

  yield* stream;
});

Future<bool> _checkInternet() async {
  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 2));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
