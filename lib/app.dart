import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'screens/main_nav_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

class JustASecApp extends StatelessWidget {
  const JustASecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just A Sec',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/register': (_) => const RegisterScreen(),
        '/main': (_) => const MainNavScreen(),
      },
    );
  }
}
