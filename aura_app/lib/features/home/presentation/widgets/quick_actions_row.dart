import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onSOS;
  final VoidCallback onCreatePost;
  final VoidCallback onWellnessFeed;

  const QuickActionsRow({
    super.key,
    required this.onSOS,
    required this.onCreatePost,
    required this.onWellnessFeed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            responsive,
            icon: Icons.warning_rounded,
            label: 'SOS',
            colors: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
            onTap: onSOS,
          ),
        ),
        SizedBox(width: responsive.w(3)),
        Expanded(
          child: _buildActionButton(
            responsive,
            icon: Icons.add_circle_outline,
            label: 'Post',
            colors: [AppColors.primary, AppColors.accent],
            onTap: onCreatePost,
          ),
        ),
        SizedBox(width: responsive.w(3)),
        Expanded(
          child: _buildActionButton(
            responsive,
            icon: Icons.explore_outlined,
            label: 'Feed',
            colors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
            onTap: onWellnessFeed,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    Responsive responsive, {
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: responsive.h(2)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: responsive.isTablet ? 28 : 24,
            ),
            SizedBox(height: responsive.h(0.5)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.isTablet ? 13 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
