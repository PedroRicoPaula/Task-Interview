import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task4_spec_driven/main.dart';

import 'fake_thread_counter.dart';

void main() {
  late FakeThreadCounter counter;

  setUp(() => counter = FakeThreadCounter());

  bool isEnabled(WidgetTester tester, String key) =>
      tester.widget<ButtonStyleButton>(find.byKey(Key(key))).onPressed != null;

  Finder inLabel(String text) => find.descendant(
        of: find.byKey(const Key('label')),
        matching: find.text(text),
      );

  testWidgets('AC-1: opens idle, with Start enabled and Stop disabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(OddEvenThreadsApp(counter: counter));

    expect(inLabel('-'), findsOneWidget);
    expect(find.text('Status: Idle'), findsOneWidget);
    expect(isEnabled(tester, 'startButton'), isTrue);
    expect(isEnabled(tester, 'stopButton'), isFalse);
  });

  testWidgets('shows each number, its thread and the sequence while running',
      (WidgetTester tester) async {
    await tester.pumpWidget(OddEvenThreadsApp(counter: counter));
    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pump();

    expect(find.text('Status: Running'), findsOneWidget);
    expect(isEnabled(tester, 'startButton'), isFalse);
    expect(isEnabled(tester, 'stopButton'), isTrue);

    counter.sendNumber(1);
    counter.sendNumber(2);
    await tester.pump();

    expect(inLabel('2'), findsOneWidget);
    expect(inLabel('even thread'), findsOneWidget);
    expect(find.text(' 1  (odd thread)'), findsOneWidget);
    expect(find.text(' 2  (even thread)'), findsOneWidget);
  });

  testWidgets('shows Finished at the end and allows a new run',
      (WidgetTester tester) async {
    await tester.pumpWidget(OddEvenThreadsApp(counter: counter));
    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pump();
    counter.sendNumber(1);
    counter.sendFinished();
    await tester.pump();

    expect(find.text('Status: Finished'), findsOneWidget);
    expect(inLabel('1'), findsOneWidget);
    expect(isEnabled(tester, 'startButton'), isTrue);
    expect(isEnabled(tester, 'stopButton'), isFalse);
  });

  testWidgets('Stop ends the run and keeps the last number',
      (WidgetTester tester) async {
    await tester.pumpWidget(OddEvenThreadsApp(counter: counter));
    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pump();
    counter.sendNumber(1);
    await tester.pump();

    await tester.tap(find.byKey(const Key('stopButton')));
    await tester.pump();

    expect(find.text('Status: Stopped'), findsOneWidget);
    expect(inLabel('1'), findsOneWidget);
    expect(counter.isListening, isFalse);
  });
}
