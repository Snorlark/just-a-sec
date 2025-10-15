import 'package:flutter/material.dart';

import '../config/app_spacing.dart';
import '../custom/custom_button_widget.dart';
import '../custom/custom_transition.dart';
import '../widgets/responsive_container_widget.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final loggedIn = await UserService().isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ResponsiveContainerWidget(
            child: Padding(
              padding: AppSpacing.allMargin,
              child: Column(
                children: [
                  const Spacer(),

                  Image.asset(
                    'assets/images/splash_text.png',
                    width: MediaQuery.of(context).size.width * 0.7,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: AppSpacing.gutter),
                  CustomButtonWidget(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),

                  const Spacer(),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Created by Lark and Angelique',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
