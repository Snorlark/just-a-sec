import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/constants.dart';

class CustomFont extends StatelessWidget {
  final String text;
  final double fontSize, letterSpacing, height;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final FontStyle fontStyle;
  final TextDecoration textDecoration;
  final TextDecorationStyle textDecorationStyle;
  final List<Shadow> shadows;

  const CustomFont({
    super.key,
    required this.text,
    this.fontSize = 15,
    this.color = WHITE,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0,
    this.height = 1.2,
    this.fontStyle = FontStyle.normal,
    this.textDecoration = TextDecoration.none,
    this.textDecorationStyle = TextDecorationStyle.solid,
    this.shadows = const [Shadow()], // Default shadow
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: GoogleFonts.cormorantGaramond(
        textStyle: TextStyle(
          fontSize: fontSize,
          color: color,
          fontStyle: fontStyle,
          height: height,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          decoration: textDecoration,
          decorationStyle: textDecorationStyle,
          shadows: shadows,
        ),
      ),
    );
  }
}
