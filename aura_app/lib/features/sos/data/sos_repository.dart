import 'package:dio/dio.dart';
import '../../../core/network/connectivity/connectivity_service.dart';
import 'sos_local_datasource.dart';
import 'sos_remote_datasource.dart';
import 'models/sos_settings.dart';
import 'models/sos_event.dart';
import 'models/sos_event_status.dart';
import 'models/trusted_contact.dart';

class SOSRepository {
  final SOSRemoteDataSource _remoteDataSource;
  final SOSLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  SOSRepository({
    SOSRemoteDataSource? remoteDataSource,
    SOSLocalDataSource? localDataSource,
    ConnectivityService? connectivityService,
  }) : _remoteDataSource = remoteDataSource ?? SOSRemoteDataSource(),
       _localDataSource = localDataSource ?? SOSLocalDataSource(),
       _connectivityService = connectivityService ?? ConnectivityService();

  Future<SOSSettings> getSettings(String userId) async {
    if (await _connectivityService.hasConnection()) {
      try {
        final settings = await _remoteDataSource.getSettings();
        await _localDataSource.saveSettings(settings);
        return settings;
      } on DioException {
        final local = await _localDataSource.getSettings(userId);
        return local ?? SOSSettings.defaultSettings(userId);
      }
    }
    final local = await _localDataSource.getSettings(userId);
    return local ?? SOSSettings.defaultSettings(userId);
  }

  Future<SOSSettings> updateMessage(String userId, String message) async {
    if (await _connectivityService.hasConnection()) {
      try {
        final settings = await _remoteDataSource.updateMessage(message);
        await _localDataSource.saveSettings(settings);
        return settings;
      } on DioException {
        final local = await _localDataSource.getSettings(userId);
        if (local != null) {
          final updated = local.copyWith(
            customMessage: message,
            lastUpdated: DateTime.now(),
          );
          await _localDataSource.saveSettings(updated);
          return updated;
        }
        throw Exception('Failed to update message');
      }
    }
    final local = await _localDataSource.getSettings(userId);
    if (local != null) {
      final updated = local.copyWith(
        customMessage: message,
        lastUpdated: DateTime.now(),
      );
      await _localDataSource.saveSettings(updated);
      return updated;
    }
    throw Exception('No network connection');
  }

  Future<List<TrustedContact>> getContacts(String userId) async {
    if (await _connectivityService.hasConnection()) {
      try {
        final contacts = await _remoteDataSource.getContacts();
        await _localDataSource.saveContacts(userId, contacts);
        return contacts;
      } on DioException {
        return await _localDataSource.getContacts(userId);
      }
    }
    return await _localDataSource.getContacts(userId);
  }

  Future<TrustedContact> addContact(
    String userId, {
    required String name,
    required String phone,
    String? email,
    String? relationship,
    int? priority,
  }) async {
    if (await _connectivityService.hasConnection()) {
      final contact = await _remoteDataSource.addContact(
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
        priority: priority,
      );
      await _localDataSource.addContact(userId, contact);
      return contact;
    }
    throw Exception('No network connection. Cannot add contact offline.');
  }

  Future<void> removeContact(String userId, String contactId) async {
    if (await _connectivityService.hasConnection()) {
      await _remoteDataSource.removeContact(contactId);
    }
    await _localDataSource.removeContact(userId, contactId);
  }

  Future<SOSEvent> triggerSOS(
    String userId, {
    required double latitude,
    required double longitude,
    String? address,
    String? customMessage,
    int contactsNotified = 0,
    String? deviceInfo,
  }) async {
    final event = SOSEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      oderId: userId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      message: customMessage ?? 'I need help! This is an emergency.',
      contactsNotified: contactsNotified,
      status: SOSEventStatus.triggered,
      triggeredAt: DateTime.now(),
      syncedToServer: false,
      deviceInfo: deviceInfo,
    );

    await _localDataSource.saveEvent(event);

    if (await _connectivityService.hasConnection()) {
      try {
        final serverEvent = await _remoteDataSource.triggerSOS(
          latitude: latitude,
          longitude: longitude,
          address: address,
          customMessage: customMessage,
          contactsNotified: contactsNotified,
          syncedFromOffline: false,
          triggeredAt: event.triggeredAt,
          deviceInfo: deviceInfo,
        );
        await _localDataSource.saveEvent(
          serverEvent.copyWith(syncedToServer: true),
        );
        return serverEvent;
      } on DioException {
        await _localDataSource.addToPendingSync(event);
        return event;
      }
    }

    await _localDataSource.addToPendingSync(event);
    return event;
  }

  Future<List<SOSEvent>> getEvents(String userId) async {
    if (await _connectivityService.hasConnection()) {
      try {
        final events = await _remoteDataSource.getUserEvents();
        for (final event in events) {
          await _localDataSource.saveEvent(event);
        }
        return events;
      } on DioException {
        return await _localDataSource.getEvents(userId);
      }
    }
    return await _localDataSource.getEvents(userId);
  }

  Future<void> syncPendingEvents() async {
    if (!await _connectivityService.hasConnection()) return;

    final pendingEvents = await _localDataSource.getPendingSyncEvents();
    for (final event in pendingEvents) {
      try {
        final syncedEvent = await _remoteDataSource.syncOfflineEvent(event);
        await _localDataSource.saveEvent(
          syncedEvent.copyWith(syncedToServer: true),
        );
        await _localDataSource.removeFromPendingSync(event.id);
      } catch (_) {}
    }
  }

  Future<bool> hasPendingSyncEvents() async {
    final pending = await _localDataSource.getPendingSyncEvents();
    return pending.isNotEmpty;
  }
}
