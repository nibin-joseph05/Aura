import 'package:flutter/material.dart';

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

    final actions = [
      _ActionData(
        icon: Icons.add_circle_outline_rounded,
        label: 'Share Vibe',
        colors: const [Color(0xFF2196F3), Color(0xFF00BCD4)],
        onTap: onCreatePost,
      ),
      _ActionData(
        icon: Icons.warning_amber_rounded,
        label: 'SOS',
        colors: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
        onTap: onSOS,
      ),
      _ActionData(
        icon: Icons.alarm_rounded,
        label: 'Alarms',
        colors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
        onTap: onAlarm ?? () {},
      ),
      _ActionData(
        icon: Icons.directions_walk_rounded,
        label: 'Walk',
        colors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
        onTap: onWalking ?? () {},
      ),
      _ActionData(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Messages',
        colors: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
        onTap: onChat ?? () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: responsive.h(1.5)),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: responsive.isTablet ? 96 : 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (_, __) => SizedBox(width: responsive.w(3)),
            itemBuilder: (context, index) {
              return _QuickActionCard(
                data: actions[index],
                responsive: responsive,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });
}

class _QuickActionCard extends StatefulWidget {
  final _ActionData data;
  final Responsive responsive;

  const _QuickActionCard({required this.data, required this.responsive});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final d = widget.data;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        d.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: r.isTablet ? 96 : 80,
          height: r.isTablet ? 96 : 84,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: d.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: d.colors[0].withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: r.isTablet ? 44 : 38,
                height: r.isTablet ? 44 : 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  d.icon,
                  color: Colors.white,
                  size: r.isTablet ? 24 : 20,
                ),
              ),
              SizedBox(height: r.h(0.7)),
              Text(
                d.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: r.isTablet ? 11 : 10,
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
