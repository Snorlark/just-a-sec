import 'package:flutter/material.dart';
import '../config/app_spacing.dart';
import '../config/constants.dart';

class CustomIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData iconLogo;
  final bool isUpload;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.iconLogo,
    this.isUpload = false,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final pressedScale = 0.92; // shrink on press

    // Icon button
    final navBarHeight =
        70.0 + (bottomPadding > 0 ? bottomPadding : AppSpacing.margin);
    final baseIconSize = screenWidth > 400 ? 30.0 : 28.0;
    final baseCircleSize = screenWidth > 400 ? 45.0 : 50.0;

    // Make upload icon ~20% bigger instead of 3–4x bigger
    final iconSize = widget.isUpload ? baseIconSize * 1.3 : baseIconSize;
    final circleSize = widget.isUpload ? baseCircleSize * 1.3 : baseCircleSize;

    return Transform.scale(
      scale: _isPressed ? pressedScale : 1.0,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          height: circleSize,
          width: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(_isPressed ? 0.2 : 0.3),
            boxShadow:
                _isPressed
                    ? []
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Icon(
            widget.iconLogo,
            size: iconSize,
            color: Colors.white.withOpacity(_isPressed ? 0.7 : 1.0),
          ),
        ),
      ),
    );
  }
}
