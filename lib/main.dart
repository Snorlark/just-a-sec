import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ Hive dependencies
import 'package:hive_flutter/hive_flutter.dart';
import 'models/story_model.dart';
import 'models/user_model.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Lock app orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ✅ Load dotenv config
  await dotenv.load(fileName: './.env');
  

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
  final settingsBox = await Hive.openBox('settingsBox');
  final initialDark = settingsBox.get('darkMode') == true;

  runApp(JustASecApp(initialDark: initialDark));

}