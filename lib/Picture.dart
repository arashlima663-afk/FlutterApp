import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_application_1/encrypt.dart';
import 'package:flutter_application_1/Picture.dart';
import 'package:flutter_application_1/flags.dart';
import 'dart:typed_data';

// Future<void> _openCamera() async {
//   try {
//     Variables.controller = null;
//     Variables.capturedImage = null;
//     Variables.webImage = null;
//     Variables.showCamera = true;
//     Variables.uploaded = false;

//     final List<CameraDescription> cameras = await availableCameras();
//     final CameraDescription backCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.back,
//       orElse: () => cameras.first,
//     );

//     Variables.controller = CameraController(
//       backCamera,
//       ResolutionPreset.ultraHigh,
//       enableAudio: false,
//       imageFormatGroup: ImageFormatGroup.jpeg,
//     );
//     await Variables.controller!.initialize();
//     if (!mounted) return;
//   } on CameraException catch (e) {
//     debugPrint("Camera error: ${e.description}");
//   }
// }

// Future<void> _takePicture() async {
//   final dynamic image = await _controller!.takePicture();

//   if (image == null) return;
//   imageAsBytes = await image.readAsBytes();

//   if (kIsWeb) {
//   } else {}
// }

// Take From Gallery
Future openGallery() async {
  Variables.controller = null;
  Variables.capturedImage = null;
  Variables.webImage = null;
  Variables.uploaded = false;

  final XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: null,
    requestFullMetadata: false,
  );

  Variables.capturedImage = image;

  Variables.imageAsBytes = await image!.readAsBytes();

  Variables.streamImage = Stream<List<int>>.fromFuture(
    image.readAsBytes(),
  ).cast<List<int>>();
}
