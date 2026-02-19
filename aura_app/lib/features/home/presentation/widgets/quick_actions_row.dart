import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onSOS;
  final VoidCallback onCreatePost;
  final VoidCallback onWellnessFeed;
  final VoidCallback? onAlarm;
  final VoidCallback? onChat;
  final VoidCallback? onWalking;

  const QuickActionsRow({
    super.key,
    required this.onSOS,
    required this.onCreatePost,
    required this.onWellnessFeed,
    this.onAlarm,
    this.onChat,
    this.onWalking,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _AnimatedActionButton(
                icon: Icons.warning_rounded,
                label: 'SOS',
                colors: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                onTap: onSOS,
                responsive: responsive,
              ),
            ),
            SizedBox(width: responsive.w(2.5)),
            Expanded(
              child: _AnimatedActionButton(
                icon: Icons.add_circle_outline,
                label: 'Post',
                colors: [AppColors.primary, AppColors.accent],
                onTap: onCreatePost,
                responsive: responsive,
              ),
            ),
            SizedBox(width: responsive.w(2.5)),
            Expanded(
              child: _AnimatedActionButton(
                icon: Icons.explore_outlined,
                label: 'Feed',
                colors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                onTap: onWellnessFeed,
                responsive: responsive,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.h(1.5)),
        Row(
          children: [
            Expanded(
              child: _AnimatedActionButton(
                icon: Icons.alarm_rounded,
                label: 'Alarms',
                colors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                onTap: onAlarm ?? () {},
                responsive: responsive,
              ),
            ),
            SizedBox(width: responsive.w(2.5)),
            Expanded(
              child: _AnimatedActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                colors: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
                onTap: onChat ?? () {},
                responsive: responsive,
              ),
            ),
            SizedBox(width: responsive.w(2.5)),
            Expanded(
              child: _AnimatedActionButton(
                icon: Icons.directions_walk_rounded,
                label: 'Walking',
                colors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                onTap: onWalking ?? () {},
                responsive: responsive,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;
  final Responsive responsive;

  const _AnimatedActionButton({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    required this.responsive,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: widget.responsive.h(2)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.colors[0].withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: widget.responsive.isTablet ? 28 : 24,
              ),
              SizedBox(height: widget.responsive.h(0.5)),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.responsive.isTablet ? 13 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
