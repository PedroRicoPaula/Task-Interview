import 'package:flutter/services.dart';

/// The thread that published a number.
enum CounterThread { odd, even }

/// An event from a counting run.
///
/// See section 6.1 of docs/02-technical-spec.md.
sealed class CounterEvent {
  const CounterEvent();

  /// Decodes a message from the platform channel.
  ///
  /// Throws a [FormatException] for anything that is not a valid event.
  factory CounterEvent.fromMessage(Object? message) {
    if (message is! Map) {
      throw FormatException('Expected a map', message);
    }
    switch (message['type']) {
      case 'number':
        final Object? value = message['value'];
        final CounterThread? thread = switch (message['thread']) {
          'odd' => CounterThread.odd,
          'even' => CounterThread.even,
          _ => null,
        };
        if (value is! int || thread == null) {
          throw FormatException('Invalid number event', message);
        }
        return NumberEvent(value, thread);
      case 'finished':
        return const FinishedEvent();
      default:
        throw FormatException('Unknown event type', message);
    }
  }
}

/// A number published by one of the threads.
final class NumberEvent extends CounterEvent {
  const NumberEvent(this.value, this.thread);

  final int value;
  final CounterThread thread;

  @override
  bool operator ==(Object other) =>
      other is NumberEvent && other.value == value && other.thread == thread;

  @override
  int get hashCode => Object.hash(value, thread);

  @override
  String toString() => 'NumberEvent($value, ${thread.name})';
}

/// Both threads have reached the limit.
final class FinishedEvent extends CounterEvent {
  const FinishedEvent();
}

/// Runs the two counting threads.
///
/// See section 6.2 of docs/02-technical-spec.md.
abstract interface class ThreadCounter {
  /// Starts a run. Cancelling the subscription stops it.
  Stream<CounterEvent> run({required int limit, required Duration stepDelay});
}

/// A [ThreadCounter] backed by the two Kotlin threads, through an
/// [EventChannel].
class PlatformThreadCounter implements ThreadCounter {
  const PlatformThreadCounter();

  static const EventChannel _channel =
      EventChannel('com.pedro.task4_spec_driven/counter');

  @override
  Stream<CounterEvent> run({required int limit, required Duration stepDelay}) {
    return _channel
        .receiveBroadcastStream(<String, int>{
          'limit': limit,
          'stepDelayMs': stepDelay.inMilliseconds,
        })
        .map(CounterEvent.fromMessage);
  }
}
