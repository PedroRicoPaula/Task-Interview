import 'dart:async';

import 'package:task4_spec_driven/counter/thread_counter.dart';

/// A [ThreadCounter] driven by the test instead of the Kotlin threads.
class FakeThreadCounter implements ThreadCounter {
  StreamController<CounterEvent>? _run;

  int? lastLimit;
  Duration? lastStepDelay;
  int runs = 0;

  /// Whether the current run still has a subscriber.
  bool get isListening => _run?.hasListener ?? false;

  @override
  Stream<CounterEvent> run({required int limit, required Duration stepDelay}) {
    lastLimit = limit;
    lastStepDelay = stepDelay;
    runs++;
    // Synchronous, so each event reaches the controller as soon as it is sent.
    _run = StreamController<CounterEvent>(sync: true);
    return _run!.stream;
  }

  void sendNumber(int value) => _run!.add(
        NumberEvent(value, value.isOdd ? CounterThread.odd : CounterThread.even),
      );

  void sendFinished() => _run!.add(const FinishedEvent());

  void sendError(Object error) => _run!.addError(error);
}
