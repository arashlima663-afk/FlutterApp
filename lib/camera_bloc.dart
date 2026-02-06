import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraPreviewState extends CameraState {}

enum UploadStatus { not, done, wait, failure }

enum EncStatus { not, done }

class CameraCapturedState extends CameraState {
  final XFile image;
  final Uint8List byteImage;
  final EncStatus encryptStatus;
  final UploadStatus uploadStatus;

  CameraCapturedState(
    this.image,
    this.byteImage, {
    this.uploadStatus = UploadStatus.not,
    this.encryptStatus = EncStatus.not,
  });
  CameraCapturedState copyWith({
    UploadStatus? uploadStatus,
    EncStatus? encryptStatus,
  }) {
    return CameraCapturedState(
      image,
      byteImage,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      encryptStatus: encryptStatus ?? this.encryptStatus,
    );
  }
}

class CameraErrorState extends CameraState {
  final String message;
  CameraErrorState(this.message);
}

class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(CameraInitial()) {
    loadKey();
  }
  CameraController? controller;
  List<int> hkdfNonce = [];
  SimpleKeyPair? clientKeyPair;
  String ownerId = '';
  String pubKey = '';
  Uint8List? byteImage;
  Map<String, dynamic>? databody;

  List<int> aesNonce = [];
  // Open Camera Preview
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
      emit(CameraPreviewState());
    } catch (e) {
      emit(CameraErrorState("Failed to open camera: $e"));
    }
  }

  // Capture Image
  Future<void> captureImage() async {
    if (controller == null) return;
    try {
      final XFile image = await controller!.takePicture();
      byteImage = await image.readAsBytes();

      emit(CameraCapturedState(image, byteImage!));
    } catch (e) {
      emit(CameraErrorState("Failed to capture image: $e"));
    }
  }

  // Gallery image
  Future opengallery() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: null,
      requestFullMetadata: false,
    );
    if (image == null) return;
    byteImage = await image.readAsBytes();
    emit(CameraCapturedState(image, byteImage!));
  }

  // Close Camera
  // Future<void> closeCamera() async {
  //   try {
  //     await controller?.dispose();
  //     controller = null;
  //     emit(CameraInitial());
  //   } catch (e) {
  //     emit(CameraErrorState("Failed to close camera: $e"));
  //   }
  // }
  // loadkey
  Future loadKey() async {
    try {
      print('load key...');
      ownerId = randomstr(length: 7);
      hkdfNonce = generateHkdfNonce();
      final x25519 = X25519();
      final aes = AesGcm.with256bits();
      aesNonce = aes.newNonce();

      clientKeyPair = await x25519.newKeyPair();
      final clientPublicKey = await clientKeyPair!.extractPublicKey();
      final clientPublicKeyBase64 = base64Encode(clientPublicKey.bytes);
      final response = await http.post(
        Uri.parse('http://172.16.40.5:5000/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'owner_id': ownerId,
          'clientPublicKeyBase64': clientPublicKeyBase64,
          'hkdfNonce': base64Encode(hkdfNonce),
          'aesNonce': base64Encode(aesNonce),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        pubKey = data['pub_key'];
        emit(CameraInitial());
      } else {
        emit(CameraErrorState("try again: $e"));
      }
    } catch (e) {
      emit(CameraErrorState("There is no Internet Connection: $e"));
    }
  }

  // // Encrypt
  Future<void> encrypt() async {
    try {
      final aes = AesGcm.with256bits();
      final x25519 = X25519();

      // 2️⃣ Decode server public key
      if (pubKey == '') {
        return emit(CameraErrorState("There is no Internet Connection: $e"));
      }
      final serverPubKeyBytes = base64Decode(pubKey);
      final serverPublicKey = SimplePublicKey(
        serverPubKeyBytes,
        type: KeyPairType.x25519,
      );

      // 3️⃣ Compute shared secret
      final sharedSecret = await x25519.sharedSecretKey(
        keyPair: clientKeyPair!,
        remotePublicKey: serverPublicKey,
      );

      // 4️⃣ Derive key for sign the Client AES
      final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
      final key = await hkdf.deriveKey(
        secretKey: sharedSecret,
        nonce: hkdfNonce,
      );

      // 5️⃣ Encrypt
      final secretBox = await aes.encrypt(
        byteImage!.toList(),
        secretKey: key,
        nonce: aesNonce,
      );
      print('0');

      databody = {
        "ciphertext": secretBox.cipherText,
        "mac": secretBox.mac.bytes,
      };
      print(databody);
      final current = state;
      if (current is CameraCapturedState) {
        emit(
          current.copyWith(
            encryptStatus: EncStatus.done,
            uploadStatus: UploadStatus.not,
          ),
        );
      }
    } catch (e) {
      emit(CameraErrorState("There is no Internet Connection: $e"));
    }
  }

  Future<void> uploxad() async {
    print('2');
    final response = await http.post(
      Uri.parse('http://172.16.40.5:5000/data'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({...databody!, 'owner_id': ownerId}),
    );
    print('2');

    if (response.statusCode == 200) {
      print("Uploaded");
      final current = state;

      if (current is CameraCapturedState) {
        if (current.uploadStatus == UploadStatus.done) {
          emit(
            current.copyWith(
              encryptStatus: EncStatus.done,
              uploadStatus: UploadStatus.done,
            ),
          );
        }
        emit(
          current.copyWith(
            encryptStatus: EncStatus.done,
            uploadStatus: UploadStatus.done,
          ),
        );
      }
    } else {
      throw Exception('Failed to load Server Response');
    }
  }
}
