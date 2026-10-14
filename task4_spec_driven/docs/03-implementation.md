# Implementation: Odd/Even Thread Counter

- **Project:** Task 4 (Multithreading), spec-driven version
- **Document:** 3 of 3, implementation plan and record
- **Status:** Complete
- **Author:** Pedro Paula, written with Claude Code
- **Date:** 14 October 2026
- **Based on:** [`02-technical-spec.md`](02-technical-spec.md) v1.0

This document turns the technical specification into ordered implementation
steps, and records what happened at each step: the result, the checks that were
run, and any deviation from the specification.

## 1. Plan

Each step ends with a check. The next step only starts when the check passes.

| Step | Work | Spec sections | Check |
| --- | --- | --- | --- |
| 1 | Create the Flutter project for Android only; set the application ID and launcher name | 7, 10 | Project builds |
| 2 | `OddEvenCounter` in Kotlin, with its JUnit tests | 4 | JUnit tests pass |
| 3 | `CounterStreamHandler` and `MainActivity` | 5 | Project builds |
| 4 | Event model, `ThreadCounter` and `PlatformThreadCounter` in Dart, with decoding tests | 5, 6.1, 6.2 | Dart tests pass |
| 5 | `CounterController`, with tests using a fake `ThreadCounter` | 6.3 | Dart tests pass |
| 6 | `CounterScreen` and `main.dart`, with widget tests | 6.4 | Dart tests pass |
| 7 | Full check: static analysis and every test | 8 | `flutter analyze` clean, all tests pass |
| 8 | Release APK, then the acceptance criteria by hand on the emulator | 8, 10 | AC-1 to AC-7 pass |
| 9 | README for the project and links from the repository README | 10 | Review |

## 2. Progress

| Step | Result | Check |
| --- | --- | --- |
| 1 | Project created with `flutter create --platforms android`. Application ID `com.pedro.task4_spec_driven`, launcher name "Odd/Even Threads". JUnit 4 added as a test dependency in `android/app/build.gradle.kts`. | Builds (see step 8). |
| 2 | [`OddEvenCounter.kt`](../android/app/src/main/kotlin/com/pedro/task4_spec_driven/OddEvenCounter.kt) and [`OddEvenCounterTest.kt`](../android/app/src/test/kotlin/com/pedro/task4_spec_driven/OddEvenCounterTest.kt), with 6 tests. | 6 of 6 pass. The 500 runs of 1 to 100 with no delay took 1.3 s. |
| 3 | [`CounterStreamHandler.kt`](../android/app/src/main/kotlin/com/pedro/task4_spec_driven/CounterStreamHandler.kt) and [`MainActivity.kt`](../android/app/src/main/kotlin/com/pedro/task4_spec_driven/MainActivity.kt). | Compiles as part of the release build (step 8). |
| 4 | [`thread_counter.dart`](../lib/counter/thread_counter.dart), with 3 decoding tests. | Pass. |
| 5 | [`counter_controller.dart`](../lib/counter/counter_controller.dart), with 9 tests using a fake `ThreadCounter`. | Pass. |
| 6 | [`counter_screen.dart`](../lib/ui/counter_screen.dart) and [`main.dart`](../lib/main.dart), with 4 widget tests. | Pass. |
| 7 | `flutter analyze` reported one style suggestion (`prefer_initializing_formals` in the controller's constructor), which was applied. | No issues. 16 of 16 Dart tests and 6 of 6 JUnit tests pass. |
| 8 | Release APK built (43.0 MB) and installed on an Android 15 emulator. | All acceptance criteria pass (section 3). |
| 9 | Project README and links from the repository README. | Reviewed. |

### Checking that the tests can fail

A test that cannot fail proves nothing, so the synchronization tests were also
run against a deliberately broken version: the wait for the turn
(`while (running && next <= limit && !parity.owns(next))`) was removed, so both
threads published whenever they liked. Three tests failed as expected (exact
order, thread per number, and the 500 runs). The code was then restored and all
6 tests passed again.

## 3. Acceptance results

Checked by hand on the release APK, on an Android 15 emulator. The screenshots
are in [`screenshots/`](screenshots/). Thread names were read from the
operating system with `adb shell ps -T -p <app process id>`.

| Criterion | Result | Evidence |
| --- | --- | --- |
| AC-1 | Pass. The label shows `-`, the status is Idle, Start is enabled and Stop is disabled. | [`1-idle.png`](screenshots/1-idle.png) |
| AC-2 | Pass. The label counted 1 to 20 in order, alternating threads. During the run, the app process had two operating-system threads named `odd-thread` and `even-thread`. | [`2-running.png`](screenshots/2-running.png) |
| AC-3 | Pass. The list holds exactly 1 to 20, odd numbers from the odd thread and even numbers from the even thread. After the run, no counting thread was left. | [`3-finished.png`](screenshots/3-finished.png) |
| AC-4 | Pass. Stop at 5: the label kept 5 and the status changed to Stopped. The screen was identical 2 seconds later, and no counting thread was left. | [`4-stopped.png`](screenshots/4-stopped.png) |
| AC-5 | Pass. Start after Stop cleared the list and counted from 1 again. | [`5-restarted.png`](screenshots/5-restarted.png) |
| AC-6 | Pass. The buttons responded at once during runs; the counting runs on its own threads. This was observed, not measured. | |
| AC-7 | Pass. Closing the screen with Back during a run left the app process alive but with no `odd-thread` or `even-thread`. | |

## 4. Deviations from the technical specification

There were no functional deviations. Two files were added that the project
structure in section 7 of the technical specification did not list:

- `test/fake_thread_counter.dart`: the fake `ThreadCounter` described in
  section 8, shared by the controller and screen tests.
- `docs/screenshots/`: the evidence for the acceptance results above.

## 5. How to run the checks

```
flutter analyze
flutter test
cd android
gradlew testDebugUnitTest
```

On Windows, use `gradlew.bat`. The JUnit report is written to
`build/app/reports/tests/testDebugUnitTest/index.html`.
