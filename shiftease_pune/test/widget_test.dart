import 'package:flutter_test/flutter_test.dart';
import 'package:shiftease_pune/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ShifteaseApp());

    // Basic sanity check
    expect(find.text('Shiftease Pune'), findsWidgets);
  });
}