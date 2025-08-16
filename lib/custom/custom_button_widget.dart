import 'package:flutter/material.dart';
import '../config/app_spacing.dart';
import '../config/constants.dart';

class CustomButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final bool goBack;
  final String text;
  final bool isTextButton;

  const CustomButtonWidget({
    super.key,
    required this.onPressed,
    this.goBack = false,
    this.text = '',
    this.isTextButton = false,
  });

  @override
  State<CustomButtonWidget> createState() => _CustomButtonWidgetState();
}

class _CustomButtonWidgetState extends State<CustomButtonWidget> {
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

    if (widget.isTextButton && widget.text.isNotEmpty) {
      return Transform.scale(
        scale: _isPressed ? pressedScale : 1.0,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Container(
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withOpacity(_isPressed ? 0.6 : 0.8),
              boxShadow:
                  _isPressed
                      ? []
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PRIMARY.withOpacity(_isPressed ? 0.7 : 1.0),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Icon button
    final navBarHeight =
        70.0 + (bottomPadding > 0 ? bottomPadding : AppSpacing.margin);
    final iconSize = screenWidth > 400 ? 32.0 : 30.0;
    final circleSize = screenWidth > 400 ? 60.0 : 55.0;

    return Container(
      height: navBarHeight,
      padding: EdgeInsets.only(
        left: AppSpacing.margin,
        right: AppSpacing.margin,
        bottom: bottomPadding > 0 ? bottomPadding : AppSpacing.margin,
        top: AppSpacing.margin / 2,
      ),
      child: Transform.scale(
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
              border: Border.all(
                color: Colors.white.withOpacity(_isPressed ? 0.2 : 0.3),
                width: 1,
              ),
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
              widget.goBack ? Icons.keyboard_arrow_left : Icons.arrow_forward,
              size: iconSize,
              color: Colors.white.withOpacity(_isPressed ? 0.7 : 1.0),
            ),
          ),
        ),
      ),
    );
  }
}
