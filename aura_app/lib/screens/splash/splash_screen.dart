import 'package:flutter/material.dart';
import '../../components/loading/ghost_running.dart';
import '../onboarding/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _glow = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _startAnimations() {
    _logoController.forward().then((_) {
      _logoController.animateTo(0.96,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      ).then((_) {
        _logoController.animateTo(1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeIn,
        );
      });
    });

    _glowController.repeat(reverse: true);
    _particleController.repeat();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _shimmerController.repeat();
    });

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

    Future.delayed(const Duration(milliseconds: 4800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                GhostRunning(
                  onAnimationComplete: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                        const WelcomeScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                CurvedAnimation(parent: animation, curve: Curves.easeOut),
                              ),
                              child: child,
                            ),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 1000),
                        reverseTransitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
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

  Widget _buildAnimatedLine(String letter, String word, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: controller.value,
          child: Transform.translate(
            offset: Offset(0, 45 * (1 - controller.value)),
            child: Transform.scale(
              scale: 0.75 + (0.25 * controller.value),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.98),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          fontFamily: 'monospace',
                          shadows: [
                            Shadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '–',
                        style: TextStyle(
                          color: Colors.cyan.withOpacity(0.7),
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Text(
                      word,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 19,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.blue.withOpacity(0.3),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0A1A2F),
              const Color(0xFF0E2A4A),
              const Color(0xFF134B73),
              Colors.blue.shade900.withOpacity(0.3),
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
                  AnimatedBuilder(
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
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(_glow.value * 0.9),
                                        blurRadius: 70,
                                        spreadRadius: 12,
                                      ),
                                      BoxShadow(
                                        color: Colors.cyan.withOpacity(_glow.value * 0.7),
                                        blurRadius: 90,
                                        spreadRadius: 18,
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(_glow.value * 0.5),
                                        blurRadius: 50,
                                        spreadRadius: 8,
                                      ),
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(_glow.value * 0.4),
                                        blurRadius: 110,
                                        spreadRadius: 25,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
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
                                            Colors.white.withOpacity(0.3),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.srcATop,
                                      child: Image.asset(
                                        'assets/logos/Aura-logo.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.shade500,
                                                  Colors.blue.shade700,
                                                  Colors.blue.shade900,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'AURA',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 4,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 70),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAnimatedLine("A", "Aware", _line1Controller),
                      const SizedBox(height: 14),
                      _buildAnimatedLine("U", "United", _line2Controller),
                      const SizedBox(height: 14),
                      _buildAnimatedLine("R", "Robust", _line3Controller),
                      const SizedBox(height: 14),
                      _buildAnimatedLine("A", "Assure", _line4Controller),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final xPos = (size.width * 0.08 * i + 30) % size.width;
      final yPos = ((size.height * 0.65) +
          (animationValue * size.height * 0.35 + i * 45)) % size.height;

      final offset = Offset(xPos, yPos);
      final opacity = (0.12 + (i % 4) * 0.06) *
          (1 - ((animationValue + i * 0.04) % 1.0));

      paint.color = Colors.blue.withOpacity(opacity);
      canvas.drawCircle(offset, 2.5 + (i % 3).toDouble(), paint);
    }

    for (int i = 0; i < 18; i++) {
      final xPos = (size.width * 0.12 * i + 80) % size.width;
      final yPos = ((size.height * 0.4) +
          (animationValue * size.height * 0.45 + i * 65)) % size.height;

      final offset = Offset(xPos, yPos);
      final opacity = (0.1 + (i % 3) * 0.05) *
          (1 - ((animationValue + i * 0.06) % 1.0));

      paint.color = Colors.cyan.withOpacity(opacity);
      canvas.drawCircle(offset, 2 + (i % 2).toDouble(), paint);
    }

    for (int i = 0; i < 12; i++) {
      final xPos = (size.width * 0.15 * i + 150) % size.width;
      final yPos = ((size.height * 0.55) +
          (animationValue * size.height * 0.4 + i * 70)) % size.height;

      final offset = Offset(xPos, yPos);
      final opacity = (0.08 + (i % 2) * 0.04) *
          (1 - ((animationValue + i * 0.08) % 1.0));

      paint.color = Colors.purple.withOpacity(opacity);
      canvas.drawCircle(offset, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}