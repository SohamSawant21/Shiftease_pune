import 'package:flutter_test/flutter_test.dart';
import 'package:shiftease_pune/main.dart';
import 'package:provider/provider.dart';
import 'package:shiftease_pune/services/request_provider.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RequestProvider()),
        ],
        child: const ShifteaseApp(),
      ),
    );

    // Verify app builds
    expect(find.text('Shiftease Pune'), findsWidgets);
  });
}
