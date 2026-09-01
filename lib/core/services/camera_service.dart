import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraManager {
  static List<CameraDescription> availableCamerasList = [];
  static bool isInitialized = false;

  static Future<void> initializeCameras() async {
    try {
      availableCamerasList = await availableCameras();
      isInitialized = true;
      debugPrint('Cameras initialized: ${availableCamerasList.length} cameras found');
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      availableCamerasList = [];
      isInitialized = false;
    }
  }

  static CameraDescription? getBackCamera() {
    if (availableCamerasList.isEmpty) return null;
    try {
      return availableCamerasList.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => availableCamerasList.first,
      );
    } catch (e) {
      return availableCamerasList.first;
    }
  }

  static CameraDescription? getFrontCamera() {
    if (availableCamerasList.isEmpty) return null;
    try {
      return availableCamerasList.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => availableCamerasList.first,
      );
    } catch (e) {
      return availableCamerasList.first;
    }
  }
}
