import 'package:flutter/material.dart';

import '../../../../core/ui/responsive/responsive.dart';

enum HomeNavItem { home, feed, sos, walk, account }

class HomeFooter extends StatelessWidget {
  final HomeNavItem selectedItem;
  final ValueChanged<HomeNavItem> onItemSelected;

  const HomeFooter({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final sosButtonSize = responsive.isTablet ? 65.0 : 55.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: sosButtonSize / 2 + responsive.h(1),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildSeparatorLine(responsive, sosButtonSize),
              ),
              Positioned(
                top: 0,
                child: _buildSosButton(context, responsive, sosButtonSize),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            bottom: responsive.h(1.5),
            top: responsive.h(1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Home',
                item: HomeNavItem.home,
                responsive: responsive,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.article_rounded,
                label: 'Feed',
                item: HomeNavItem.feed,
                responsive: responsive,
              ),
              SizedBox(width: sosButtonSize + responsive.w(2)),
              _buildNavItem(
                context: context,
                icon: Icons.directions_walk_rounded,
                label: 'Walk',
                item: HomeNavItem.walk,
                responsive: responsive,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_rounded,
                label: 'Account',
                item: HomeNavItem.account,
                responsive: responsive,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeparatorLine(Responsive responsive, double sosButtonSize) {
    final gapWidth = sosButtonSize + responsive.w(4);

    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: responsive.w(5)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: gapWidth),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required HomeNavItem item,
    required Responsive responsive,
  }) {
    final isSelected = selectedItem == item;

    return GestureDetector(
      onTap: () => onItemSelected(item),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(2),
          vertical: responsive.h(0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: responsive.isTablet ? 26 : 22,
              color: isSelected ? Colors.white : Colors.white54,
            ),
            SizedBox(height: responsive.h(0.2)),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: responsive.isTablet ? 11 : 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButton(
    BuildContext context,
    Responsive responsive,
    double buttonSize,
  ) {
    return GestureDetector(
      onTap: () => onItemSelected(HomeNavItem.sos),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF416C).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                size: responsive.isTablet ? 22 : 18,
                color: Colors.white,
              ),
              Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.isTablet ? 10 : 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
