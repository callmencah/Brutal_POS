import 'package:flutter_test/flutter_test.dart';
import 'package:brutalist_pos/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrutalPosApp());
    expect(find.text('BRUTAL POS'), findsOneWidget);
  });
}
