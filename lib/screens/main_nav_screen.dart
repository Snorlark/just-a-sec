import 'package:flutter/material.dart';
import 'package:just_a_sec/widgets/responsive_container_widget.dart';

import '../config/app_spacing.dart';
import '../custom/custom_rounded_navbar.dart';
import 'gallery_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  void jumpToPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // optional: disable swipe
        onPageChanged: (page) {
          setState(() => _currentIndex = page);
        },
        children: [
          // Home
          SafeArea(
            child: ResponsiveContainerWidget(
              child: _buildAnimatedPage(
                HomeScreen(
                  onGoBack:
                      () => jumpToPage(1), // jump to gallery when caret pressed
                ),
                key: const ValueKey('home'),
              ),
            ),
          ),
          // Gallery
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
              ),
              child: _buildAnimatedPage(
                const GalleryScreen(),
                key: const ValueKey('gallery'),
              ),
            ),
          ),
          // Profile
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
              ),
              child: _buildAnimatedPage(
                const ProfileScreen(),
                key: const ValueKey('profile'),
              ),
            ),
          ),
        ],
      ),

      // Show nav bar only if not on home screen
      bottomNavigationBar:
          _currentIndex == 0
              ? null
              : CustomRoundedNavBar(
                currentIndex: _currentIndex,
                onTap: (value) => jumpToPage(value),
              ),
    );
  }
}

Widget _buildAnimatedPage(Widget page, {Key? key}) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 600),
    transitionBuilder: (child, animation) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    child: KeyedSubtree(key: key, child: page),
  );
}
