import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

final appTheme = ThemeData(
  scaffoldBackgroundColor: PRIMARY,
  primaryColor: WHITE,
  textTheme: TextTheme(
    headlineMedium: GoogleFonts.cormorantGaramond(
      fontSize: 30,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.cormorantGaramond(fontSize: 18, color: WHITE),
    bodyMedium: GoogleFonts.cormorantGaramond(fontSize: 16, color: WHITE),
    bodySmall: GoogleFonts.cormorantGaramond(fontSize: 14, color: WHITE),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    buttonColor: PRIMARY,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  primaryColor: Colors.white,
  textTheme: TextTheme(
    headlineMedium: GoogleFonts.cormorantGaramond(
      fontSize: 30,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.cormorantGaramond(fontSize: 18, color: Colors.white),
    bodyMedium: GoogleFonts.cormorantGaramond(fontSize: 16, color: Colors.white70),
    bodySmall: GoogleFonts.cormorantGaramond(fontSize: 14, color: Colors.white70),
  ),
  iconTheme: const IconThemeData(color: Colors.white70),
  cardColor: const Color(0xFF1E1E1E),
  colorScheme: const ColorScheme.dark().copyWith(
    primary: Colors.white,
    secondary: Colors.white70,
  ),
);