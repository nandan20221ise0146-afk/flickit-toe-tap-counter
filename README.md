# FLICKIT – Toe Tap Counter

## Project Overview

FLICKIT Toe Tap Counter is a Flutter-based Android application designed to detect feet using the mobile camera and YOLO object detection through the Roboflow API.

The application captures an image from the camera, sends it to the Roboflow model, and processes the detection response to identify and count detected feet.

## Technologies Used

- Flutter
- Dart
- Android
- Roboflow API
- YOLO Object Detection
- HTTP package
- Camera integration

## Setup and Installation

### Prerequisites

- Flutter SDK
- Android Studio
- Android device with camera
- Roboflow account and API key

### Steps

1. Clone or download the project.
2. Open the project folder in VS Code.
3. Install dependencies:

```bash
flutter pub get
```

4. Connect an Android device with USB debugging enabled.
5. Run the application with your Roboflow API key:

```bash
flutter run --dart-define=ROBOFLOW_API_KEY=k4qSJA1jJFEW4wCCNw6v
```

## Toe Detection Approach

1. The application accesses the mobile camera.
2. An image is captured for detection.
3. The image is sent to the Roboflow hosted YOLO model.
4. The model returns object predictions.
5. The application checks the predicted class labels.
6. Predictions labeled `feet` or `foot` are counted.

## Dependencies

The project uses Flutter packages for:

- Camera access and image capture
- HTTP requests to the Roboflow API
- JSON response processing

See `pubspec.yaml` for the exact package names and versions.

## Known Limitations

- Detection depends on camera positioning, lighting and image quality.
- Internet connectivity is required for hosted Roboflow inference.
- Detection accuracy depends on the trained YOLO model.
- The current implementation counts detected feet; continuous toe-tap movement tracking and tap counting are not yet implemented.

## Future Improvements

- Real-time foot tracking.
- Toe-tap movement detection.
- Automatic tap counting.
- Detection accuracy improvements.
- Offline inference support.

## Project Structure

```text
toe_tap_counter/
├── android/
├── lib/
│   ├── main.dart
│   └── services/
│       └── yolo_service.dart
├── test/
├── pubspec.yaml
└── README.md
```

## Author

FLICKIT Project
