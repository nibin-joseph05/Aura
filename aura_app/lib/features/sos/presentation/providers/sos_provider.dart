import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/sos_repository.dart';
import '../../data/models/sos_settings.dart';
import '../../data/models/sos_event.dart';
import '../../data/models/trusted_contact.dart';

final sosRepositoryProvider = Provider<SOSRepository>((ref) {
  return SOSRepository();
});

final sosSettingsProvider = FutureProvider.family<SOSSettings, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(sosRepositoryProvider);
  return repository.getSettings(userId);
});

final trustedContactsProvider =
    FutureProvider.family<List<TrustedContact>, String>((ref, userId) async {
      final repository = ref.watch(sosRepositoryProvider);
      return repository.getContacts(userId);
    });

final sosEventsProvider = FutureProvider.family<List<SOSEvent>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(sosRepositoryProvider);
  return repository.getEvents(userId);
});

final currentLocationProvider = FutureProvider<Position?>((ref) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  } catch (e) {
    return null;
  }
});

class SOSNotifier extends StateNotifier<AsyncValue<void>> {
  final SOSRepository _repository;
  final Ref _ref;

  SOSNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<SOSEvent?> triggerSOS({
    required String oderId,
    required double latitude,
    required double longitude,
    String? address,
    String? customMessage,
    int contactsNotified = 0,
    String? deviceInfo,
  }) async {
    state = const AsyncValue.loading();
    try {
      final event = await _repository.triggerSOS(
        oderId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        customMessage: customMessage,
        contactsNotified: contactsNotified,
        deviceInfo: deviceInfo,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(sosEventsProvider(oderId));
      return event;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<SOSSettings?> updateMessage(String oderId, String message) async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.updateMessage(oderId, message);
      state = const AsyncValue.data(null);
      _ref.invalidate(sosSettingsProvider(oderId));
      return settings;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<TrustedContact?> addContact(
    String oderId, {
    required String name,
    required String phone,
    String? email,
    String? relationship,
    int? priority,
  }) async {
    state = const AsyncValue.loading();
    try {
      final contact = await _repository.addContact(
        oderId,
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
        priority: priority,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(trustedContactsProvider(oderId));
      _ref.invalidate(sosSettingsProvider(oderId));
      return contact;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> removeContact(String oderId, String contactId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeContact(oderId, contactId);
      state = const AsyncValue.data(null);
      _ref.invalidate(trustedContactsProvider(oderId));
      _ref.invalidate(sosSettingsProvider(oderId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> syncPendingEvents() async {
    try {
      await _repository.syncPendingEvents();
    } catch (_) {}
  }
}

final sosNotifierProvider =
    StateNotifierProvider<SOSNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(sosRepositoryProvider);
      return SOSNotifier(repository, ref);
    });

final hasPendingSyncProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(sosRepositoryProvider);
  return repository.hasPendingSyncEvents();
});
