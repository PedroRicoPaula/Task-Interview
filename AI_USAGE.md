# AI Usage

I built these apps with **Claude Code**, Anthropic's AI coding agent. This
document explains how I used it, what it produced, and what I checked myself.

## Summary

- **Tool:** Claude Code was the only AI tool I used. I ran it first in the
  Claude desktop app (model Claude Opus 5) and later in the VS Code extension
  (model Claude Opus 5.5).
- **What the AI did:** it set up the development environment (except one
  manual step, see [Task 1](#task-1-environment)), wrote all of the code, tests
  and documentation, built the APKs and captured the screenshots.
- **What I did:** I directed the work through the prompts below, tested the
  apps on the emulator and reviewed the code. I did not write or edit code by
  hand.

## Why there are no prompt files

I did not prepare specification or prompt files before starting. I worked with
Claude Code as a conversation, so my instructions were chat messages. The
prompts that produced the apps are listed below, taken from the session logs.
I wrote them in Portuguese, so they are translated into English here.

## Timeline

| Date | Where | Work |
| ---- | ----- | ---- |
| 8 Oct 2026 | Claude desktop app | Environment set-up, first version (a single app), tests, screenshots, English review |
| 8 Oct 2026 | VS Code | Git repository and push to GitHub |
| 14 Oct 2026 | VS Code | Split into three apps, release APKs, this document |

## Prompts

### Session 1: building the apps (8 October 2026)

1. > I had an interview and received a test to do. Tell me whether you can do
   > everything on your own or whether I need to do something manually.

   In the same message I pasted the email with the four tasks.

2. > Go ahead with everything you can do on your own, in the order of the
   > requested steps. At the end I want to be able to see the result, even if
   > you have to explain step by step how to test it and see how it works.

3. > I tested it manually on the emulator and I think everything is fine. I
   > just need you to put everything in a folder on the Desktop so I can open
   > it in Cursor and check all the code and its organization. Then tell me how
   > I can send the result, since the email said nothing about how to deliver
   > it.

4. > Don't move on to anything else. I want you to check that the content is in
   > English, because Alon will review the code, and that it is well written,
   > with well-organized folders and files. Do a review and keep it simple,
   > functional and error-free.

### Session 2: repository and follow-ups (8 to 14 October 2026)

Here I used Claude Code for the repository and the follow-up work. These
requests are summarized rather than quoted:

- Create the Git repository and push it to GitHub.
- Fix the table formatting in the README.
- After the review feedback: split the project into three apps, add the APKs
  to the repository and write this document.

## What Claude Code did

### Task 1: environment

Claude Code set up the toolchain from the command line:

- installed JDK 17 (Microsoft OpenJDK) and Android Studio with `winget`;
- cloned the Flutter SDK (stable channel);
- installed Android SDK platform 36, build-tools 36.0.0, the emulator and an
  Android 15 system image with `sdkmanager`, and created an emulator with
  `avdmanager`;
- ran `flutter doctor` until the Android toolchain was ready.

Installing the Flutter and Dart plugins inside Android Studio needs the IDE's
graphical interface, so Claude Code left that step to me.

### Tasks 2 to 4: the apps

- It wrote the screens and the tests. The first version was a single app with
  one screen per task. After the review feedback it split that app into the
  three apps in this repository, without changing how the screens behave.
- For Task 4 it chose two Dart isolates that pass a single turn token, because
  Dart has no threads that share memory. The design is explained in the
  [Task 4 README](task4_multithreading/README.md#how-the-synchronization-works).
- It wrote the READMEs, built the release APKs, installed them on the emulator
  through `adb` and captured the screenshots.

Problems it hit and fixed along the way:

- `flutter doctor` asked for Android SDK 36, so it installed it.
- Flutter Web cannot compile `dart:isolate`, so it removed the web target. The
  apps are Android-only.
- The first release build failed because of the 260-character path limit on
  Windows, so it rebuilt the APK from a shorter folder.
- Parts of the first version (UI text, code comments and a testing guide) were
  in Portuguese. At my request it translated everything into English.

## What I did

- I directed the work through the prompts above and made the calls on scope
  and delivery: English throughout, a simple structure, and three separate
  apps after the review feedback.
- I tested each task manually on the emulator. I tested the first version (one
  app with a screen per task); the split into three apps did not change how the
  screens behave.
- I reviewed the code and the project structure, and I can explain how it
  works, including the Task 4 synchronization.
- I did not write or edit code by hand.

## How the result was checked

- `flutter analyze` reports no issues in any of the three apps.
- `flutter test` passes in all three apps (six tests in total).
- Each release APK was installed on an Android 15 emulator and run before it
  was committed. The screenshots in the README come from those runs.

---

This document was also written with Claude Code, from the session logs and my
answers about what I did myself.
