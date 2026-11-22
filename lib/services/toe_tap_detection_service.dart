
import 'dart:math' as math;

import '../models/detection_result.dart';

class ToeTapDetectionService {
  int _toeTapCount = 0;

  bool _isArmed = true;
  int _framesAway = 0;

  DateTime? _lastTapTime;

  static const double _contactThreshold = 0.06;
  static const double _rearmThreshold = 0.12;

  static const int _requiredFramesAway = 3;
  static const int _cooldownMs = 450;

  int get tapCount => _toeTapCount;

  int processFrame(
    YoloFrameResult frame, {
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();

    final ball = _findBall(frame.detections);
    final footPoints = _findFootPoints(frame.detections);

    if (ball == null || footPoints.isEmpty) {
      _handleMissingDetection();
      return _toeTapCount;
    }

    final ballBox = ball.boundingBox;

    double closestDistance = double.infinity;

    for (final foot in footPoints) {
      final distance = _distanceToBox(
        foot.x,
        foot.y,
        ballBox,
      );

      if (distance < closestDistance) {
        closestDistance = distance;
      }
    }

    if (closestDistance <= _contactThreshold) {
      _framesAway = 0;

      if (_isArmed && _canCountTap(now)) {
        _toeTapCount++;

        _isArmed = false;
        _lastTapTime = now;
      }
    } else if (closestDistance >= _rearmThreshold) {
      _framesAway++;

      if (_framesAway >= _requiredFramesAway) {
        _isArmed = true;
      }
    } else {
      _framesAway = 0;
    }

    return _toeTapCount;
  }

  Detection? _findBall(List<Detection> detections) {
    for (final detection in detections) {
      final label = detection.label.toLowerCase();

      if (label.contains('ball') ||
          label.contains('football') ||
          label.contains('sports ball')) {
        return detection;
      }
    }

    return null;
  }

  List<PoseKeypoint> _findFootPoints(
    List<Detection> detections,
  ) {
    final points = <PoseKeypoint>[];

    for (final detection in detections) {
      if (detection.label.toLowerCase() != 'person') {
        continue;
      }

      for (final keypoint in detection.keypoints) {
        final name = keypoint.name.toLowerCase();

        if ((name.contains('ankle') ||
                name.contains('foot') ||
                name.contains('toe')) &&
            keypoint.confidence >= 0.35) {
          points.add(keypoint);
        }
      }
    }

    return points;
  }

  double _distanceToBox(
    double x,
    double y,
    BoundingBox box,
  ) {
    final closestX = x.clamp(
      box.x,
      box.x + box.width,
    );

    final closestY = y.clamp(
      box.y,
      box.y + box.height,
    );

    final dx = x - closestX;
    final dy = y - closestY;

    return math.sqrt(dx * dx + dy * dy);
  }

  bool _canCountTap(DateTime now) {
    if (_lastTapTime == null) return true;

    return now.difference(_lastTapTime!).inMilliseconds >=
        _cooldownMs;
  }

  void _handleMissingDetection() {
    _framesAway = 0;
  }

  void reset() {
    _toeTapCount = 0;
    _isArmed = true;
    _framesAway = 0;
    _lastTapTime = null;
  }
}
