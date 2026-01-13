import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _selectedImgae;
  String? _responseText;
  dynamic pkey;

  @override
  void initState() {
    super.initState();
    _postData();
  }

  Future<void> _postData() async {
    final url = Uri.parse('http://10.0.2.2:8000/');

    final body = jsonEncode({'body': 'POST request from Flutter'});

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _responseText = response.body;
        });
      } else {
        setState(() {
          _responseText = 'Failed ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text('Flutter App', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _pickGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _pickCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Camera',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _selectedImgae != null
                  ? Image.file(_selectedImgae!)
                  : Text('Select an Image'),
              const SizedBox(height: 100),

              Text(_responseText ?? 'Null Input'),
            ],
          ),
        ),
      ),
    );
  }

  Future _pickGallery() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (returnedImage == null) return;
    setState(() {
      _selectedImgae = File(returnedImage.path);
    });
  }

  Future _pickCamera() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (returnedImage == null) return;
    setState(() {
      _selectedImgae = File(returnedImage.path);
    });
  }
}
