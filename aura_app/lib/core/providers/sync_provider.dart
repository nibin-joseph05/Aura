import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/sync/sync_manager.dart';
import '../network/sync/sync_status.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager();
});

final syncStatusProvider = StreamProvider.autoDispose<SyncStatus>((ref) {
  final manager = ref.watch(syncManagerProvider);
  return manager.statusStream;
});

final isSyncingProvider = Provider<bool>((ref) {
  final status = ref.watch(syncStatusProvider);
  return status.when(
    data: (s) => s.isSyncing,
    loading: () => false,
    error: (_, __) => false,
  );
});

final pendingSyncCountProvider = Provider<int>((ref) {
  final status = ref.watch(syncStatusProvider);
  return status.when(
    data: (s) => s.totalPending,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
