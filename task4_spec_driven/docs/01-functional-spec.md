# Functional Specification: Odd/Even Thread Counter

- **Project:** Task 4 (Multithreading), spec-driven version
- **Document:** 1 of 3, functional specification
- **Status:** Approved, v1.0 (approved by Pedro Paula on 14 October 2026)
- **Author:** Pedro Paula, written with Claude Code
- **Date:** 14 October 2026
- **Next document:** `02-technical-spec.md`, written from this specification
  once it is approved

## 1. Purpose

This document defines **what** the app must do, from the user's point of view.
It does not decide how it is built; that is the job of the technical
specification.

## 2. Original requirement

> Multithreading Task: Implement two threads. The first thread should count odd
> numbers, while the second thread counts even numbers. Both threads should take
> turns updating a label to display the numbers in sequence (e.g., 1, 2, 3, 4,
> etc.) in a synchronized manner.

## 3. Scope

**In scope**

- A single-screen Android app built with Flutter.
- Two threads that count concurrently: one counts odd numbers, the other counts
  even numbers.
- One label that both threads update in turn, so it shows 1, 2, 3, 4, ... in
  order.
- Controls to start, stop and restart the count.
- Automated tests and a release APK.

**Out of scope**

- iOS, web and desktop builds.
- Saving data between sessions, settings screens, accounts or network access.
- Localization: the app is in English only.

## 4. Definitions

| Term | Meaning |
| --- | --- |
| **Odd thread** | The thread that produces 1, 3, 5, ... |
| **Even thread** | The thread that produces 2, 4, 6, ... |
| **Label** | The single on-screen text that shows the current number. |
| **Turn** | The right of one thread to publish its next number. Only one thread holds the turn at any time. |
| **Run** | One count from 1 up to the limit, started by the user. |
| **Limit** | The last number of a run. |

## 5. Functional requirements

| ID | Requirement |
| --- | --- |
| FR-1 | The app runs two threads at the same time during a run: the odd thread and the even thread. |
| FR-2 | The odd thread produces only odd numbers, starting at 1 and increasing by 2. The even thread produces only even numbers, starting at 2 and increasing by 2. |
| FR-3 | Both threads update the **same** label. |
| FR-4 | The threads take strict turns: odd, even, odd, even, ... The odd thread always goes first. |
| FR-5 | The label shows every number from 1 to the limit exactly once, in ascending order, with no gaps, repeats or reordering. |
| FR-6 | Each number stays on screen long enough to be read before the next one replaces it. |
| FR-7 | Next to the label, the screen shows which thread published the current number (odd or even). |
| FR-8 | The screen shows the full sequence produced so far, with the thread that produced each number, so the order can be checked at a glance. |
| FR-9 | A **Start** button begins a run. It is disabled while a run is in progress. |
| FR-10 | A **Stop** button ends the run early. Both threads stop promptly, and the label keeps the last number shown. It is disabled when no run is in progress. |
| FR-11 | When the count reaches the limit, both threads finish on their own and the screen shows that the run is complete. |
| FR-12 | After a run finishes or is stopped, pressing **Start** clears the previous result and begins a new run from 1. |
| FR-13 | Closing the screen or the app stops both threads. No thread keeps running in the background. |

## 6. Screen and states

The app has one screen with, from top to bottom:

1. A title bar.
2. The **label**: a large number, with the producing thread shown below it.
3. A status line: Idle, Running, Stopped or Finished.
4. The **Start** and **Stop** buttons.
5. The **sequence list**: one line per number, for example `3 (odd thread)`.

| State | Label | Start | Stop | How the state is entered |
| --- | --- | --- | --- | --- |
| Idle | `-` | Enabled | Disabled | The app opens |
| Running | Current number | Disabled | Enabled | The user presses Start |
| Stopped | Last number shown | Enabled | Disabled | The user presses Stop |
| Finished | The limit | Enabled | Disabled | The count reaches the limit |

## 7. Non-functional requirements

| ID | Requirement |
| --- | --- |
| NFR-1 | The order in FR-5 holds no matter how the operating system schedules the threads. It must not depend on timing or delays. |
| NFR-2 | The interface stays responsive during a run. The counting never blocks the UI. |
| NFR-3 | The synchronization logic is covered by automated tests that check the exact sequence and which thread produced each number. |
| NFR-4 | All text in the app, code and documents is in English. |
| NFR-5 | The app runs on Android phones and emulators, and is delivered as an installable APK. |

## 8. Acceptance criteria

| ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-1 | The app has just opened | The user looks at the screen | The label shows `-`, the status is Idle, Start is enabled and Stop is disabled. |
| AC-2 | The app is idle | The user presses Start | The label shows 1, 2, 3, ... up to the limit, in order, alternating odd and even threads. |
| AC-3 | A run has finished | The user reads the sequence list | It holds exactly the numbers 1 to the limit, odd numbers from the odd thread and even numbers from the even thread. |
| AC-4 | A run is in progress | The user presses Stop | The count stops within one step, the label keeps its last number, and the status is Stopped. |
| AC-5 | A run is finished or stopped | The user presses Start | The list is cleared and a new run starts from 1. |
| AC-6 | A run is in progress | The user scrolls the list or presses buttons | The app responds without freezing. |
| AC-7 | A run is in progress | The user closes the app | Both threads end. |

## 9. Decisions

These were open questions in the draft. They were resolved when the document
was approved.

| # | Question | Decision |
| --- | --- | --- |
| Q-1 | What does "thread" mean in a Flutter app? | Real operating-system threads. The technical specification explains how. |
| Q-2 | What is the limit? | 20. |
| Q-3 | How long does each number stay on screen? | About half a second, so the alternation is easy to follow. |
| Q-4 | Should the user be able to change the limit or the speed? | No. Fixed values keep the app simple. |

## Revision history

| Version | Date | Change |
| --- | --- | --- |
| 0.1 | 14 October 2026 | First draft. |
| 1.0 | 14 October 2026 | Approved. Open questions resolved (section 9). |
