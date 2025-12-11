import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class GhostRunningState {
  final bool gifLoaded;
  final bool showFallback;

  const GhostRunningState({
    this.gifLoaded = false,
    this.showFallback = false,
  });

  GhostRunningState copyWith({
    bool? gifLoaded,
    bool? showFallback,
  }) {
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

    final duration = widget.animationDuration ?? const Duration(milliseconds: 2000);

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

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


    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !ref.read(ghostRunningProvider).gifLoaded) {
        ref.read(ghostRunningProvider.notifier).setShowFallback(true);
      }
    });


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

  Widget _buildFallbackLoader() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
            Colors.blue.shade900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [

          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.all(8 + (4 * _controller.value)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2 * _controller.value),
                ),
              );
            },
          ),
          const Center(
            child: Icon(
              Icons.bolt,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGifLoader() {
    return Transform.translate(
      offset: Offset(0, _bounce.value),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.cyan.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            "assets/animations/ghost-running.gif",
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
              return _buildFallbackLoader();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingState = ref.watch(ghostRunningProvider);


    final primaryMsg = widget.primaryMessage ??
        (loadingState.showFallback
            ? "Loading your experience..."
            : "Loading your experience...");

    final secondaryMsg = widget.secondaryMessage ?? "Just a moment";


    final bgColors = widget.gradientColors ??
        [
          const Color(0xFF0A1A2F),
          const Color(0xFF134B73),
        ];

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? const Color(0xFF0A1A2F),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
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
                        ? _buildFallbackLoader()
                        : _buildGifLoader(),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        primaryMsg,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        secondaryMsg,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
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