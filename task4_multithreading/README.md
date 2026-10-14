# Task 4 - Multithreading

> Implement two threads. The first thread should count odd numbers, while the
> second thread counts even numbers. Both threads should take turns updating a
> label to display the numbers in sequence (e.g., 1, 2, 3, 4, etc.) in a
> synchronized manner.

Pressing **Count to 20** starts two isolates. The odd one and the even one take
turns updating a single label, so it shows 1, 2, 3, ... 20 in order. The label
is colored by the isolate that wrote the current number, and the list below it
records the full sequence.

- **Synchronization logic:** [`lib/counter_isolates.dart`](lib/counter_isolates.dart)
- **Screen:** [`lib/main.dart`](lib/main.dart)
- **Tests:** [`test/counter_isolates_test.dart`](test/counter_isolates_test.dart), [`test/widget_test.dart`](test/widget_test.dart)
- **APK:** [`apk/task4_multithreading.apk`](../apk/task4_multithreading.apk)

## How the synchronization works

Dart has no threads that share mutable memory. Its concurrency model is based on
_isolates_: each isolate owns its heap and event loop, and isolates communicate
only through messages (`SendPort` / `ReceivePort`). So synchronization is not
done with `synchronized` / `wait()` / `notify()` as it would be in Java, but by
passing a single **turn token** back and forth.

Exactly one token exists, so only one isolate is ever allowed to write at a
time, which guarantees the `1, 2, 3, 4, ...` order:

```
odd  -> emits 1 -> hands the token over -> waits
even -> emits 2 -> hands the token over -> waits
odd  -> emits 3 -> ...
```

Implementation notes:

- `_counterWorker` is a top-level function, as required by `Isolate.spawn`.
- Each worker blocks on a `StreamIterator` over its own `ReceivePort`, so a
  worker only resumes when it receives the token.
- At startup the two workers exchange ports through a short handshake. The even
  worker is wired first so its partner port always arrives before the first
  token.
- `stop()` kills both isolates; the screen also calls it from `dispose()`.
- The UI isolate never blocks: it only listens to the numbers and calls
  `setState`.

The equivalent on native Android would be two `Thread`s sharing a lock, using
`wait()` / `notifyAll()` on a shared "whose turn is it" flag and posting the
label update with `runOnUiThread`.

Because `dart:isolate` is not available on Flutter Web, this app targets
Android only.

## Run

```
flutter pub get
flutter run
```

## Test

```
flutter test
```

`counter_isolates_test.dart` checks that the two isolates produce exactly
`1, 2, 3, ... 20` in order, with every odd number coming from the odd isolate
and every even number from the even one, and that `stop()` interrupts the count.

Requirements and screenshots are in the [repository README](../README.md).
