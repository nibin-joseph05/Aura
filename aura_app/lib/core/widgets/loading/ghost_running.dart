import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../ui/responsive/responsive.dart';

class GhostRunningState {
  final bool gifLoaded;
  final bool showFallback;

  const GhostRunningState({this.gifLoaded = false, this.showFallback = false});

  GhostRunningState copyWith({bool? gifLoaded, bool? showFallback}) {
    return GhostRunningState(
      gifLoaded: gifLoaded ?? this.gifLoaded,
      showFallback: showFallback ?? this.showFallback,
    );
  }
}

class GhostRunningNotifier extends StateNotifier<GhostRunningState> {
  GhostRunningNotifier() : super(const GhostRunningState());

  void setGifLoaded(bool loaded) {
    state = state.copyWith(gifLoaded: loaded);
  }

  void setShowFallback(bool show) {
    state = state.copyWith(showFallback: show);
  }

  void reset() {
    state = const GhostRunningState();
  }
}

final ghostRunningProvider =
    StateNotifierProvider.autoDispose<GhostRunningNotifier, GhostRunningState>(
      (ref) => GhostRunningNotifier(),
    );

class GhostRunning extends ConsumerStatefulWidget {
  final VoidCallback? onAnimationComplete;

  final String? primaryMessage;

  final String? secondaryMessage;

  final Color? backgroundColor;

  final List<Color>? gradientColors;

  final Duration? animationDuration;

  const GhostRunning({
    super.key,
    this.onAnimationComplete,
    this.primaryMessage,
    this.secondaryMessage,
    this.backgroundColor,
    this.gradientColors,
    this.animationDuration,
  });

  @override
  ConsumerState<GhostRunning> createState() => _GhostRunningState();
}

class _GhostRunningState extends ConsumerState<GhostRunning>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupTimers();
  }

  void _initializeAnimations() {
    final duration = widget.animationDuration ?? AppConstants.longAnimation;

    _controller = AnimationController(vsync: this, duration: duration);

    _bounce = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  void _setupTimers() {
    Future.delayed(AppConstants.mediumAnimation, () {
      if (mounted && !ref.read(ghostRunningProvider).gifLoaded) {
        ref.read(ghostRunningProvider.notifier).setShowFallback(true);
      }
    });

    final duration = widget.animationDuration ?? AppConstants.longAnimation;
    Future.delayed(duration, () {
      if (mounted && widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFallbackLoader(Responsive responsive) {
    final size = responsive.space(80);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.6),
            blurRadius: responsive.space(15),
            spreadRadius: responsive.space(3),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.all(
                  responsive.space(8) +
                      (responsive.space(4) * _controller.value),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textLight.withValues(
                    alpha: 0.2 * _controller.value,
                  ),
                ),
              );
            },
          ),
          Center(
            child: Icon(
              Icons.bolt,
              color: AppColors.textLight,
              size: responsive.icon(AppDimensions.iconL),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGifLoader(Responsive responsive) {
    final size = responsive.space(80);

    return Transform.translate(
      offset: Offset(0, _bounce.value),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: responsive.space(15),
              spreadRadius: responsive.space(3),
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: responsive.space(25),
              spreadRadius: responsive.space(5),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            AssetConstants.ghostRunning,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ref.read(ghostRunningProvider.notifier).setGifLoaded(true);
                  }
                });
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(ghostRunningProvider.notifier).setShowFallback(true);
                });
              }
              return _buildFallbackLoader(responsive);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final loadingState = ref.watch(ghostRunningProvider);

    final primaryMsg = widget.primaryMessage ?? "Loading your experience...";
    final secondaryMsg = widget.secondaryMessage ?? "Just a moment";

    final bgColor = widget.backgroundColor ?? AppColors.splashDark;
    final gradientColors = widget.gradientColors ?? AppColors.splashGradient;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fade.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    loadingState.showFallback
                        ? _buildFallbackLoader(responsive)
                        : _buildGifLoader(responsive),

                    SizedBox(height: responsive.space(AppDimensions.marginL)),

                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        primaryMsg,
                        style: AppTextStyles.textTheme.bodyLarge!.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: responsive.space(AppDimensions.marginS)),

                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        secondaryMsg,
                        style: AppTextStyles.textTheme.bodyMedium!.copyWith(
                          color: AppColors.textLight.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
