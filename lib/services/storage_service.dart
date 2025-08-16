import 'package:hive/hive.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _userBoxName = 'userBox';

  /// Opens the box (or returns it if already open)
  Future<Box<UserModel>> _openUserBox() async {
    if (Hive.isBoxOpen(_userBoxName)) {
      return Hive.box<UserModel>(_userBoxName);
    }
    return await Hive.openBox<UserModel>(_userBoxName);
  }

  /// Save user data (e.g. after login or signup)
  Future<void> saveUser(UserModel user) async {
    final box = await _openUserBox();
    await box.put('currentUser', user);
  }

  /// Get the current saved user
  Future<UserModel?> getUser() async {
    final box = await _openUserBox();
    return box.get('currentUser');
  }

  /// Delete user data (e.g. on logout)
  Future<void> clearUser() async {
    final box = await _openUserBox();
    await box.delete('currentUser');
  }

  /// Check if a user is saved
  Future<bool> hasUser() async {
    final box = await _openUserBox();
    return box.containsKey('currentUser');
  }
}
