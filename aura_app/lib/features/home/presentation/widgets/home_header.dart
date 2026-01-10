import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../user/presentation/providers/user_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String? _buildFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final base = AppConfig.baseUrl;
    return '$base/uploads/$path';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final profileImageUrl = _buildFullImageUrl(user?.profileImageUrl);

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
              GestureDetector(
                onTap: () {},
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
}
