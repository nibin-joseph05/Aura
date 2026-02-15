import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionsProvider =
    StateNotifierProvider<PermissionsNotifier, PermissionsState>((ref) {
      return PermissionsNotifier();
    });

class PermissionItem {
  final String label;
  final Permission permission;
  final bool isGranted;
  final bool isPermanentlyDenied;

  PermissionItem({
    required this.label,
    required this.permission,
    this.isGranted = false,
    this.isPermanentlyDenied = false,
  });

  PermissionItem copyWith({bool? isGranted, bool? isPermanentlyDenied}) {
    return PermissionItem(
      label: label,
      permission: permission,
      isGranted: isGranted ?? this.isGranted,
      isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
    );
  }
}

class PermissionsState {
  final List<PermissionItem> permissions;
  final bool isLoading;

  PermissionsState({this.permissions = const [], this.isLoading = false});

  PermissionsState copyWith({
    List<PermissionItem>? permissions,
    bool? isLoading,
  }) {
    return PermissionsState(
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get allGranted => permissions.every((p) => p.isGranted);
}

class PermissionsNotifier extends StateNotifier<PermissionsState> {
  PermissionsNotifier() : super(PermissionsState());

  static final _permissionDefs = [
    PermissionItem(label: 'Location', permission: Permission.locationWhenInUse),
    PermissionItem(label: 'SMS', permission: Permission.sms),
    PermissionItem(label: 'Notifications', permission: Permission.notification),
    PermissionItem(label: 'Contacts', permission: Permission.contacts),
    PermissionItem(
      label: 'Background Execution',
      permission: Permission.ignoreBatteryOptimizations,
    ),
  ];

  Future<void> loadPermissions() async {
    state = state.copyWith(isLoading: true);

    final updated = <PermissionItem>[];
    for (final def in _permissionDefs) {
      final status = await def.permission.status;
      updated.add(
        def.copyWith(
          isGranted: status.isGranted,
          isPermanentlyDenied: status.isPermanentlyDenied,
        ),
      );
    }

    state = state.copyWith(permissions: updated, isLoading: false);
  }

  Future<void> requestPermission(int index) async {
    final item = state.permissions[index];

    if (item.isGranted) return;

    if (item.isPermanentlyDenied) {
      await openAppSettings();
      await Future.delayed(const Duration(seconds: 1));
      await loadPermissions();
      return;
    }

    final status = await item.permission.request();
    final updatedList = List<PermissionItem>.from(state.permissions);
    updatedList[index] = item.copyWith(
      isGranted: status.isGranted,
      isPermanentlyDenied: status.isPermanentlyDenied,
    );

    state = state.copyWith(permissions: updatedList);
  }

  Future<void> requestAll() async {
    for (var i = 0; i < state.permissions.length; i++) {
      if (!state.permissions[i].isGranted) {
        await requestPermission(i);
      }
    }
  }
}
