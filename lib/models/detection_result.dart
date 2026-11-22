
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class PoseKeypoint {
  final String name;
  final double x;
  final double y;
  final double confidence;

  const PoseKeypoint({
    required this.name,
    required this.x,
    required this.y,
    required this.confidence,
  });
}

class Detection {
  final String label;
  final double confidence;
  final BoundingBox boundingBox;
  final List<PoseKeypoint> keypoints;

  const Detection({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.keypoints = const [],
  });
}

class YoloFrameResult {
  final List<Detection> detections;
  final int inferenceTimeMs;

  const YoloFrameResult({
    required this.detections,
    required this.inferenceTimeMs,
  });
}
