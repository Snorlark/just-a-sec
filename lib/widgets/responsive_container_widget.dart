import 'package:flutter/material.dart';

import '../config/app_spacing.dart';

class ResponsiveContainerWidget extends StatelessWidget {
  final Widget child;
  final bool applyHorizontalMargin;

  const ResponsiveContainerWidget({
    super.key,
    required this.child,
    this.applyHorizontalMargin = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: applyHorizontalMargin ? AppSpacing.horizontalMargin : null,
      child: child,
    );
  }
}
