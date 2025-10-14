import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../custom/custom_text.dart';
import '../models/user_model.dart';
import '../providers/theme_provider.dart';
import '../config/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _username = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final box = await Hive.openBox<UserModel>('userBox');
    final user = box.get('currentUser');
    setState(() {
      _user = user;
      _firstName.text = user?.firstName ?? '';
      _lastName.text = user?.lastName ?? '';
      _username.text = user?.username ?? '';
    });
  }

  Future<void> _persistTheme(bool isDark) async {
    final box = await Hive.openBox('settingsBox');
    await box.put('darkMode', isDark);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final box = await Hive.openBox<UserModel>('userBox');
    final updated = UserModel(
      username: _username.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      profilePicturePath: _user?.profilePicturePath,
      profilePictureDate: _user?.profilePictureDate,
    );
    await box.put('currentUser', updated);
    setState(() => _user = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          text: 'Settings',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const CustomText(text: 'Save', fontSize: 16, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile section
            const CustomText(text: 'Profile', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: CustomText(text: _user == null ? 'U' : _initials(_user!), fontSize: 16, fontWeight: FontWeight.w700, color: PRIMARY),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _username,
                            style: const TextStyle(color: Colors.white),
                            decoration: _fieldDecoration('Username'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Username required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstName,
                            style: const TextStyle(color: Colors.white),
                            decoration: _fieldDecoration('First name'),
                            validator: (v) => null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastName,
                            style: const TextStyle(color: Colors.white),
                            decoration: _fieldDecoration('Last name'),
                            validator: (v) => null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _saveProfile,
                        child: const CustomText(text: 'Save changes', fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Theme section
            const CustomText(text: 'Appearance', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.dark_mode, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: CustomText(
                      text: 'Dark Mode',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Switch(
                    value: themeProvider.isDark,
                    onChanged: (val) {
                      context.read<ThemeProvider>().setDark(val);
                      _persistTheme(val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
    );
  }

  String _displayName(UserModel user) {
    final first = (user.firstName ?? '').trim();
    final last = (user.lastName ?? '').trim();
    if (first.isEmpty && last.isEmpty) return user.username ?? 'User';
    return [first, last].where((e) => e.isNotEmpty).join(' ');
  }

  String _initials(UserModel user) {
    final name = _displayName(user);
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
