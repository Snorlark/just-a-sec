import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_a_sec/models/story_model.dart';
import 'app.dart';
import 'models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters with correct typeIds
  // Make sure UserModel uses @HiveType(typeId: 0)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  // Make sure StoryModel uses @HiveType(typeId: 1)
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(StoryModelAdapter());
  }

  // Open boxes
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<StoryModel>('storyBox');

  runApp(const JustASecApp());
}
