import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_tasks/screens/task2_hello_world.dart';
import 'package:interview_tasks/screens/task3_label_edittext_button.dart';

void main() {
  testWidgets('Task 2: displays Hello World', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Task2HelloWorldScreen()));

    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('Task 3: the button copies the EditText into the label',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Task3LabelEditTextButtonScreen()),
    );

    expect(find.text('The text will appear here'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('editText')), 'Hello Alon!');
    await tester.tap(find.byKey(const Key('button')));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('label')),
        matching: find.text('Hello Alon!'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Task 3: an empty text field shows a hint',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Task3LabelEditTextButtonScreen()),
    );

    await tester.tap(find.byKey(const Key('button')));
    await tester.pump();

    expect(find.text('The text field is empty'), findsOneWidget);
  });
}
