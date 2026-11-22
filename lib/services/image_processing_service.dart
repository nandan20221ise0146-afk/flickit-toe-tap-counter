
import 'dart:developer' as developer;

import 'package:camera/camera.dart';

import '../models/detection_result.dart';
import 'toe_tap_detection_service.dart';

class ImageProcessingService {
  final ToeTapDetectionService _toeTapDetectionService =
      ToeTapDetectionService();

  bool _isProcessing = false;
  bool _isDisposed = false;
  int _tapCount = 0;

  int get tapCount => _tapCount;

  bool get isProcessing => _isProcessing;

  void Function(int count)? onTapCountChanged;

  // Camera frame processing
  Future<void> processImage(CameraImage image) async {
    if (_isProcessing || _isDisposed) return;

    _isProcessing = true;

    try {
      // YOLO inference will be connected here.
      // CameraImage must be converted to the format
      // required by the YOLO model before inference.
    } catch (e, stackTrace) {
      developer.log(
        'Image processing error',
        name: 'ImageProcessingService',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isProcessing = false;
    }
  }

  // Process YOLO detection results
  void processDetections(YoloFrameResult result) {
    if (_isDisposed) return;

    _toeTapDetectionService.processFrame(result);

    final newCount = _toeTapDetectionService.tapCount;

    if (newCount != _tapCount) {
      _tapCount = newCount;
      onTapCountChanged?.call(_tapCount);
    }
  }

  // Reset counter
  void resetCounter() {
    if (_isDisposed) return;

    _toeTapDetectionService.reset();
    _tapCount = 0;
    onTapCountChanged?.call(_tapCount);
  }

  void reset() {
    resetCounter();
  }

  void dispose() {
    _isDisposed = true;
    onTapCountChanged = null;
  }
}
