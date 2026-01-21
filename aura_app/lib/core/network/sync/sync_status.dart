class SyncStatus {
  final bool isSyncing;
  final int pendingSOS;
  final int pendingWellness;
  final int pendingActivities;
  final DateTime? lastSyncTime;
  final String? lastError;

  const SyncStatus({
    this.isSyncing = false,
    this.pendingSOS = 0,
    this.pendingWellness = 0,
    this.pendingActivities = 0,
    this.lastSyncTime,
    this.lastError,
  });

  int get totalPending => pendingSOS + pendingWellness + pendingActivities;

  bool get hasPending => totalPending > 0;

  SyncStatus copyWith({
    bool? isSyncing,
    int? pendingSOS,
    int? pendingWellness,
    int? pendingActivities,
    DateTime? lastSyncTime,
    String? lastError,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingSOS: pendingSOS ?? this.pendingSOS,
      pendingWellness: pendingWellness ?? this.pendingWellness,
      pendingActivities: pendingActivities ?? this.pendingActivities,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError ?? this.lastError,
    );
  }
}
