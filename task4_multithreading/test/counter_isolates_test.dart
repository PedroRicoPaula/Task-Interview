import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:task4_multithreading/counter_isolates.dart';

void main() {
  test('both isolates produce 1..20 in order, alternating odd and even',
      () async {
    final SyncCounter counter = SyncCounter(limit: 20);
    final List<CounterTick> ticks = <CounterTick>[];
    final Completer<void> finished = Completer<void>();

    await counter.start(
      onTick: ticks.add,
      onFinished: finished.complete,
    );

    await finished.future.timeout(const Duration(seconds: 10));

    // The sequence is complete and strictly ordered.
    expect(
      ticks.map((CounterTick tick) => tick.value),
      List<int>.generate(20, (int index) => index + 1),
    );

    // Odd numbers came from the odd isolate and even ones from the even isolate.
    for (final CounterTick tick in ticks) {
      expect(
        tick.kind,
        tick.value.isOdd ? CounterKind.odd : CounterKind.even,
      );
    }
  });

  test('stop() interrupts the count', () async {
    final SyncCounter counter = SyncCounter(
      limit: 1000,
      delay: const Duration(milliseconds: 5),
    );
    final List<CounterTick> ticks = <CounterTick>[];

    await counter.start(onTick: ticks.add, onFinished: () {});

    await Future<void>.delayed(const Duration(milliseconds: 120));
    counter.stop();
    final int countAtStop = ticks.length;

    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(ticks.length, countAtStop);
    expect(countAtStop, lessThan(1000));
    expect(counter.isRunning, isFalse);
  });
}
