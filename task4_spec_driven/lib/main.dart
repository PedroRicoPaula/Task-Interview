import 'package:flutter/material.dart';

import 'counter/thread_counter.dart';
import 'ui/counter_screen.dart';

void main() {
  runApp(const OddEvenThreadsApp());
}

class OddEvenThreadsApp extends StatelessWidget {
  const OddEvenThreadsApp({
    super.key,
    this.counter = const PlatformThreadCounter(),
  });

  /// Replaced by a fake in widget tests.
  final ThreadCounter counter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odd/Even Threads',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: CounterScreen(counter: counter),
    );
  }
}
