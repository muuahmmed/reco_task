// widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reco_test/main.dart';
import 'package:reco_test/screens/splash/splash_screen.dart';
import 'package:reco_test/services/firebase/firebase_service.dart';
import 'package:reco_test/services/firebase/firestore_service.dart';

void main() {
  testWidgets('App builds and shows a MaterialApp', (WidgetTester tester) async {
    // Create real instances of your services
    final databaseService = FirestoreService();
    final firebaseAuthService = FirebaseAuthService();

    // Pump MyApp with its required dependencies
    await tester.pumpWidget(
      MyApp(
        databaseService: databaseService,
        firebaseAuthService: firebaseAuthService,
      ),
    );

    // Let any async init complete
    await tester.pumpAndSettle();

    // Verify that a MaterialApp (and thus your Logo/Splash) is present
    expect(find.byType(MaterialApp), findsOneWidget);
    // Optionally verify your first screen’s key/text:
    expect(find.byType(LogoScreen), findsOneWidget);
  });
}
