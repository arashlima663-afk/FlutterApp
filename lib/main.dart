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

import 'package:path/path.dart';
import 'package:async/async.dart';

Future<Res> fetchKey(String randomString) async {
  final x25519 = X25519();

  Variables.clientKeyPair = await x25519.newKeyPair();
  final clientPublicKey = await Variables.clientKeyPair.extractPublicKey();
  Variables.clientPublicKeyBase64 = base64.encode(clientPublicKey.bytes);

  final response = await http.post(
    Uri.parse('http://localhost:5000/key'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'owner_id': randomString,
      'clientPublicKeyBase64': Variables.clientPublicKeyBase64,
    }),
  );

  if (response.statusCode == 200) {
    return Res.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load Server Response');
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

    // Then run every 5 minutes
    // _fetchAndSchedule();
  }

  // VARIABLES

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Variables.controller!.dispose();
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
                    /// GALLERY BUTTON
                    ElevatedButton(
                      onPressed: () async {
                        await openGallery();
                        Variables.updateImage(
                          await Variables.capturedImage!.readAsBytes(),
                        );
                      },
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
                      onPressed: () {},
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
                    if (Variables.capturedImage != null ||
                        Variables.webImage != null)
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            print('Hi');
                            print(Variables.streamImage);
                            final encryptedStream = encrypt(
                              stream: Variables.streamImage!,
                            );
                            final response = await upload(
                              byteStream: encryptedStream,
                            );
                            print(response.statusCode);
                          } catch (e) {
                            print(e);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Variables.uploaded == true
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
                if (Variables.showCamera && controller != null)
                  Stack(
                    children: [
                      CameraPreview(Variables.controller!),

                      /// TAKE BUTTON
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {},
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
                StreamBuilder<Uint8List?>(
                  stream: Variables.imageStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    }

                    if (Variables.showCamera) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: Text('Camera preview')),
                      );
                    }

                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('Select the image')),
                    );
                  },
                ),
                const SizedBox(height: 200, child: Text('select the image')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
