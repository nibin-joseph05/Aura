import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../core/widgets/loading/ghost_running.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../messaging/data/service/messaging_api_service.dart';
import '../../presentation/providers/profile_image_provider.dart';
import '../../presentation/providers/user_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _followStatus;
  bool _isLoading = true;
  bool _isFollowLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _api = MessagingApiService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadProfile();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String? _buildImageUrl(String? path, {int? cacheBust}) {
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
    if (cacheBust != null) return '$url?v=$cacheBust';
    return url;
  }

  Future<void> _loadProfile() async {
    try {
      final currentUserId = ref.read(userProvider).user?.uid ?? '';
      final dio = _api;

      final results = await Future.wait([
        dio.getUserProfile(widget.userId),
        dio.getFollowStatus(currentUserId, widget.userId),
      ]);

      setState(() {
        _profile = results[0];
        _followStatus = results[1];
      });

      setState(() {
        _isLoading = false;
      });
      _animController.forward();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(
          context: context,
          message: 'Failed to load profile',
        );
      }
    }
  }

  Future<void> _handleFollowAction() async {
    if (_isFollowLoading) return;
    setState(() => _isFollowLoading = true);

    final currentUserId = ref.read(userProvider).user?.uid ?? '';
    final status = _followStatus?['status'] ?? 'NONE';

    try {
      if (status == 'NONE' || status == 'REJECTED') {
        await _api.sendFollowRequest(currentUserId, widget.userId);
        AppSnackbar.showSuccess(
          context: context,
          message: 'Follow request sent',
        );
      } else if (status == 'ACCEPTED') {
        await _api.unfollow(currentUserId, widget.userId);
        AppSnackbar.showInfo(context: context, message: 'Unfollowed');
      }

      final newStatus = await _api.getFollowStatus(
        currentUserId,
        widget.userId,
      );
      setState(() => _followStatus = newStatus);
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context: context, message: 'Action failed');
      }
    } finally {
      if (mounted) setState(() => _isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final userState = ref.watch(userProvider);
    final imgState = ref.watch(profileImageProvider);
    final isOwnProfile = widget.userId == userState.user?.uid;
    final brightness = Theme.of(context).brightness;

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
              AppHeader(
                title: _profile?['username'] ?? 'Profile',
                actions: isOwnProfile
                    ? [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editProfile,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.iconButtonFill(brightness),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: AppColors.onSurface(brightness),
                              size: 18,
                            ),
                          ),
                        ),
                      ]
                    : null,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: GhostRunning())
                    : FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildProfileContent(
                          responsive,
                          userState,
                          isOwnProfile,
                          imgState,
                          brightness,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    Responsive responsive,
    dynamic userState,
    bool isOwnProfile,
    ProfileImageState imgState,
    Brightness brightness,
  ) {
    final user = isOwnProfile ? userState.user : null;
    final name = user?.name ?? _profile?['name'] ?? '';
    final username = user?.username ?? _profile?['username'] ?? '';
    final bio = user?.bio ?? _profile?['bio'] ?? '';
    final profileImageUrl = _buildImageUrl(
      isOwnProfile
          ? (imgState.imageUrl ?? user?.profileImageUrl)
          : _profile?['profileImageUrl'],
      cacheBust: isOwnProfile ? imgState.uploadedAt : null,
    );
    final followersCount =
        _profile?['followersCount'] ?? user?.followersCount ?? 0;
    final followingCount =
        _profile?['followingCount'] ?? user?.followingCount ?? 0;
    final postsCount = _profile?['postsCount'] ?? user?.postsCount ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: responsive.w(5)),
      child: Column(
        children: [
          SizedBox(height: responsive.h(3)),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.containerBorder(brightness),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: profileImageUrl != null
                  ? Image.network(
                      profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildAvatarPlaceholder(brightness),
                    )
                  : _buildAvatarPlaceholder(brightness),
            ),
          ),
          SizedBox(height: responsive.h(1.5)),
          Text(
            name,
            style: TextStyle(
              color: AppColors.onSurface(brightness),
              fontSize: responsive.isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: TextStyle(
              color: AppColors.onSurfaceMuted(brightness),
              fontSize: responsive.isTablet ? 15 : 13,
            ),
          ),
          if (bio.toString().isNotEmpty) ...[
            SizedBox(height: responsive.h(1)),
            Text(
              bio.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: responsive.isTablet ? 14 : 12,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: responsive.h(2.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Posts', postsCount, responsive, brightness),
              _buildStatDivider(brightness),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.followers,
                  arguments: widget.userId,
                ),
                child: _buildStatItem(
                  'Followers',
                  followersCount,
                  responsive,
                  brightness,
                ),
              ),
              _buildStatDivider(brightness),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.following,
                  arguments: widget.userId,
                ),
                child: _buildStatItem(
                  'Following',
                  followingCount,
                  responsive,
                  brightness,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(2.5)),
          if (!isOwnProfile) ...[
            _buildFollowButton(responsive, brightness),
            SizedBox(height: responsive.h(1)),
            if (_followStatus?['isMutual'] == true)
              _buildMessageButton(responsive, brightness),
          ],
          SizedBox(height: responsive.h(3)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    dynamic count,
    Responsive responsive,
    Brightness brightness,
  ) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: AppColors.onSurface(brightness),
            fontSize: responsive.isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.onSurfaceMuted(brightness),
            fontSize: responsive.isTablet ? 13 : 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(Brightness brightness) {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.containerBorder(brightness),
    );
  }

  Widget _buildFollowButton(Responsive responsive, Brightness brightness) {
    final status = _followStatus?['status'] ?? 'NONE';

    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'ACCEPTED':
        label = 'Following';
        bgColor = AppColors.iconButtonFill(brightness);
        textColor = AppColors.onSurface(brightness);
        break;
      case 'PENDING':
        label = 'Requested';
        bgColor = AppColors.containerFill(brightness);
        textColor = AppColors.onSurfaceMuted(brightness);
        break;
      default:
        label = 'Follow';
        bgColor = AppColors.accent;
        textColor = Colors.white;
    }

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: status == 'PENDING' ? null : _handleFollowAction,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: responsive.h(1.5)),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.containerBorder(brightness)),
          ),
          child: Center(
            child: _isFollowLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onSurface(brightness),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: responsive.isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageButton(Responsive responsive, Brightness brightness) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () async {
          final currentUserId = ref.read(userProvider).user?.uid ?? '';
          try {
            final conv = await _api.getOrCreateConversation(
              currentUserId,
              widget.userId,
            );
            if (mounted) {
              Navigator.pushNamed(
                context,
                AppRoutes.chatScreen,
                arguments: {
                  'conversationId': conv['id'],
                  'otherUserId': widget.userId,
                },
              );
            }
          } catch (e) {
            if (mounted) {
              AppSnackbar.showError(
                context: context,
                message: 'Cannot start conversation',
              );
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: responsive.h(1.5)),
          decoration: BoxDecoration(
            color: AppColors.containerFill(brightness),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.containerBorder(brightness)),
          ),
          child: Center(
            child: Text(
              'Message',
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: responsive.isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(Brightness brightness) {
    return Container(
      color: AppColors.iconButtonFill(brightness),
      child: Icon(
        Icons.person,
        size: 40,
        color: AppColors.onSurfaceFaint(brightness),
      ),
    );
  }
}
