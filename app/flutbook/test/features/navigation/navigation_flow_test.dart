import 'package:flutbook/features/auth/presentation/widgets/login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Navigation Flow Tests', () {
    testWidgets('Login buttons should be present', (WidgetTester tester) async {
      // Build the login buttons widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginButtons(),
          ),
        ),
      );

      // Verify all expected login buttons are present
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Skip for Development'), findsOneWidget);
    });

    testWidgets('Navigation flow structure test', (WidgetTester tester) async {
      // Test that the basic navigation structure is correct
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginButtons(),
          ),
        ),
      );

      // Verify login screen elements
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });
  });
}
