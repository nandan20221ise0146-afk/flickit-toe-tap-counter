
import 'package:flutter_test/flutter_test.dart';
import 'package:toe_tap_counter/main.dart';

void main() {
  testWidgets('Toe Tap Counter app smoke test',
      (WidgetTester tester) async {

    await tester.pumpWidget(const MyApp());

    expect(find.text('Toe Tap Counter'), findsOneWidget);
  });
}
