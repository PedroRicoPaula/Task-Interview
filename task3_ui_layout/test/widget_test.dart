import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task3_ui_layout/main.dart';

void main() {
  testWidgets('the button copies the EditText into the label',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UiLayoutApp());

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

  testWidgets('an empty text field shows a hint', (WidgetTester tester) async {
    await tester.pumpWidget(const UiLayoutApp());

    await tester.tap(find.byKey(const Key('button')));
    await tester.pump();

    expect(find.text('The text field is empty'), findsOneWidget);
  });
}
