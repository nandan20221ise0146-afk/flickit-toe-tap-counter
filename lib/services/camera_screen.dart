
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'camera_service.dart';
import 'image_processing_service.dart';
import 'yolo_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();

  final ImageProcessingService _imageProcessingService =
      ImageProcessingService();

  final YoloService _yoloService = YoloService();

  bool _isLoading = true;
  bool _isStarted = false;
  bool _isDetecting = false;

  String? _error;
  String? _detectionError;

  int _feetCount = 0;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  // Initialize camera
  Future<void> initializeCamera() async {
    try {
      await _cameraService.initializeCamera();

      if (!mounted) return;

      await _cameraService.startImageStream(
        _imageProcessingService.processImage,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Start counting
  void startCounting() {
    setState(() {
      _isStarted = true;
    });
  }

  // Stop counting
  void stopCounting() {
    setState(() {
      _isStarted = false;
    });
  }

  // Reset counting
  void resetCounting() {
    _imageProcessingService.reset();

    setState(() {
      _isStarted = false;
      _feetCount = 0;
      _detectionError = null;
    });
  }

  // Detect feet using YOLO
  Future<void> detectFeet() async {
    if (_isDetecting || !_cameraService.isInitialized) {
      return;
    }

    setState(() {
      _isDetecting = true;
      _detectionError = null;
    });

    try {
      // Capture image from camera
      final imageFile = await _cameraService.captureImage();
      debugPrint('Captured image path: ${imageFile.path}');
debugPrint('Captured image size: ${await imageFile.length()} bytes');

      // Send image to Roboflow YOLO API
      final result = await _yoloService.detectFeet(imageFile);

      // Get detected feet count
      final count = _yoloService.getFeetCount(result);

      if (!mounted) return;

      setState(() {
        _feetCount = count;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _detectionError = e.toString();
      });
    } finally {
      // Restart camera stream
      if (mounted && _cameraService.isInitialized) {
        try {
          await _cameraService.startImageStream(
            _imageProcessingService.processImage,
          );
        } catch (e) {
          if (mounted) {
            setState(() {
              _detectionError = 'Camera stream error: $e';
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    unawaited(_cameraService.stopImageStream());
    unawaited(_cameraService.disposeCamera());

    _imageProcessingService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toe Tap Counter'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Camera Preview
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Camera Error: $_error',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _cameraService.isInitialized
                            ? CameraPreview(
                                _cameraService.controller!,
                              )
                            : const Text('Camera not available'),
              ),
            ),

            // Counting Status
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _isStarted
                    ? 'Counting Started'
                    : 'Ready to Start',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // YOLO Detection Result
            Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'YOLO Foot Detection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (_isDetecting)
                      const CircularProgressIndicator()
                    else
                      Text(
                        'Feet Detected: $_feetCount',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                    if (_detectionError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _detectionError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            !_isLoading &&
                                    _error == null &&
                                    !_isDetecting
                                ? detectFeet
                                : null,
                        icon: const Icon(Icons.search),
                        label: const Text('Detect Feet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Start, Stop and Reset Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          !_isLoading &&
                                  _error == null &&
                                  !_isStarted &&
                                  !_isDetecting
                              ? startCounting
                              : null,
                      child: const Text('Start'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          !_isLoading &&
                                  _error == null &&
                                  _isStarted &&
                                  !_isDetecting
                              ? stopCounting
                              : null,
                      child: const Text('Stop'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          !_isLoading &&
                                  _error == null &&
                                  !_isDetecting
                              ? resetCounting
                              : null,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
