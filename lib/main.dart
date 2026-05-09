import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nbox',
      home: Scaffold(
        appBar: AppBar(title: const Text('Nbox - 牛盒')),
        body: const Center(child: Text('Nbox v1.0.0')),
      ),
    );
  }
}
