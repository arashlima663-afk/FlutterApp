import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// The main function is the entry point of the application
void main() {
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

// String title
class _HomeState extends State<Home> {
  String? _data;

  fetchdata() async {
    var response = await http.get(
      Uri.parse('http://localhost:5000/key'),
      // body: jsonEncode(<String, String>{'title': title}),
    );
    setState(() {
      _data = response.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Title of the application
      title: 'GeeksforGeeks',
      // Theme of the application
      theme: ThemeData(primarySwatch: Colors.green),
      // Dark theme of the application
      darkTheme: ThemeData(primarySwatch: Colors.grey),
      // Color of the application
      color: Colors.amberAccent,
      // Supported locales for the application
      supportedLocales: {const Locale('en', ' ')},
      // Disable the debug banner
      debugShowCheckedModeBanner: false,

      // Home screen of the application
      home: Scaffold(
        appBar: AppBar(
          // Title of the app bar
          title: const Text('GeeksforGeeks'),
          // Background color of the app bar
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
            ElevatedButton(onPressed: fetchdata, child: Text('f')),
            ElevatedButton(onPressed: () {}, child: Text('c')),
            ElevatedButton(onPressed: () {}, child: Text('d')),
            Expanded(child: Text(_data ?? 'Loading...')),
          ],
        ),
      ),
    );
  }
}
