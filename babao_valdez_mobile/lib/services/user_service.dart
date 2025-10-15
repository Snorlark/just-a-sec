import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class UserService {
  Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    // Response response = await post(
    final response = await http.post(
      Uri.parse('$host/api/users/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      return data;
    } else {
      print(data);
      throw Exception('Failed to load data');
    }
  }

  // Register user via API
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String age,
    required String gender,
    required String contactNumber,
    required String email,
    required String username,
    required String address,
    String? type,
    bool? isActive,
    String? password,
  }) async {
    final response = await http.post(
      Uri.parse('$host/api/users/'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'gender': gender,
        'contactNumber': contactNumber,
        'email': email,
        'username': username,
        'address': address,
        if (type != null) 'type': type,
        if (isActive != null) 'isActive': isActive.toString(),
        if (password != null) 'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Registration failed: ${response.statusCode}');
    }
  }

  // Save data into SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Some APIs wrap the user in { user: {..}, token: '...' }
    final user = (userData['user'] is Map) ? (userData['user'] as Map).cast<String, dynamic>() : userData;

    await prefs.setString('token', (userData['token'] ?? user['token'] ?? '').toString());
    // IDs can be returned as _id or id
    final dynamicId = (user['_id'] ?? user['id'] ?? '').toString();
    await prefs.setString('id', dynamicId);
    await prefs.setString('firstName', (user['firstName'] ?? '').toString());
    await prefs.setString('lastName', (user['lastName'] ?? '').toString());
    await prefs.setString('username', (user['username'] ?? '').toString());
    await prefs.setString('email', (user['email'] ?? '').toString());
    await prefs.setString('age', (user['age'] ?? '').toString());
    await prefs.setString('gender', (user['gender'] ?? '').toString());
    await prefs.setString('contactNumber', (user['contactNumber'] ?? '').toString());
    await prefs.setString('address', (user['address'] ?? '').toString());
    await prefs.setString('type', (user['type'] ?? '').toString());
    await prefs.setBool('isActive', (user['isActive'] ?? true) == true);
    // Optional: profile picture fields if backend provides
    if (user.containsKey('profilePictureUrl')) {
      await prefs.setString('profilePictureUrl', (user['profilePictureUrl'] ?? '').toString());
    }
    if (user.containsKey('profilePicturePath')) {
      await prefs.setString('profilePicturePath', (user['profilePicturePath'] ?? '').toString());
    }
  }

  // Retrieve User Data from SharedPreferences
  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token') ?? '',
      'id': prefs.getString('id') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'age': prefs.getString('age') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'contactNumber': prefs.getString('contactNumber') ?? '',
      'address': prefs.getString('address') ?? '',
      'type': prefs.getString('type') ?? '',
      'isActive': prefs.getBool('isActive') ?? true,
      'profilePictureUrl': prefs.getString('profilePictureUrl') ?? '',
      'profilePicturePath': prefs.getString('profilePicturePath') ?? '',
    };
  }

  // Check if User is Logged In?
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Logout and Clear User Data
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Fetch all users from backend (simple public GET)
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('$host/api/users'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>()).toList();
      } else if (decoded is Map && decoded['users'] is List) {
        return (decoded['users'] as List)
            .map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>())
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  // Resolve current user by matching stored email/username against backend list
  Future<Map<String, dynamic>?> fetchAndCacheCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('id') ?? '';
    final storedEmail = prefs.getString('email') ?? '';
    final storedUsername = prefs.getString('username') ?? '';

    final users = await fetchUsers();
    Map<String, dynamic>? found;
    if (storedId.isNotEmpty) {
      found = users.firstWhere(
        (u) {
          final uid = (u['_id'] ?? u['id'] ?? '').toString();
          return uid == storedId;
        },
        orElse: () => {},
      );
      if (found.isEmpty) found = null;
    }
    if (storedEmail.isNotEmpty && found == null) {
      found = users.firstWhere(
        (u) => (u['email']?.toString().toLowerCase() ?? '') == storedEmail.toLowerCase(),
        orElse: () => {},
      );
      if (found.isEmpty) found = null;
    }
    if (found == null && storedUsername.isNotEmpty) {
      found = users.firstWhere(
        (u) => (u['username']?.toString().toLowerCase() ?? '') == storedUsername.toLowerCase(),
        orElse: () => {},
      );
      if (found.isEmpty) found = null;
    }
    if (found != null && found.isNotEmpty) {
      await saveUserData({'user': found, 'token': prefs.getString('token') ?? ''});
      return found;
    }
    return null;
  }
}
