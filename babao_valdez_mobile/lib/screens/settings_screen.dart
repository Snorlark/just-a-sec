import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom/custom_text.dart';
import '../providers/theme_provider.dart';
import '../config/constants.dart';
import '../services/user_service.dart';
import 'account_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Future<void> _persistTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
  }

  @override
  void dispose() {
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const CustomText(text: 'Account', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const CustomText(text: 'Profile', fontSize: 16, color: Colors.white),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
                      },
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const CustomText(text: 'Logout', fontSize: 16, color: Colors.white),
                  onTap: () async {
                    await UserService().logout();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
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

  String _displayNameFromMap(Map<String, dynamic> user) {
    final first = (user['firstName'] ?? '').toString().trim();
    final last = (user['lastName'] ?? '').toString().trim();
    final username = (user['username'] ?? 'User').toString();
    if (first.isEmpty && last.isEmpty) return username;
    return [first, last].where((e) => e.isNotEmpty).join(' ');
  }
}
