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
import 'package:path/path.dart';
import 'package:async/async.dart';

late SimpleKeyPair clientKeyPair;
late String clientPublicKeyBase64;
bool uploaded = false;
String randomString = generateRandomString(7);
Uint8List? imageAsBytes;

String? owner_id;
String? pubKey;
String? jwt;

Future<Res> fetchKey(String randomString) async {
  final x25519 = X25519();

  clientKeyPair = await x25519.newKeyPair();
  final clientPublicKey = await clientKeyPair.extractPublicKey();
  clientPublicKeyBase64 = base64.encode(clientPublicKey.bytes);

  final response = await http.post(
    Uri.parse('http://localhost:5000/key'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'owner_id': randomString,
      'clientPublicKeyBase64': clientPublicKeyBase64,
    }),
  );

  if (response.statusCode == 200) {
    return Res.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load Server Response');
  }
}

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CameraPage());
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Run immediately on app start
    final String randomnumber = generateRandomString(7);
    // fetchKey(randomnumber).then((Res res) {
    //   pubKey = res.pubKey;
    //   owner_id = res.ownerId;
    //   jwt = res.jwt;
    // });

    // Then run every 5 minutes
    // _fetchAndSchedule();
  }

  // VARIABLES
  CameraController? _controller;
  Uint8List? _webImage;
  XFile? _capturedImage;
  bool _showCamera = false;
  int? _statusCode;

  Future<Res>? _futureKey;
  String? clientPublicKeyBase64;
  SimpleKeyPair? clientKeyPair;

  // req to server

  // Take from Camera
  Future<void> _openCamera() async {
    try {
      _controller = null;
      _capturedImage = null;
      _webImage = null;
      _showCamera = true;
      uploaded = false;

      final List<CameraDescription> cameras = await availableCameras();
      final CameraDescription backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _showCamera = true;
      });
    } on CameraException catch (e) {
      debugPrint("Camera error: ${e.description}");
    }
  }

  Future<void> _takePicture() async {
    final dynamic image = await _controller!.takePicture();

    if (image == null) return;
    imageAsBytes = await image.readAsBytes();

    if (kIsWeb) {
      setState(() {
        _webImage = imageAsBytes;
        _showCamera = false;
      });
    } else {
      setState(() {
        _capturedImage = image;
        _showCamera = false;
      });
    }
  }

  // Take From Gallery
  Future _openGallery() async {
    _controller = null;
    _capturedImage = null;
    _webImage = null;
    uploaded = false;

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: null,
      requestFullMetadata: false,
    );

    if (image == null) return;

    imageAsBytes = await image.readAsBytes();

    if (kIsWeb) {
      setState(() {
        _webImage = imageAsBytes;
        _showCamera = false;
      });
    } else {
      setState(() {
        _capturedImage = image;
        _showCamera = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          title: const Text(
            'Flutter App',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<Res>(
                      future: _futureKey, // ✅ use stored Future
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Text('pubKey: ${snapshot.data!.pubKey}');
                        }
                        return const Text('No data');
                      },
                    ),

                    /// GALLERY BUTTON
                    ElevatedButton(
                      onPressed: _openGallery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Gallery",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// CAMERA BUTTON
                    ElevatedButton(
                      onPressed: _openCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Camera",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (_capturedImage != null || _webImage != null)
                      ElevatedButton(
                        onPressed: () {
                          upload(imageAsBytes!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: uploaded == true
                            ? const Text(
                                "Done!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                "Upload",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                /// CAMERA PREVIEW
                if (_showCamera && _controller != null)
                  Stack(
                    children: [
                      CameraPreview(_controller!),

                      /// TAKE BUTTON
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: _takePicture,
                          child: const Text(
                            "Take",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),

                /// CAPTURED IMAGE
                if (_capturedImage != null)
                  Image.file(File(_capturedImage!.path), fit: BoxFit.cover)
                else if (kIsWeb && _webImage != null)
                  Image.memory(_webImage!)
                else if (_capturedImage == null &&
                    _webImage == null &&
                    _showCamera == false)
                  const SizedBox(height: 200, child: Text('select the image')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
