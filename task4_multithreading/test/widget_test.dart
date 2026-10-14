import 'package:flutter_test/flutter_test.dart';
import 'package:task4_multithreading/main.dart';

void main() {
  testWidgets('starts idle and shows the count button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MultithreadingApp());

    expect(find.text('-'), findsOneWidget);
    expect(find.text('idle'), findsOneWidget);
    expect(find.text('Count to 20'), findsOneWidget);
  });
}
