import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  static List<CameraDescription> availableCamerasList = [];
  static bool isInitialized = false;

  /// Initializes hardware cameras
  static Future<void> initCameras() async {
    try {
      availableCamerasList = await availableCameras();
      isInitialized = availableCamerasList.isNotEmpty;
      debugPrint('CameraService: Initialized ${availableCamerasList.length} cameras.');
    } catch (e) {
      debugPrint('CameraService init error: $e');
      availableCamerasList = [];
      isInitialized = false;
    }
  }

  /// Returns default rear camera for desk/paper tracing
  static CameraDescription? getBackCamera() {
    if (availableCamerasList.isEmpty) return null;
    return availableCamerasList.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => availableCamerasList.first,
    );
  }

  /// Creates and configures a CameraController
  static Future<CameraController?> createController() async {
    final camera = getBackCamera();
    if (camera == null) return null;

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    return controller;
  }
}
