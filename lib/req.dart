import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter POST on App Start',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _responseText = "Sending POST request...";

  @override
  void initState() {
    super.initState();
    sendPostRequest();
  }

  Future<void> sendPostRequest() async {
    final url = Uri.parse(
      'https://jsonplaceholder.typicode.com/posts',
    ); // Replace with your API endpoint

    final body = jsonEncode({
      'title': 'Hello Flutter',
      'body': 'This is a POST request sent on app start',
      'userId': 1,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('POST successful: ${response.body}');
        setState(() {
          _responseText = 'POST Successful!\nResponse:\n${response.body}';
        });
      } else {
        print('Failed POST: ${response.statusCode} ${response.body}');
        setState(() {
          _responseText = 'POST Failed: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _responseText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POST on App Start')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_responseText, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
