import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:just_a_sec/services/camera_service.dart';
import 'package:just_a_sec/config/app_spacing.dart';
import 'package:just_a_sec/widgets/responsive_container_widget.dart';

class CameraWidget extends StatefulWidget {
  final CameraService cameraService;

  const CameraWidget({super.key, required this.cameraService});

  @override
  State<CameraWidget> createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  bool _isLoading = true;
  bool _isRecording = false;

  // Focus box position
  Offset? _focusPoint;

  // Exposure values
  double _exposureOffset = 0.0;
  double _minExposure = 0.0;
  double _maxExposure = 0.0;
  bool _showBrightnessDial = false;

  Uint8List? lastFrame;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setState(() => _isLoading = true);
    await widget.cameraService.initializeCamera();
    if (mounted) {
      // Fetch exposure range
      _minExposure =
          await widget.cameraService.controller!.getMinExposureOffset();
      _maxExposure =
          await widget.cameraService.controller!.getMaxExposureOffset();
      _exposureOffset = 0.0;
      setState(() => _isLoading = false);
    }
  }

  Future<void> freezeLastFrame() async {
    final controller = widget.cameraService.controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final image = await controller.takePicture();
      lastFrame = await image.readAsBytes();
    } catch (e) {
      debugPrint("Error freezing last frame: $e");
    }
  }

  Future<void> refreshCamera() async {
    await freezeLastFrame(); // capture before hiding preview
    setState(() => _isLoading = true);

    await widget.cameraService.initializeCamera();

    _minExposure =
        await widget.cameraService.controller!.getMinExposureOffset();
    _maxExposure =
        await widget.cameraService.controller!.getMaxExposureOffset();
    _exposureOffset = 0.0;

    if (mounted) setState(() => _isLoading = false);
  }

  void _onTapToFocus(TapDownDetails details, BoxConstraints constraints) async {
    final controller = widget.cameraService.controller;
    if (controller == null || !controller.value.isInitialized) return;

    final previewSize = controller.value.previewSize!;
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // Convert tap to normalized coordinates (0.0 - 1.0)
    double dx = localPosition.dx / constraints.maxWidth;
    double dy = localPosition.dy / constraints.maxHeight;

    // Clamp to 0.0–1.0
    dx = dx.clamp(0.0, 1.0);
    dy = dy.clamp(0.0, 1.0);

    setState(() {
      _focusPoint = localPosition;
      _showBrightnessDial = true;
    });

    await widget.cameraService.setFocusPoint(Offset(dx, dy));

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _focusPoint = null;
        _showBrightnessDial = false;
      });
    });
  }

  @override
  void dispose() {
    widget.cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double boxHeight = MediaQuery.of(context).size.height * 0.6;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _onTapToFocus(details, constraints),
          child: Stack(
            children: [
              ResponsiveContainerWidget(
                child: Padding(
                  padding: AppSpacing.allMargin,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: boxHeight,
                      child:
                          _isLoading ||
                                  widget.cameraService.controller == null ||
                                  !widget
                                      .cameraService
                                      .controller!
                                      .value
                                      .isInitialized
                              ? (lastFrame != null
                                  ? Image.memory(lastFrame!, fit: BoxFit.cover)
                                  : Container(
                                    color: Colors.white.withOpacity(0.2),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ))
                              : FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width:
                                      widget
                                          .cameraService
                                          .controller!
                                          .value
                                          .previewSize!
                                          .height,
                                  height:
                                      widget
                                          .cameraService
                                          .controller!
                                          .value
                                          .previewSize!
                                          .width,
                                  child: CameraPreview(
                                    widget.cameraService.controller!,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ),
              ),

              // Focus box
              if (_focusPoint != null)
                Positioned(
                  left: _focusPoint!.dx - 13,
                  top: _focusPoint!.dy - 13,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 2),
                      borderRadius: BorderRadius.circular(70),
                    ),
                  ),
                ),

              // Brightness Dial
              if (_showBrightnessDial && _focusPoint != null)
                Positioned(
                  left: _focusPoint!.dx + 55,
                  top: _focusPoint!.dy - 75,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) async {
                      double newOffset =
                          _exposureOffset - (details.delta.dy * 0.02);
                      newOffset = newOffset.clamp(_minExposure, _maxExposure);
                      setState(() => _exposureOffset = newOffset);
                      await widget.cameraService.controller!.setExposureOffset(
                        _exposureOffset,
                      );
                    },
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Slider(
                        value: _exposureOffset,
                        divisions: 10,
                        thumbColor: null,
                        activeColor: Colors.yellow,
                        onChanged: (value) async {
                          setState(() => _exposureOffset = value);
                          await widget.cameraService.controller!
                              .setExposureOffset(value);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
