import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/theme.dart';
import 'screens/main_nav_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

class JustASecApp extends StatelessWidget {
  const JustASecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Just A Sec',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/register': (_) => const RegisterScreen(),
          '/main': (_) => const MainNavScreen(),
        },
      ),
    );
  }
}
