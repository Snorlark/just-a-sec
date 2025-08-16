import 'package:flutter/material.dart';

class AppSpacing {
  // Base spacing units
  static const double baseUnit = 12.0;

  // Margins (outer spacing)
  static const double margin = baseUnit; // 15px

  // Gutters (spacing between elements)
  static const double gutter = baseUnit; // 15px

  // Column system
  static const int columnCount = 4;

  // Calculated values
  static double get totalMargins => margin * 2; // Left + Right margins
  static double get totalGutters =>
      gutter * (columnCount - 1); // Gutters between columns

  // Calculate single column width
  static double columnWidth(double screenWidth) {
    final availableWidth = screenWidth - totalMargins - totalGutters;
    return availableWidth / columnCount;
  }

  // Common padding values
  static const EdgeInsets horizontalMargin = EdgeInsets.symmetric(
    horizontal: margin,
  );
  static const EdgeInsets allMargin = EdgeInsets.all(margin);
  static const EdgeInsets verticalGutter = EdgeInsets.symmetric(
    vertical: gutter / 2,
  );
  static const EdgeInsets horizontalGutter = EdgeInsets.symmetric(
    horizontal: gutter / 2,
  );
}
