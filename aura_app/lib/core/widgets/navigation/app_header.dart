import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/responsive/responsive.dart';

class AppHeader extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color textColor;
  final bool showBack;
  final bool compact;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.textColor = Colors.white,
    this.showBack = true,
    this.compact = false,
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

    final titleSize = widget.compact
        ? (responsive.isTablet ? 20.0 : 18.0)
        : (responsive.isLargeTablet
              ? 32.0
              : responsive.isTablet
              ? 28.0
              : 22.0);

    final subtitleSize = responsive.isTablet ? 14.0 : 12.0;

    final verticalPadding = widget.compact
        ? responsive.h(1.0)
        : responsive.h(1.5);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: EdgeInsets.only(
            top: verticalPadding,
            left: responsive.w(4),
            right: responsive.w(4),
            bottom: verticalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (widget.showBack) ...[
                      _buildBackButton(context, responsive),
                      SizedBox(width: responsive.w(3)),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: widget.textColor,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: widget.textColor.withValues(alpha: 0.7),
                                height: 1.1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.actions != null) Row(children: widget.actions!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, Responsive responsive) {
    final size = responsive.isTablet ? 24.0 : 20.0;

    return GestureDetector(
      onTap: widget.onBack ?? () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(responsive.isTablet ? 6 : 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: size,
          color: widget.textColor,
        ),
      ),
    );
  }
}
