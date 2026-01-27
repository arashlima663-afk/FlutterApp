// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cryptography/cryptography.dart';
// import 'package:cryptography/dart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'dart:math';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:async';
// import 'package:camera/camera.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(debugShowCheckedModeBanner: false, home: Home());
//   }
// }

// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   // for picture
//   CameraController? _controller;
//   XFile? _capturedImage;
//   bool _showCamera = false;

//   final bool isWeb = kIsWeb;
//   File? _selectedImgae;
//   File? _mobileImage;
//   Uint8List? _webImage;
//   late CameraController controller;
//   // serverPublicKey
//   List<int>? serverPublicKey;
//   String? status1;
//   //
//   Uint8List? _imageAsBytes;
//   List<int>? secretImg;
//   List<int>? secretKeyBytes;
//   // final img = [..._imageAsBytes!, ...secretKeyBytes];

//   // late CameraController controller;
//   // late List<CameraDescription> cameras;
//   // Uint8List? capturedImage;

//   Future<void> _openCamera() async {
//     final cameras = await availableCameras();
//     _controller = CameraController(
//       cameras.first,
//       ResolutionPreset.ultraHigh,
//       enableAudio: false,
//     );

//     await _controller!.initialize();

//     setState(() {
//       _showCamera = true;
//     });
//   }

//   Future<void> _takePicture() async {
//     if (_controller == null || !_controller!.value.isInitialized) return;

//     final image = await _controller!.takePicture();

//     setState(() {
//       _capturedImage = image;
//       _showCamera = false;
//     });
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _postData();
//   }

//   // init post req for pub key
//   Future<void> _postData() async {
//     final url = Uri.parse('http://10.0.2.2:8000');
//     final body = jsonEncode({'body': 'request for serverPublicKey'});

//     try {
//       final response = await http.post(
//         url,
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: body,
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final Uint8List serverPubBytes = base64Decode(data['public_key']);
//         final SimplePublicKey serverPublicKey = SimplePublicKey(
//           serverPubBytes,
//           type: KeyPairType.x25519,
//         );
//         setState(() {
//           serverPublicKey;
//         });
//       } else {
//         setState(() {
//           status1 = "Status: ${response.statusCode}\n\n${response.body}!!";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         status1 = 'Error: $e !!';
//       });
//     }
//   }

//   // aes encrypt
//   // Future<Map<String, Uint8List>> encryptWithX25519({
//   //   required List<int> imageBytes,
//   //   required SimplePublicKey serverPublicKey,
//   // }) async {
//   //   final x25519 = X25519();
//   //   final clientKeyPair = await x25519.newKeyPair();
//   //   final clientPublicKey = await clientKeyPair.extractPublicKey();
//   //   final sharedSecretKey = await x25519.sharedSecretKey(
//   //     keyPair: clientKeyPair,
//   //     remotePublicKey: serverPublicKey,
//   //   );
//   // }

//   //   setState(() {});
//   // }
//   /// HKDF key derivation
//   Future<List<int>> _hkdfSha256(SecretKey sharedSecret, int length) async {
//     final algorithm = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
//     final secretKey = SecretKey([1, 2, 3]);
//     final nonce = [4, 5, 6];
//     final output = await algorithm.deriveKey(
//       secretKey: secretKey,
//       nonce: nonce,
//     );
//     final List<int> out = await output.extractBytes();
//     return out;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 0, 0, 0),
//         title: const Text('Flutter App', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.only(top: 30),
//           child: Align(
//             alignment: Alignment.topCenter,
//             child: Column(
//               children: [
//                 SizedBox(
//                   width: 200,
//                   child: ElevatedButton(
//                     onPressed: _pickGallery,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     child: const Text(
//                       'Gallery',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 _selectedImgae == null
//                     ? Align(
//                         alignment: Alignment.topCenter,
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               width: 200,
//                               child: ElevatedButton(
//                                 onPressed: _openCamera,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue,
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 15,
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'Camera',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 50),
//                             Text('select the image'),
//                           ],
//                         ),
//                       )
//                     : Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               SizedBox(
//                                 width: 200,
//                                 child: ElevatedButton(
//                                   onPressed: _pickCamera,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.blue,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 15,
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'Take New',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               SizedBox(
//                                 width: 200,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     // Logic for the new "UP" button
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 16,
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'Upload',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           if (kIsWeb)
//                             Image.memory(
//                               _webImage!,
//                               height: 250,
//                               fit: BoxFit.cover,
//                             )
//                           else
//                             Image.file(_selectedImgae!, fit: BoxFit.fill),

//                           SizedBox(height: 20),
//                         ],
//                       ),
//                 const SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future _pickGallery() async {
//     final returnedImage = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//     );

//     if (returnedImage == null) return;
//     if (kIsWeb) {
//       _webImage = await returnedImage.readAsBytes();
//     } else {
//       _mobileImage = File(returnedImage.path);
//     }
//     setState(() {
//       _webImage == null ? _mobileImage : _webImage;
//     });
//   }

//   Future<void> captureImageMobile() async {
//     final cameras = await availableCameras();

//     controller = CameraController(
//       cameras.first,
//       ResolutionPreset.high,
//       enableAudio: false,
//       imageFormatGroup: ImageFormatGroup.jpeg,
//     );

//     await controller.initialize();

//     final XFile imageFile = await controller.takePicture();
//     if (imageFile.path.isEmpty) return;

//     final bytes = await File(imageFile.path).readAsBytes();

//     setState(() {
//       capturedImage = bytes;
//       _selectedImgae = File(imageFile.path);
//     });
//   }

//   Future _pickCamera() async {
//     _selectedImgae = null;
//     final returnedImage = await ImagePicker().pickImage(
//       source: ImageSource.camera,
//       imageQuality: 100,
//     );

//     _imageAsBytes = await returnedImage?.readAsBytes();

//     if (returnedImage == null) return;
//     setState(() {
//       _selectedImgae = File(returnedImage.path);
//       _imageAsBytes;
//     });
//   }

//   //
// }
