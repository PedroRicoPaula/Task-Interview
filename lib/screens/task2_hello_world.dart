import 'package:flutter/material.dart';

/// Task 2 - "Create Your First App: Build a simple Hello World application."
class Task2HelloWorldScreen extends StatelessWidget {
  const Task2HelloWorldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task 2 - Hello World')),
      body: const Center(
        child: Text(
          'Hello World',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
