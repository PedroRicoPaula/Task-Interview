import 'dart:async';
import 'dart:isolate';

/// Task 4 - the "two synchronized threads" logic.
///
/// Dart has no threads sharing mutable memory. Its concurrency model is based on
/// *isolates*: each one owns its heap and event loop and they communicate only
/// through messages ([SendPort] / [ReceivePort]).
///
/// Because of that, synchronization is not done with `synchronized` / `wait()` /
/// `notify()` as it would be in Java, but by passing a single **turn token**
/// back and forth. Exactly one token exists, so only one isolate is ever
/// allowed to write at a time, which guarantees the 1, 2, 3, 4, ... order:
///
///     odd  -> emits 1 -> hands the token over -> waits
///     even -> emits 2 -> hands the token over -> waits
///     odd  -> emits 3 -> ...

/// Identifies which isolate produced a number.
enum CounterKind { odd, even }

/// A number produced by one of the isolates.
class CounterTick {
  const CounterTick(this.value, this.kind);

  final int value;
  final CounterKind kind;
}

/// Marker sent to the UI when a worker has finished.
class CounterFinished {
  const CounterFinished();
}

/// Tokens exchanged between the two workers.
enum _Token { turn, stop }

/// Configuration handed to an isolate at spawn time.
class _CounterConfig {
  const _CounterConfig({
    required this.uiPort,
    required this.handshakePort,
    required this.kind,
    required this.start,
    required this.limit,
    required this.goesFirst,
    required this.delay,
  });

  /// Port of the main isolate, where numbers are published for the UI.
  final SendPort uiPort;

  /// Port used once, to hand this worker's own port back to the main isolate.
  final SendPort handshakePort;

  final CounterKind kind;

  /// 1 for the odd worker, 2 for the even one.
  final int start;

  /// Last number to count.
  final int limit;

  /// The odd worker starts; the even one waits for its turn.
  final bool goesFirst;

  /// Pause between numbers, only so the count is visible on screen.
  final Duration delay;
}

/// Entry point of each isolate. Must be a top-level (or static) function.
Future<void> _counterWorker(_CounterConfig config) async {
  // Port on which this worker receives the turn token.
  final ReceivePort turnPort = ReceivePort();
  final StreamIterator<dynamic> turns = StreamIterator<dynamic>(turnPort);

  // Hand our own port back so the main isolate can wire both workers together.
  config.handshakePort.send(turnPort.sendPort);

  // The first message received is the partner's port.
  if (!await turns.moveNext()) {
    turnPort.close();
    return;
  }
  final SendPort partner = turns.current as SendPort;

  int value = config.start;

  // Whoever does not start blocks here until the token arrives.
  if (!config.goesFirst) {
    if (!await turns.moveNext() || turns.current == _Token.stop) {
      await turns.cancel();
      turnPort.close();
      return;
    }
  }

  while (value <= config.limit) {
    await Future<void>.delayed(config.delay);

    // Critical section: this isolate holds the only token, so it writes alone.
    config.uiPort.send(CounterTick(value, config.kind));
    value += 2;

    // Hand the turn over and block until we get it back.
    partner.send(_Token.turn);
    if (!await turns.moveNext() || turns.current == _Token.stop) {
      break;
    }
  }

  // Done: release the partner and tell the UI this worker has finished.
  partner.send(_Token.stop);
  config.uiPort.send(const CounterFinished());
  await turns.cancel();
  turnPort.close();
}

/// Drives the two counting isolates from the main isolate.
class SyncCounter {
  SyncCounter({
    required this.limit,
    this.delay = Duration.zero,
  });

  /// Last number to count, shared by both workers.
  final int limit;

  /// Pause applied before each number, to make the count visible.
  final Duration delay;

  Isolate? _oddIsolate;
  Isolate? _evenIsolate;
  ReceivePort? _uiPort;
  int _workersDone = 0;

  bool get isRunning => _oddIsolate != null;

  /// Spawns both isolates and starts counting.
  ///
  /// [onTick] is called for every number produced, [onFinished] once both
  /// isolates have completed.
  Future<void> start({
    required void Function(CounterTick tick) onTick,
    required void Function() onFinished,
  }) async {
    if (isRunning) return;

    _workersDone = 0;
    final ReceivePort uiPort = ReceivePort();
    _uiPort = uiPort;

    uiPort.listen((dynamic message) {
      if (message is CounterTick) {
        onTick(message);
      } else if (message is CounterFinished) {
        _workersDone++;
        if (_workersDone == 2) {
          stop();
          onFinished();
        }
      }
    });

    final ReceivePort handshake = ReceivePort();
    final StreamIterator<dynamic> handshakes =
        StreamIterator<dynamic>(handshake);

    final SendPort oddTurnPort = await _spawnWorker(
      uiPort: uiPort.sendPort,
      handshake: handshake,
      handshakes: handshakes,
      kind: CounterKind.odd,
      start: 1,
      goesFirst: true,
    );
    final SendPort evenTurnPort = await _spawnWorker(
      uiPort: uiPort.sendPort,
      handshake: handshake,
      handshakes: handshakes,
      kind: CounterKind.even,
      start: 2,
      goesFirst: false,
    );

    // Introduce the workers to each other. The even worker is wired first so
    // that its partner port always arrives before the first turn token.
    evenTurnPort.send(oddTurnPort);
    oddTurnPort.send(evenTurnPort);

    await handshakes.cancel();
    handshake.close();
  }

  Future<SendPort> _spawnWorker({
    required SendPort uiPort,
    required ReceivePort handshake,
    required StreamIterator<dynamic> handshakes,
    required CounterKind kind,
    required int start,
    required bool goesFirst,
  }) async {
    final Isolate isolate = await Isolate.spawn(
      _counterWorker,
      _CounterConfig(
        uiPort: uiPort,
        handshakePort: handshake.sendPort,
        kind: kind,
        start: start,
        limit: limit,
        goesFirst: goesFirst,
        delay: delay,
      ),
      debugName: '${kind.name}-counter',
    );

    if (kind == CounterKind.odd) {
      _oddIsolate = isolate;
    } else {
      _evenIsolate = isolate;
    }

    await handshakes.moveNext();
    return handshakes.current as SendPort;
  }

  /// Kills both isolates and closes the ports.
  void stop() {
    _oddIsolate?.kill(priority: Isolate.immediate);
    _evenIsolate?.kill(priority: Isolate.immediate);
    _oddIsolate = null;
    _evenIsolate = null;
    _uiPort?.close();
    _uiPort = null;
  }
}
