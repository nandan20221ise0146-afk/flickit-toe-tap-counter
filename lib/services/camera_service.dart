
import 'dart:io';

import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;

  // Get camera controller
  CameraController? get controller => _controller;

  // Check camera initialization
  bool get isInitialized =>
      _controller?.value.isInitialized ?? false;

  // Initialize camera
  Future<void> initializeCamera() async {
    try {
      // Get all available cameras
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No camera found on this device.');
      }

      // Select back camera
      final backCamera = cameras.firstWhere(
        (camera) =>
            camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Create camera controller
      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      // Initialize camera
      await _controller!.initialize();
    } catch (e) {
      await disposeCamera();
      rethrow;
    }
  }

  // Start camera image stream
  Future<void> startImageStream(
    void Function(CameraImage image) onImage,
  ) async {
    if (_controller == null ||
        !_controller!.value.isInitialized) {
      throw Exception('Camera is not initialized.');
    }

    if (!_controller!.value.isStreamingImages) {
      await _controller!.startImageStream(onImage);
    }
  }

  // Stop camera image stream
  Future<void> stopImageStream() async {
    if (_controller != null &&
        _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  // Capture image for YOLO detection
  Future<File> captureImage() async {
    if (_controller == null ||
        !_controller!.value.isInitialized) {
      throw Exception('Camera is not initialized.');
    }

    if (_controller!.value.isTakingPicture) {
      throw Exception('Camera is already taking a picture.');
    }

    // Stop streaming before taking a picture
    if (_controller!.value.isStreamingImages) {
      await stopImageStream();
    }

    final XFile image = await _controller!.takePicture();

    return File(image.path);
  }

  // Release camera resources
  Future<void> disposeCamera() async {
    await _controller?.dispose();
    _controller = null;
  }
}
