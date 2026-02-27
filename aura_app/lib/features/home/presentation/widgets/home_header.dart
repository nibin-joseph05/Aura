import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../user/presentation/providers/profile_image_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String? _buildFullImageUrl(String? path, {int? cacheBust}) {
    if (path == null || path.isEmpty) return null;
    String url;
    if (path.startsWith('http')) {
      url = path;
    } else {
      final base = AppConfig.baseUrl;
      if (path.startsWith('/uploads/')) {
        url = '$base$path';
      } else {
        url = '$base/uploads/$path';
      }
    }
    if (cacheBust != null) {
      return '$url?v=$cacheBust';
    }
    return url;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final userState = ref.watch(userProvider);
    final imgState = ref.watch(profileImageProvider);
    final user = userState.user;

    final String? rawPath = imgState.imageUrl ?? user?.profileImageUrl;
    final profileImageUrl = _buildFullImageUrl(
      rawPath,
      cacheBust: imgState.uploadedAt,
    );

    final notifState = ref.watch(notificationProvider);
    final unreadCount = notifState.unreadCount;

    final firstName = user?.name?.split(' ').first ?? 'User';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(5),
            vertical: responsive.h(1.5),
          ),
          child: Row(
            children: [
              Image.asset(
                AssetConstants.auraAppIcon,
                width: responsive.isTablet ? 44 : 36,
                height: responsive.isTablet ? 44 : 36,
              ),
              SizedBox(width: responsive.w(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi, $firstName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Welcome to Aura',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: responsive.isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeaderIcon(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () => Navigator.pushNamed(context, '/chat'),
                responsive: responsive,
              ),
              SizedBox(width: responsive.w(1.5)),
              _buildNotificationIcon(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                responsive: responsive,
                unreadCount: unreadCount,
              ),
              SizedBox(width: responsive.w(2)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.myAccount),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: responsive.isTablet ? 48 : 40,
                      height: responsive.isTablet ? 48 : 40,
                      child: profileImageUrl != null
                          ? Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.white24,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder(responsive),
                            )
                          : _buildPlaceholder(responsive),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          margin: EdgeInsets.symmetric(horizontal: responsive.w(5)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(Responsive responsive) {
    return Container(
      color: Colors.white24,
      child: Icon(
        Icons.person,
        size: responsive.isTablet ? 24 : 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Responsive responsive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: responsive.isTablet ? 40 : 34,
        height: responsive.isTablet ? 40 : 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: responsive.isTablet ? 20 : 17,
        ),
      ),
    );
  }

  Widget _buildNotificationIcon({
    required VoidCallback onTap,
    required Responsive responsive,
    required int unreadCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: responsive.isTablet ? 40 : 34,
            height: responsive.isTablet ? 40 : 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: responsive.isTablet ? 20 : 17,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF416C),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
