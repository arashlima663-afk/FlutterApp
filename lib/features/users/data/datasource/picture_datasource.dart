import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Picture {
  CameraController? controller;
  Future<void> openCamera() async {
    try {
      final cameras = await availableCameras();
      final CameraDescription backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        backCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller!.initialize();
    } catch (e) {
      print(e);
    }
  }

  // Capture Image
  Future<void> captureImage() async {
    if (controller == null) return;
    try {
      final XFile image = await controller!.takePicture();
      // byteImage = await image.readAsBytes();
    } catch (e) {}
  }
}
