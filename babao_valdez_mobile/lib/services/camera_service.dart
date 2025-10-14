import 'dart:ui';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;
  FlashMode _currentFlashMode = FlashMode.off;

  CameraController? get controller => _controller;

  Future<void> initializeCamera({int cameraIndex = 0}) async {
    _cameras ??= await availableCameras();
    _currentCameraIndex = cameraIndex;

    // Dispose old controller if exists
    await _controller?.dispose();

    _controller = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();

    // Lock zoom level
    await _controller!.setZoomLevel(1.0);

    // Apply stored flash mode safely
    try {
      await _controller!.setFlashMode(_currentFlashMode);
    } catch (e) {
      print("Error setting flash: $e");
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    _currentFlashMode = mode; // Store it
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        // Add a small delay to ensure camera is ready
        await Future.delayed(Duration(milliseconds: 100));
        await _controller!.setFlashMode(mode);
      } catch (e) {
        print("Flash mode error: $e");
      }
    }
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    final newIndex = (_currentCameraIndex + 1) % _cameras!.length;

    // Save old controller so preview can keep showing
    final oldController = _controller;

    try {
      // Dispose old before starting new (required by Android)
      await oldController?.dispose();

      // Init new controller
      final newController = CameraController(
        _cameras![newIndex],
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await newController.initialize();
      await newController.setZoomLevel(1.0);

      try {
        await newController.setFlashMode(_currentFlashMode);
      } catch (e) {
        print("Error setting flash mode: $e");
      }

      // Swap
      _controller = newController;
      _currentCameraIndex = newIndex;
    } catch (e) {
      print("Error switching camera: $e");
    }
  }

  Future<void> setFocusPoint(Offset offset) async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _controller!.setFocusPoint(offset);
        await _controller!.setExposurePoint(offset);
      } catch (e) {
        print("Focus error: $e");
      }
    }
  }

  Future<XFile?> takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.setZoomLevel(1.0);
      return await _controller!.takePicture();
    }
    return null;
  }

  Future<XFile?> recordOneSecondVideo() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;

    try {
      // Explicitly set zoom to 1.0 before recording
      await _controller!.setZoomLevel(1.0);

      // Start recording
      await _controller!.startVideoRecording();

      // Wait for 2 seconds (change to 1 if needed)
      await Future.delayed(const Duration(seconds: 2));

      // Stop recording
      return await _controller!.stopVideoRecording();
    } catch (e) {
      print("Video recording error: $e");
      // Make sure to stop recording if there's an error
      if (_controller!.value.isRecordingVideo) {
        await _controller!.stopVideoRecording();
      }
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}
