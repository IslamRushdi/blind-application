import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraUtils {
  static List<CameraDescription>? _cameras;

  static initializeCamera(CameraController cameraController) async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();

    initializeCameraController(cameraController);
  }

  static CameraController initializeCameraController(
    CameraController cameraController,
  ) {
    cameraController = CameraController(_cameras![0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      cameraController.setFocusMode(FocusMode.locked);
      cameraController.setFlashMode(FlashMode.off);
    });

    return cameraController;
  }
}
