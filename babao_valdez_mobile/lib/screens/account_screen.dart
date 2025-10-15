import 'dart:io';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../custom/custom_text.dart';
import '../config/constants.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = UserService();
    // First, try backend (more authoritative)
    await service.fetchAndCacheCurrentUser();
    Map<String, dynamic> data = await service.getUserData();

    if (!mounted) return;
    setState(() {
      _user = data;
      _loading = false;
    });
  }

  String _initials(Map<String, dynamic> u) {
    final first = (u['firstName'] ?? '').toString();
    final last = (u['lastName'] ?? '').toString();
    final username = (u['username'] ?? 'U').toString();
    final name = ((first.isEmpty && last.isEmpty) ? username : '$first $last').trim();
    final parts = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _rowItem({required IconData icon, required String label, required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: label, fontSize: 12, color: Colors.white.withOpacity(0.7)),
                const SizedBox(height: 2),
                CustomText(text: value.isEmpty ? '-' : value, fontSize: 16, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          text: 'Account',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Column(
                      children: [
                        _buildAvatar(_user!),
                        const SizedBox(height: 12),
                        CustomText(
                          text: _displayName(_user!),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: (_user!['email'] ?? '').toString(),
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _rowItem(icon: Icons.person_outline, label: 'Username', value: (_user!['username'] ?? '').toString()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _rowItem(icon: Icons.badge_outlined, label: 'First name', value: (_user!['firstName'] ?? '').toString()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _rowItem(icon: Icons.badge_outlined, label: 'Last name', value: (_user!['lastName'] ?? '').toString()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _rowItem(icon: Icons.numbers, label: 'Age', value: (_user!['age'] ?? '').toString()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _rowItem(icon: Icons.wc, label: 'Gender', value: (_user!['gender'] ?? '').toString()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _rowItem(icon: Icons.phone, label: 'Contact Number', value: (_user!['contactNumber'] ?? '').toString()),
                  const SizedBox(height: 12),
                  _rowItem(icon: Icons.email_outlined, label: 'Email', value: (_user!['email'] ?? '').toString()),
                ],
              ),
            ),
    );
  }

  String _displayName(Map<String, dynamic> u) {
    final first = (u['firstName'] ?? '').toString().trim();
    final last = (u['lastName'] ?? '').toString().trim();
    final username = (u['username'] ?? 'User').toString();
    if (first.isEmpty && last.isEmpty) return username;
    return [first, last].where((e) => e.isNotEmpty).join(' ');
  }

  Widget _buildAvatar(Map<String, dynamic> u) {
    final url = (u['profilePictureUrl'] ?? '').toString();
    final path = (u['profilePicturePath'] ?? '').toString();
    final initials = _initials(u);

    Widget child;
    if (url.isNotEmpty) {
      child = CircleAvatar(
        radius: 36,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(url),
      );
    } else if (path.isNotEmpty) {
      child = CircleAvatar(
        radius: 36,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(File(path)),
      );
    } else {
      child = CircleAvatar(
        radius: 36,
        backgroundColor: Colors.white,
        child: CustomText(text: initials, fontSize: 18, fontWeight: FontWeight.w700, color: PRIMARY),
      );
    }
    return child;
  }
}
