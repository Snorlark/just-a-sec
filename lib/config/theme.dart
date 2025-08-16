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
