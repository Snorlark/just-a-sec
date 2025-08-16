import 'package:flutter/material.dart';

class CustomRecordButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double size;
  final Color borderColor;
  final Color backgroundColor;
  final Color backgroundColorPressed;
  final double borderWidth;
  final bool isUpload;

  const CustomRecordButton({
    Key? key,
    this.onPressed,
    this.size = 100.0,
    this.borderColor = Colors.yellow,
    this.backgroundColor = Colors.white,
    this.backgroundColorPressed = const Color.fromARGB(96, 255, 255, 255),
    this.borderWidth = 8.0,
    this.isUpload = false,
  }) : super(key: key);

  @override
  State<CustomRecordButton> createState() => _CustomRecordButtonState();
}

class _CustomRecordButtonState extends State<CustomRecordButton>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _pressController;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Heartbeat animation controller
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Heartbeat animation (border pulsing)
    _heartbeatAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartbeatController, curve: Curves.elasticOut),
    );

    // Scale animation (inner circle shrinking)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _pressController.forward();
    _startHeartbeatAnimation();
  }

  void _onTapUp(TapUpDetails details) {
    _resetButton();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _resetButton();
  }

  void _resetButton() {
    setState(() {
      _isPressed = false;
    });
    _pressController.reverse();
  }

  void _startHeartbeatAnimation() {
    _heartbeatController.reset();
    _heartbeatController.forward().then((_) {
      _heartbeatController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_heartbeatController, _pressController]),
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(
              child: Transform.scale(
                scale: _heartbeatAnimation.value,
                child: Container(
                  width: widget.size * 0.9,
                  height: widget.size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        widget.isUpload
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                    border: Border.all(
                      color:
                          widget.isUpload
                              ? Colors.transparent
                              : widget.borderColor,
                      width: widget.borderWidth,
                    ),
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child:
                            widget.isUpload
                                ? Icon(
                                  Icons.send_rounded,
                                  size: widget.size * 0.5,
                                  color:
                                      _isPressed
                                          ? widget.backgroundColorPressed
                                          : widget.backgroundColor,
                                )
                                : Container(
                                  width: widget.size * 0.6,
                                  height: widget.size * 0.6,
                                  decoration: BoxDecoration(
                                    color:
                                        _isPressed
                                            ? widget.backgroundColorPressed
                                            : widget.backgroundColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
