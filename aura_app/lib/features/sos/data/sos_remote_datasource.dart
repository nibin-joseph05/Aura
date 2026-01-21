import '../../../core/network/http/dio_client.dart';
import '../../../core/network/http/api_endpoints.dart';
import 'models/sos_settings.dart';
import 'models/sos_event.dart';
import 'models/trusted_contact.dart';

class SOSRemoteDataSource {
  final DioClient _dioClient;

  SOSRemoteDataSource({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  Future<SOSSettings> getSettings() async {
    final response = await _dioClient.dio.get(ApiEndpoints.sosSettings);
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return SOSSettings.fromJson(data['data']);
    }
    throw Exception(data['error'] ?? 'Failed to fetch SOS settings');
  }

  Future<SOSSettings> updateMessage(String message) async {
    final response = await _dioClient.dio.put(
      ApiEndpoints.sosMessage,
      data: {'customMessage': message},
    );
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return SOSSettings.fromJson(data['data']);
    }
    throw Exception(data['error'] ?? 'Failed to update SOS message');
  }

  Future<List<TrustedContact>> getContacts() async {
    final response = await _dioClient.dio.get(ApiEndpoints.sosContacts);
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return (data['data'] as List)
          .map((c) => TrustedContact.fromJson(c))
          .toList();
    }
    throw Exception(data['error'] ?? 'Failed to fetch contacts');
  }

  Future<TrustedContact> addContact({
    required String name,
    required String phone,
    String? email,
    String? relationship,
    int? priority,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.sosContacts,
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'relationship': relationship,
        'priority': priority,
      },
    );
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return TrustedContact.fromJson(data['data']);
    }
    throw Exception(data['error'] ?? 'Failed to add contact');
  }

  Future<void> removeContact(String contactId) async {
    final response = await _dioClient.dio.delete(
      ApiEndpoints.sosContactById(contactId),
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to remove contact');
    }
  }

  Future<SOSEvent> triggerSOS({
    required double latitude,
    required double longitude,
    String? address,
    String? customMessage,
    int? contactsNotified,
    bool syncedFromOffline = false,
    DateTime? triggeredAt,
    String? deviceInfo,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.sosTrigger,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'customMessage': customMessage,
        'contactsNotified': contactsNotified,
        'syncedFromOffline': syncedFromOffline,
        'triggeredAt': triggeredAt?.toIso8601String(),
        'deviceInfo': deviceInfo,
      },
    );
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return SOSEvent.fromJson(data['data']);
    }
    throw Exception(data['error'] ?? 'Failed to trigger SOS');
  }

  Future<List<SOSEvent>> getUserEvents() async {
    final response = await _dioClient.dio.get(ApiEndpoints.sosEvents);
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return (data['data'] as List).map((e) => SOSEvent.fromJson(e)).toList();
    }
    throw Exception(data['error'] ?? 'Failed to fetch SOS events');
  }

  Future<SOSEvent> syncOfflineEvent(SOSEvent event) async {
    return triggerSOS(
      latitude: event.latitude,
      longitude: event.longitude,
      address: event.address,
      customMessage: event.message,
      contactsNotified: event.contactsNotified,
      syncedFromOffline: true,
      triggeredAt: event.triggeredAt,
      deviceInfo: event.deviceInfo,
    );
  }
}
