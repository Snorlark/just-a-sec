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

  // Save data into SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', userData['firstName'] ?? '');
    await prefs.setString('token', userData['token'] ?? '');
    await prefs.setString('type', userData['type'] ?? '');
  }

  // Retrieve User Data from SharedPreferences
  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString('firstName') ?? '',
      'token': prefs.getString('token') ?? '',
      'type': prefs.getString('type') ?? '',
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
}
