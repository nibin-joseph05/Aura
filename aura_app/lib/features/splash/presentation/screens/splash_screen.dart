import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/state/app_ui_ready_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loading/ghost_running.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _line1Controller;
  late AnimationController _line2Controller;
  late AnimationController _line3Controller;
  late AnimationController _line4Controller;
  late AnimationController _particleController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  late Animation<double> _glow;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _initializeAnimationControllers() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _line1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _line2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _line3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _line4Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _initializeAnimations() {
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _glow = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _logoController.forward().then((_) {
      _logoController
          .animateTo(
            0.96,
            duration: AppConstants.shortAnimation,
            curve: Curves.easeOut,
          )
          .then((_) {
            _logoController.animateTo(
              1.0,
              duration: AppConstants.shortAnimation,
              curve: Curves.easeIn,
            );
          });
    });

    _glowController.repeat(reverse: true);
    _particleController.repeat();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _shimmerController.repeat();
    });

    _animateLines();
    _navigateToNextScreen();
  }

  void _animateLines() {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _line1Controller.forward();
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _line2Controller.forward();
    });
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) _line3Controller.forward();
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _line4Controller.forward();
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 4800), () {
      if (!mounted) return;

      ref.read(appUiReadyProvider.notifier).state = true;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => GhostRunning(
            onAnimationComplete: () {
              Navigator.pushReplacementNamed(context, AppRoutes.welcome);
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppConstants.longAnimation,
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _line3Controller.dispose();
    _line4Controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedLine(
    String letter,
    String word,
    AnimationController controller,
    Responsive responsive,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: controller.value,
          child: Transform.translate(
            offset: Offset(0, responsive.h(5) * (1 - controller.value)),
            child: Transform.scale(
              scale: 0.75 + (0.25 * controller.value),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: responsive.space(26),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: AppTextStyles.textTheme.headlineMedium!.copyWith(
                          color: AppColors.textLight.withValues(alpha: 0.98),

                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withValues(alpha: 0.5),

                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.space(AppDimensions.paddingS),
                      ),
                      child: Text(
                        '–',
                        style: AppTextStyles.textTheme.headlineMedium!.copyWith(
                          color: AppColors.accent.withValues(alpha: 0.7),

                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Text(
                      word,
                      style: AppTextStyles.textTheme.headlineMedium!.copyWith(
                        color: AppColors.textLight.withValues(alpha: 0.92),

                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: AppColors.textLight.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Scaffold(
      backgroundColor: AppColors.splashDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.splashDark,
              AppColors.splashMedium,
              AppColors.splashLight,
              AppColors.primaryDark.withValues(alpha: 0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    animationValue: _particleController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(responsive),
                  SizedBox(height: responsive.h(8)),
                  _buildAnimatedText(responsive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(Responsive responsive) {
    final logoSize = responsive.space(180);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _glowController,
        _shimmerController,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.rotate(
            angle: _logoRotation.value,
            child: Transform.scale(
              scale: _logoScale.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildGlowEffect(logoSize),
                  _buildLogoContainer(logoSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowEffect(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: _glow.value * 0.9),

            blurRadius: 70,
            spreadRadius: 12,
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: _glow.value * 0.7),

            blurRadius: 90,
            spreadRadius: 18,
          ),
          BoxShadow(
            color: AppColors.textLight.withValues(alpha: _glow.value * 0.5),

            blurRadius: 50,
            spreadRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoContainer(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textLight.withValues(alpha: 0.15),

          width: 2.5,
        ),
      ),
      child: ClipOval(
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_shimmer.value - 1, 0),
              end: Alignment(_shimmer.value, 0),
              colors: [
                Colors.transparent,
                AppColors.primaryDark.withValues(alpha: 0.3),

                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Image.asset(
            AssetConstants.auraLogo,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackLogo();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          AppConstants.appName.toUpperCase(),
          style: AppTextStyles.textTheme.displayMedium!.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(Responsive responsive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAnimatedLine("A", "Aware", _line1Controller, responsive),
        SizedBox(height: responsive.space(AppDimensions.marginM)),
        _buildAnimatedLine("U", "United", _line2Controller, responsive),
        SizedBox(height: responsive.space(AppDimensions.marginM)),
        _buildAnimatedLine("R", "Robust", _line3Controller, responsive),
        SizedBox(height: responsive.space(AppDimensions.marginM)),
        _buildAnimatedLine("A", "Assure", _line4Controller, responsive),
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    _drawParticleSet(canvas, size, paint, 25, AppColors.primary, 0.08, 0.65);
    _drawParticleSet(canvas, size, paint, 18, AppColors.accent, 0.12, 0.4);
    _drawParticleSet(
      canvas,
      size,
      paint,
      12,
      AppColors.primaryLight,
      0.15,
      0.55,
    );
  }

  void _drawParticleSet(
    Canvas canvas,
    Size size,
    Paint paint,
    int count,
    Color baseColor,
    double xFactor,
    double yFactor,
  ) {
    for (int i = 0; i < count; i++) {
      final xPos = (size.width * xFactor * i + 30) % size.width;
      final yPos =
          ((size.height * yFactor) +
              (animationValue * size.height * 0.35 + i * 45)) %
          size.height;

      final offset = Offset(xPos, yPos);
      final opacity =
          (0.12 + (i % 4) * 0.06) * (1 - ((animationValue + i * 0.04) % 1.0));

      paint.color = baseColor.withValues(alpha: opacity);

      canvas.drawCircle(offset, 2.5 + (i % 3).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
