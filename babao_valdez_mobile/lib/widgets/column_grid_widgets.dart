import 'package:flutter/material.dart';

import '../config/app_spacing.dart';
import 'responsive_container_widget.dart';

class ColumnGridWidget extends StatelessWidget {
  final List<Widget> children;
  final int columnsPerRow;
  final double? spacing;

  const ColumnGridWidget({
    super.key,
    required this.children,
    this.columnsPerRow = 2,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemSpacing = spacing ?? AppSpacing.gutter;

    return ResponsiveContainerWidget(
      child: Wrap(
        spacing: itemSpacing,
        runSpacing: itemSpacing,
        children:
            children.map((child) {
              final itemWidth =
                  (screenWidth -
                      AppSpacing.totalMargins -
                      (itemSpacing * (columnsPerRow - 1))) /
                  columnsPerRow;
              return SizedBox(width: itemWidth, child: child);
            }).toList(),
      ),
    );
  }
}
