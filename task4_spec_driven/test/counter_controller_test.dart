import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task4_spec_driven/counter/counter_controller.dart';
import 'package:task4_spec_driven/counter/thread_counter.dart';

import 'fake_thread_counter.dart';

void main() {
  late FakeThreadCounter counter;
  late CounterController controller;

  setUp(() {
    counter = FakeThreadCounter();
    controller = CounterController(counter: counter);
  });

  tearDown(() => controller.dispose());

  test('starts idle, with no number', () {
    expect(controller.status, CounterStatus.idle);
    expect(controller.currentValue, isNull);
    expect(controller.history, isEmpty);
  });

  test('start() runs to the limit of 20, half a second per number', () {
    controller.start();

    expect(controller.status, CounterStatus.running);
    expect(counter.lastLimit, 20);
    expect(counter.lastStepDelay, const Duration(milliseconds: 500));
    expect(counter.isListening, isTrue);
  });

  test('numbers update the label and the history, in order', () {
    controller.start();
    counter.sendNumber(1);
    counter.sendNumber(2);

    expect(controller.currentValue, 2);
    expect(controller.currentThread, CounterThread.even);
    expect(controller.history, const <NumberEvent>[
      NumberEvent(1, CounterThread.odd),
      NumberEvent(2, CounterThread.even),
    ]);
  });

  test('the finished event ends the run and keeps the last number', () {
    controller.start();
    counter.sendNumber(1);
    counter.sendFinished();

    expect(controller.status, CounterStatus.finished);
    expect(controller.currentValue, 1);
    expect(counter.isListening, isFalse);
  });

  test('stop() cancels the run and keeps the last number', () {
    controller.start();
    counter.sendNumber(1);
    counter.sendNumber(2);
    controller.stop();

    expect(controller.status, CounterStatus.stopped);
    expect(controller.currentValue, 2);
    expect(counter.isListening, isFalse);
  });

  test('start() after a run clears the history and runs again', () {
    controller.start();
    counter.sendNumber(1);
    controller.stop();

    controller.start();

    expect(controller.status, CounterStatus.running);
    expect(controller.history, isEmpty);
    expect(controller.currentValue, isNull);
    expect(counter.runs, 2);
  });

  test('start() and stop() are ignored in the wrong state', () {
    controller.stop();
    expect(controller.status, CounterStatus.idle);

    controller.start();
    controller.start();
    expect(counter.runs, 1);
  });

  test('a platform error stops the run and keeps its message', () {
    controller.start();
    counter.sendError(
      PlatformException(code: 'INVALID_ARGUMENT', message: 'Bad limit'),
    );

    expect(controller.status, CounterStatus.stopped);
    expect(controller.errorMessage, 'Bad limit');
    expect(counter.isListening, isFalse);
  });

  test('dispose() cancels a running run', () {
    final CounterController disposable = CounterController(counter: counter);
    disposable.start();
    disposable.dispose();

    expect(counter.isListening, isFalse);
  });
}
