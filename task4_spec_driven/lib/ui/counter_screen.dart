import 'package:flutter/material.dart';

import '../counter/counter_controller.dart';
import '../counter/thread_counter.dart';

/// The single screen of the app.
///
/// Layout from section 6 of the functional specification; see section 6.4 of
/// docs/02-technical-spec.md.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key, this.counter = const PlatformThreadCounter()});

  final ThreadCounter counter;

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  late final CounterController _controller =
      CounterController(counter: widget.counter);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task 4 - Odd/Even Threads')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (BuildContext context, Widget? child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NumberLabel(
                  value: _controller.currentValue,
                  thread: _controller.currentThread,
                ),
                const SizedBox(height: 16),
                _StatusLine(
                  status: _controller.status,
                  errorMessage: _controller.errorMessage,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('startButton'),
                        onPressed:
                            _controller.isRunning ? null : _controller.start,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('stopButton'),
                        onPressed:
                            _controller.isRunning ? _controller.stop : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Sequence', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Expanded(child: _SequenceList(history: _controller.history)),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The label both threads take turns updating (FR-3, FR-7).
class _NumberLabel extends StatelessWidget {
  const _NumberLabel({required this.value, required this.thread});

  final int? value;
  final CounterThread? thread;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color background = switch (thread) {
      null => colors.surfaceContainerHighest,
      CounterThread.odd => colors.primaryContainer,
      CounterThread.even => colors.tertiaryContainer,
    };

    return Container(
      key: const Key('label'),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
          Text(
            thread == null ? ' ' : '${thread!.name} thread',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.status, required this.errorMessage});

  final CounterStatus status;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final String label = switch (status) {
      CounterStatus.idle => 'Idle',
      CounterStatus.running => 'Running',
      CounterStatus.stopped => 'Stopped',
      CounterStatus.finished => 'Finished',
    };
    return Text(
      errorMessage == null ? 'Status: $label' : 'Status: $label ($errorMessage)',
      key: const Key('status'),
      textAlign: TextAlign.center,
    );
  }
}

/// Every number of the run with its thread, so the order can be checked (FR-8).
class _SequenceList extends StatelessWidget {
  const _SequenceList({required this.history});

  final List<NumberEvent> history;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        key: const Key('sequence'),
        itemCount: history.length,
        itemBuilder: (BuildContext context, int index) {
          final NumberEvent event = history[index];
          final bool isOdd = event.thread == CounterThread.odd;
          return Text(
            '${event.value.toString().padLeft(2)}  (${event.thread.name} thread)',
            style: TextStyle(
              fontFamily: 'monospace',
              color: isOdd ? colors.primary : colors.tertiary,
            ),
          );
        },
      ),
    );
  }
}
