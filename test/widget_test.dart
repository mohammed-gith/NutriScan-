import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan/firebase_options.dart';
import 'package:nutriscan/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
    } on FirebaseException catch (error) {
      if (error.code != 'duplicate-app') rethrow;
    }
  });

  testWidgets('NutriScan home screen loads', (tester) async {
    await tester.pumpWidget(const NutriScanApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
