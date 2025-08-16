import 'dart:ui';

import 'package:flutter/material.dart';

import '../config/app_spacing.dart';

class CustomRoundedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomRoundedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Responsive sizing
    final navBarHeight =
        70.0 + (bottomPadding > 0 ? bottomPadding : AppSpacing.margin);
    final iconSize = screenWidth > 400 ? 32.0 : 30.0;
    final circleSize = screenWidth > 400 ? 50.0 : 45.0;

    return Container(
      height: navBarHeight,
      padding: EdgeInsets.only(
        left: AppSpacing.margin,
        right: AppSpacing.margin,
        bottom: bottomPadding > 0 ? bottomPadding : AppSpacing.margin,
        top: AppSpacing.margin / 2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3), // Coffee brown
              borderRadius: BorderRadius.circular(35),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.camera_alt_outlined,
                  isSelected: currentIndex == 0,
                  circleSize: circleSize,
                  iconSize: iconSize,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.photo_library_outlined,
                  isSelected: currentIndex == 1,
                  circleSize: circleSize,
                  iconSize: iconSize,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline,
                  isSelected: currentIndex == 2,
                  circleSize: circleSize,
                  iconSize: iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isSelected,
    required double circleSize,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color:
              isSelected
                  ? const Color(0xFF5D4E37) // Dark brown when selected
                  : Colors.white, // White when unselected
        ),
      ),
    );
  }
}
