import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';

class AppHeader extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color textColor;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.textColor = Colors.white,
  });

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    final titleSize = responsive.isLargeTablet
        ? 32.0
        : responsive.isTablet
        ? 28.0
        : 24.0;

    final subtitleSize = responsive.isTablet ? 16.0 : 14.0;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: EdgeInsets.only(
            top: responsive.h(1.8),
            left: responsive.w(4),
            right: responsive.w(4),
            bottom: responsive.h(1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildBackButton(context, responsive),
                  SizedBox(width: responsive.w(4.5)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: widget.textColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: widget.textColor.withOpacity(0.7),
                            height: 1.1,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (widget.actions != null) Row(children: widget.actions!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, Responsive responsive) {
    final size = responsive.isTablet ? 26.0 : 22.0;

    return GestureDetector(
      onTap: widget.onBack ?? () => Navigator.pop(context),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: 1.0,
        curve: Curves.easeOutBack,
        child: Container(
          padding: EdgeInsets.all(responsive.isTablet ? 7 : 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              BoxShadow(color: Colors.white.withOpacity(0.10), blurRadius: 6),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: size,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}
