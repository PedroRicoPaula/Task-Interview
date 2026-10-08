import 'package:flutter/material.dart';

import 'screens/task2_hello_world.dart';
import 'screens/task3_label_edittext_button.dart';
import 'screens/task4_sync_threads.dart';

void main() {
  runApp(const InterviewTasksApp());
}

class InterviewTasksApp extends StatelessWidget {
  const InterviewTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Entry point of the app: one entry per task so each one can be reviewed
/// in isolation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interview Tasks')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TaskCard(
            number: 2,
            title: 'Hello World',
            subtitle: 'A simple screen displaying "Hello World".',
            destination: Task2HelloWorldScreen(),
          ),
          _TaskCard(
            number: 3,
            title: 'Label, EditText and Button',
            subtitle:
                'Pressing the button copies the text field content into the label.',
            destination: Task3LabelEditTextButtonScreen(),
          ),
          _TaskCard(
            number: 4,
            title: 'Synchronized threads',
            subtitle:
                'Two isolates take turns writing odd and even numbers to one label.',
            destination: Task4SyncThreadsScreen(),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.destination,
  });

  final int number;
  final String title;
  final String subtitle;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(child: Text('$number')),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => destination),
        ),
      ),
    );
  }
}
