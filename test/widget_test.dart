import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan/main.dart';

void main() {
  testWidgets('NutriScan home screen loads', (tester) async {
    await tester.pumpWidget(const NutriScanApp());

    expect(find.text('Choose better food today'), findsOneWidget);
    expect(find.text('Scan Food'), findsOneWidget);
  });
}
