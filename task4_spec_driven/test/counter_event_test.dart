import 'package:flutter_test/flutter_test.dart';
import 'package:task4_spec_driven/counter/thread_counter.dart';

void main() {
  group('CounterEvent.fromMessage', () {
    test('decodes a number event', () {
      expect(
        CounterEvent.fromMessage(<String, Object>{
          'type': 'number',
          'value': 7,
          'thread': 'odd',
        }),
        const NumberEvent(7, CounterThread.odd),
      );
      expect(
        CounterEvent.fromMessage(<String, Object>{
          'type': 'number',
          'value': 8,
          'thread': 'even',
        }),
        const NumberEvent(8, CounterThread.even),
      );
    });

    test('decodes the finished event', () {
      expect(
        CounterEvent.fromMessage(<String, Object>{'type': 'finished'}),
        isA<FinishedEvent>(),
      );
    });

    test('rejects invalid messages', () {
      final List<Object?> invalid = <Object?>[
        null,
        'number',
        <String, Object>{'type': 'unknown'},
        <String, Object>{'type': 'number', 'thread': 'odd'},
        <String, Object>{'type': 'number', 'value': '7', 'thread': 'odd'},
        <String, Object>{'type': 'number', 'value': 7, 'thread': 'third'},
      ];
      for (final Object? message in invalid) {
        expect(
          () => CounterEvent.fromMessage(message),
          throwsFormatException,
          reason: '$message',
        );
      }
    });
  });
}
