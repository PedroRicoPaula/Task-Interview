import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'thread_counter.dart';

/// The states of the screen, from section 6 of the functional specification.
enum CounterStatus { idle, running, stopped, finished }

/// Holds the screen state and starts and stops runs.
///
/// See section 6.3 of docs/02-technical-spec.md.
class CounterController extends ChangeNotifier {
  CounterController({this._counter = const PlatformThreadCounter()});

  /// Last number of a run (functional specification, Q-2).
  static const int limit = 20;

  /// How long each number stays on screen (functional specification, Q-3).
  static const Duration stepDelay = Duration(milliseconds: 500);

  final ThreadCounter _counter;
  StreamSubscription<CounterEvent>? _subscription;

  final List<NumberEvent> _history = <NumberEvent>[];
  CounterStatus _status = CounterStatus.idle;
  String? _errorMessage;

  CounterStatus get status => _status;

  /// Every number of the current run, in order, with its thread.
  List<NumberEvent> get history => List<NumberEvent>.unmodifiable(_history);

  /// The number in the label, or null before the first number.
  int? get currentValue => _history.isEmpty ? null : _history.last.value;

  /// The thread that published [currentValue].
  CounterThread? get currentThread =>
      _history.isEmpty ? null : _history.last.thread;

  /// Set when the platform reports an error.
  String? get errorMessage => _errorMessage;

  bool get isRunning => _status == CounterStatus.running;

  /// Clears the previous result and starts a new run (FR-9, FR-12).
  void start() {
    if (isRunning) return;
    _history.clear();
    _errorMessage = null;
    _status = CounterStatus.running;
    _subscription = _counter
        .run(limit: limit, stepDelay: stepDelay)
        .listen(_onEvent, onError: _onError);
    notifyListeners();
  }

  /// Ends the run early and keeps the last number (FR-10).
  void stop() {
    if (!isRunning) return;
    _cancelRun();
    _status = CounterStatus.stopped;
    notifyListeners();
  }

  void _onEvent(CounterEvent event) {
    if (!isRunning) return;
    switch (event) {
      case NumberEvent():
        _history.add(event);
      case FinishedEvent():
        _cancelRun();
        _status = CounterStatus.finished;
    }
    notifyListeners();
  }

  void _onError(Object error) {
    if (!isRunning) return;
    _cancelRun();
    _status = CounterStatus.stopped;
    _errorMessage = switch (error) {
      PlatformException(:final String? message, :final String code) =>
        message ?? code,
      _ => '$error',
    };
    notifyListeners();
  }

  /// Cancelling the subscription stops the threads on the platform side.
  void _cancelRun() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _cancelRun(); // FR-13: leaving the screen stops the threads.
    super.dispose();
  }
}
