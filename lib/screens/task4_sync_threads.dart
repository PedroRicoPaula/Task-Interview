import 'package:flutter/material.dart';

import '../counter_isolates.dart';

/// Task 4 - "Implement two threads. The first thread should count odd numbers,
/// while the second thread counts even numbers. Both threads should take turns
/// updating a label to display the numbers in sequence (e.g. 1, 2, 3, 4, ...)
/// in a synchronized manner."
///
/// The synchronization itself lives in [SyncCounter]; this screen only renders
/// what the isolates produce.
class Task4SyncThreadsScreen extends StatefulWidget {
  const Task4SyncThreadsScreen({super.key});

  @override
  State<Task4SyncThreadsScreen> createState() => _Task4SyncThreadsScreenState();
}

class _Task4SyncThreadsScreenState extends State<Task4SyncThreadsScreen> {
  static const int _limit = 20;
  static const Duration _delay = Duration(milliseconds: 300);

  SyncCounter? _counter;

  /// The single label both isolates take turns updating.
  String _label = '-';
  CounterKind? _currentKind;
  final List<CounterTick> _history = <CounterTick>[];
  bool _isRunning = false;

  @override
  void dispose() {
    _counter?.stop();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _label = '-';
      _currentKind = null;
      _history.clear();
      _isRunning = true;
    });

    final SyncCounter counter = SyncCounter(limit: _limit, delay: _delay);
    _counter = counter;

    await counter.start(
      onTick: (CounterTick tick) {
        if (!mounted) return;
        setState(() {
          _label = '${tick.value}';
          _currentKind = tick.kind;
          _history.add(tick);
        });
      },
      onFinished: () {
        if (!mounted) return;
        setState(() => _isRunning = false);
      },
    );
  }

  void _stop() {
    _counter?.stop();
    _counter = null;
    setState(() => _isRunning = false);
  }

  Color _backgroundFor(ColorScheme colors) {
    return switch (_currentKind) {
      null => colors.surfaceContainerHighest,
      CounterKind.odd => colors.primaryContainer,
      CounterKind.even => colors.tertiaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Task 4 - Synchronized threads')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The single label updated by both isolates in turn.
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: _backgroundFor(colors),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _label,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    switch (_currentKind) {
                      null => 'idle',
                      CounterKind.odd => 'ODD isolate',
                      CounterKind.even => 'EVEN isolate',
                    },
                    style: const TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isRunning ? null : _start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Count to $_limit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRunning ? _stop : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Produced sequence:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CounterTick tick = _history[index];
                    final bool isOdd = tick.kind == CounterKind.odd;
                    return Text(
                      '${tick.value}  (${isOdd ? 'odd' : 'even'})',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: isOdd ? colors.primary : colors.tertiary,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
