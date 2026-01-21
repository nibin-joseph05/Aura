import 'package:hive_flutter/hive_flutter.dart';
import 'models/sos_settings.dart';
import 'models/sos_event.dart';
import 'models/trusted_contact.dart';

class SOSLocalDataSource {
  static const String _settingsBoxName = 'sos_settings';
  static const String _eventsBoxName = 'sos_events';
  static const String _pendingSyncBoxName = 'sos_pending_sync';

  Future<Box<SOSSettings>> get _settingsBox async =>
      Hive.openBox<SOSSettings>(_settingsBoxName);

  Future<Box<SOSEvent>> get _eventsBox async =>
      Hive.openBox<SOSEvent>(_eventsBoxName);

  Future<Box<SOSEvent>> get _pendingSyncBox async =>
      Hive.openBox<SOSEvent>(_pendingSyncBoxName);

  Future<SOSSettings?> getSettings(String userId) async {
    final box = await _settingsBox;
    return box.get(userId);
  }

  Future<void> saveSettings(SOSSettings settings) async {
    final box = await _settingsBox;
    await box.put(settings.userId, settings);
  }

  Future<List<TrustedContact>> getContacts(String userId) async {
    final settings = await getSettings(userId);
    return settings?.contacts ?? [];
  }

  Future<void> saveContacts(
    String userId,
    List<TrustedContact> contacts,
  ) async {
    final settings = await getSettings(userId);
    if (settings != null) {
      final updated = settings.copyWith(
        contacts: contacts,
        lastUpdated: DateTime.now(),
      );
      await saveSettings(updated);
    }
  }

  Future<void> addContact(String userId, TrustedContact contact) async {
    final contacts = await getContacts(userId);
    contacts.add(contact);
    await saveContacts(userId, contacts);
  }

  Future<void> removeContact(String userId, String contactId) async {
    final contacts = await getContacts(userId);
    contacts.removeWhere((c) => c.id == contactId);
    await saveContacts(userId, contacts);
  }

  Future<List<SOSEvent>> getEvents(String userId) async {
    final box = await _eventsBox;
    return box.values.where((e) => e.oderId == userId).toList()
      ..sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
  }

  Future<void> saveEvent(SOSEvent event) async {
    final box = await _eventsBox;
    await box.put(event.id, event);
  }

  Future<void> addToPendingSync(SOSEvent event) async {
    final box = await _pendingSyncBox;
    await box.put(event.id, event);
  }

  Future<List<SOSEvent>> getPendingSyncEvents() async {
    final box = await _pendingSyncBox;
    return box.values.toList();
  }

  Future<void> removeFromPendingSync(String eventId) async {
    final box = await _pendingSyncBox;
    await box.delete(eventId);
  }

  Future<void> clearPendingSync() async {
    final box = await _pendingSyncBox;
    await box.clear();
  }

  Future<void> updateEventSyncStatus(String eventId, bool synced) async {
    final box = await _eventsBox;
    final event = box.get(eventId);
    if (event != null) {
      await box.put(eventId, event.copyWith(syncedToServer: synced));
    }
  }

  Future<void> clearAll() async {
    final settingsBox = await _settingsBox;
    final eventsBox = await _eventsBox;
    final pendingBox = await _pendingSyncBox;

    await settingsBox.clear();
    await eventsBox.clear();
    await pendingBox.clear();
  }
}
