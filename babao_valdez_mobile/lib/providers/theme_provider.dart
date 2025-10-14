import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider({bool initialDark = false}) : _isDark = initialDark;

  bool _isDark;
  bool get isDark => _isDark;

  void setDark(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
