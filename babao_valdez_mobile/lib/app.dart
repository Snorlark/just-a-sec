import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'screens/main_nav_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';

class JustASecApp extends StatelessWidget {
  const JustASecApp({super.key, this.initialDark = false});

  final bool initialDark;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialDark: initialDark),
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final themeModel = context.watch<ThemeProvider>();
          return MaterialApp(
            title: 'Just A Sec',
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            darkTheme: darkTheme,
            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/register': (_) => const RegisterScreen(),
              '/main': (_) => const MainNavScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/login': (_) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
