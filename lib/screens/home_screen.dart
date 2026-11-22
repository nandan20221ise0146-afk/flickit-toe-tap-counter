
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../services/camera_service.dart';
import '../services/yolo_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _cameraService = CameraService();
  final YoloService _yoloService = YoloService();

  int detectedFeet = 0;

  bool isLoading = true;
  bool isDetecting = false;

  String status = 'Initializing camera...';
  String? cameraError;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      await _cameraService.initializeCamera();

      if (!mounted) return;

      setState(() {
        isLoading = false;
        status = 'Camera ready. Position your feet.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        cameraError = e.toString();
        status = 'Camera initialization failed';
      });

      debugPrint('Camera Error: $e');
    }
  }

  Future<void> startDetection() async {
    if (isDetecting || !_cameraService.isInitialized) return;

    setState(() {
      isDetecting = true;
      status = 'Capturing image...';
    });

    try {
      final imageFile = await _cameraService.captureImage();

      if (!mounted) return;

      setState(() {
        status = 'Sending image to Roboflow...';
      });

      final result = await _yoloService.detectFeet(imageFile);

      final count = _yoloService.getFeetCount(result);

      if (!mounted) return;

      setState(() {
        detectedFeet = count;
        status = count > 0
            ? 'Detection successful!'
            : 'No feet detected. Adjust camera position.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'Detection failed: $e';
      });

      debugPrint('YOLO Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isDetecting = false;
        });
      }
    }
  }

  void resetCounter() {
    setState(() {
      detectedFeet = 0;
      status = 'Counter reset. Ready for detection.';
    });
  }

  @override
  void dispose() {
    _cameraService.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toe Tap Counter'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _buildCameraPreview(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '$detectedFeet',
                    style: const TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'Feet Detected',
                    style: TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            isDetecting ? null : startDetection,
                        icon: isDetecting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          isDetecting
                              ? 'Detecting...'
                              : 'Detect Feet',
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed:
                            isDetecting ? null : resetCounter,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (cameraError != null) {
      return Center(
        child: Text(
          'Camera Error: $cameraError',
          textAlign: TextAlign.center,
        ),
      );
    }

    final CameraController? controller =
        _cameraService.controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}
