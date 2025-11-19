import 'package:flutter/material.dart';

class GhostRunning extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const GhostRunning({super.key, this.onAnimationComplete});

  @override
  State<GhostRunning> createState() => _GhostRunningState();
}

class _GhostRunningState extends State<GhostRunning>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _bounce;
  late Animation<double> _fade;
  bool _gifLoaded = false;
  bool _showFallback = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
      if (mounted && !_gifLoaded) {
        setState(() {
          _showFallback = true;
        });
      }
    });


    Future.delayed(const Duration(milliseconds: 2000), () {
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
          Center(
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
                _gifLoaded = true;
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _showFallback = true;
                  });
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A1A2F),
              Color(0xFF134B73),
            ],
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
                    _showFallback ? _buildFallbackLoader() : _buildGifLoader(),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        _showFallback ? "Loading your experience..." : "Ghost is running...",
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
                        "Just a moment",
                        style: TextStyle(
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