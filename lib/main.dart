import 'package:flutter/material.dart';

void main() {
  runApp(const NboxApp());
}

class NboxApp extends StatelessWidget {
  const NboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nbox',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nbox'),
      ),
      body: const Center(
        child: Text('Hello Nbox!'),
      ),
    );
  }
}
