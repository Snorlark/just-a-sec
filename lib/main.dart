import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ✅ Hive dependencies
import 'package:hive_flutter/hive_flutter.dart';
import 'models/story_model.dart';
import 'models/user_model.dart';

// Your existing providers & screens
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_a_sec/models/story_model.dart';
import 'app.dart';
import 'models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Lock app orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ✅ Load dotenv config
  await dotenv.load(fileName: 'assets/images/.env');
  

  // ✅ Initialize Hive
  await Hive.initFlutter();

  // Register adapters with correct typeIds
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(StoryModelAdapter());
  }

  // ✅ Open boxes
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<StoryModel>('storyBox');

  runApp(const JustASecApp());

  // ❌ Removed `runApp(const JustASecApp());`
  // Reason: You already have `MainApp` defined with providers & theme handling.
  // Keeping `JustASecApp` would cause conflicts or duplication.
}

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: ScreenUtilInit(
//         designSize: const Size(412, 715),
//         minTextAdapt: true,
//         splitScreenMode: true,
//         builder: (build, child) {
//           final themeModel = build.watch<ThemeProvider>();
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData.light(),
//             darkTheme: ThemeData.dark(),
//             themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
//             title: 'Blog App', // ❓ Adjust if app title should be "Just A Sec"
//             initialRoute: '/home',
//             routes: {
//               '/home': (context) => HomeScreen(onGoBack: () {
//                 Navigator.pop(context);
//               }),
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:just_a_sec/models/story_model.dart';
// import 'app.dart';
// import 'models/user_model.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Hive.initFlutter();

//   // Register adapters with correct typeIds
//   // Make sure UserModel uses @HiveType(typeId: 0)
//   if (!Hive.isAdapterRegistered(0)) {
//     Hive.registerAdapter(UserModelAdapter());
//   }

//   // Make sure StoryModel uses @HiveType(typeId: 1)
//   if (!Hive.isAdapterRegistered(1)) {
//     Hive.registerAdapter(StoryModelAdapter());
//   }

//   // Open boxes
//   await Hive.openBox<UserModel>('userBox');
//   await Hive.openBox<StoryModel>('storyBox');

//   runApp(const JustASecApp());
// }
