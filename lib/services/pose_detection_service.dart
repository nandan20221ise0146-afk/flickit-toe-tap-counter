
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectionService {
  late final PoseDetector _poseDetector;

  PoseDetectionService() {
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      ),
    );
  }

  Future<List<Pose>> detectPose(InputImage image) async {
    return await _poseDetector.processImage(image);
  }

  Future<void> dispose() async {
    await _poseDetector.close();
  }
}
