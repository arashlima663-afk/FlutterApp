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
import 'dart:typed_data';
import 'dart:math';

class Variables {
  static late SimpleKeyPair clientKeyPair;
  static late String clientPublicKeyBase64;
  static bool uploaded = false;
  static String? randomString;
  static Uint8List? imageAsBytes;
  static List<int>? myModifiableList;
  static Stream<List<int>>? streamImage;
  static String? ownerId;
  static String? pubKey;
  static String? jwt;
  static CameraController? cameraController;
  static Uint8List? webImage;
  static XFile? capturedImage;
  static bool showCamera = false;
  static int? statusCode;
  static CameraController? controller;
  //
  static final StreamController<Uint8List?> _imageStreamController =
      StreamController<Uint8List?>.broadcast();

  static Stream<Uint8List?> get imageStream => _imageStreamController.stream;

  static void updateImage(Uint8List? bytes) {
    _imageStreamController.add(bytes);
  }

  static void clearImage() {
    _imageStreamController.add(null);
  }
}

Future<Res>? futureKey;

class Res {
  final String ownerId;
  final dynamic pubKey;
  final String jwt;

  const Res({required this.ownerId, required this.pubKey, required this.jwt});

  factory Res.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'owner_id': String ownerId,
        'pub_key': dynamic pubKey,
        'jwt': String jwt,
      } =>
        Res(ownerId: ownerId, pubKey: pubKey, jwt: jwt),
      _ => throw const FormatException('Failed to load Server Response.'),
    };
  }
}
