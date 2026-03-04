import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
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
    final brightness = Theme.of(context).brightness;

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
                      'Hi, $firstName 👋',
                      style: TextStyle(
                        color: AppColors.onSurface(brightness),
                        fontSize: responsive.isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Welcome to Aura',
                      style: TextStyle(
                        color: AppColors.onSurfaceMuted(brightness),
                        fontSize: responsive.isTablet ? 13 : 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildNotificationIcon(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                responsive: responsive,
                unreadCount: unreadCount,
                brightness: brightness,
              ),
              SizedBox(width: responsive.w(2)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.myAccount),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.iconButtonBorder(brightness),
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
                                      color: AppColors.iconButtonFill(
                                        brightness,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder(responsive, brightness),
                            )
                          : _buildPlaceholder(responsive, brightness),
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
                AppColors.dividerColor(brightness).withValues(alpha: 0.0),
                AppColors.dividerColor(brightness),
                AppColors.dividerColor(brightness),
                AppColors.dividerColor(brightness).withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(Responsive responsive, Brightness brightness) {
    return Container(
      color: AppColors.iconButtonFill(brightness),
      child: Icon(
        Icons.person,
        size: responsive.isTablet ? 24 : 20,
        color: AppColors.onSurfaceMuted(brightness),
      ),
    );
  }

  Widget _buildNotificationIcon({
    required VoidCallback onTap,
    required Responsive responsive,
    required int unreadCount,
    required Brightness brightness,
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
              color: AppColors.iconButtonFill(brightness),
              border: Border.all(color: AppColors.iconButtonBorder(brightness)),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.onSurface(brightness),
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
