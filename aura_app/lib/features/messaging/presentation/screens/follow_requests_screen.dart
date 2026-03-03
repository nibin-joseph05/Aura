import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/widgets/screens/empty_state_widget.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../providers/messaging_provider.dart';

class FollowRequestsScreen extends ConsumerStatefulWidget {
  const FollowRequestsScreen({super.key});

  @override
  ConsumerState<FollowRequestsScreen> createState() =>
      _FollowRequestsScreenState();
}

class _FollowRequestsScreenState extends ConsumerState<FollowRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(userProvider).user?.uid;
      if (userId != null) {
        ref.read(messagingProvider.notifier).loadFollowRequests(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(messagingProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient(Theme.of(context).brightness),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: 'Follow Requests'),
              Expanded(
                child: state.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.onSurface(
                            isDark ? Brightness.dark : Brightness.light,
                          ),
                        ),
                      )
                    : state.followRequests.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.person_add_disabled_rounded,
                        title: 'No pending requests',
                        description:
                            'Follow requests from other users will appear here',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.followRequests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _buildRequestTile(
                            state.followRequests[index],
                            isDark,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestTile(FollowRequestModel request, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              request.followerName.isNotEmpty
                  ? request.followerName
                  : request.followerId.length > 12
                  ? '${request.followerId.substring(0, 12)}...'
                  : request.followerId,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(messagingProvider.notifier).acceptFollow(request.id);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Accept',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              ref.read(messagingProvider.notifier).rejectFollow(request.id);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Reject',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
