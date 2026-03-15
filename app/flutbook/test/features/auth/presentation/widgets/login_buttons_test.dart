import 'package:flutbook/features/auth/presentation/widgets/login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginButtons Widget Tests', () {
    testWidgets('All expected login buttons should be present', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoginButtons(),
            ),
          ),
        ),
      );

      // Verify all expected buttons are present
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Skip for Development'), findsOneWidget);
    });

    testWidgets('Anonymous login button should be present', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoginButtons(),
            ),
          ),
        ),
      );

      // Find the anonymous login button
      final anonymousButton = find.text('Continue as Guest');
      expect(anonymousButton, findsOneWidget);
    });

    testWidgets('Development skip button should be present', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoginButtons(),
            ),
          ),
        ),
      );

      // Find the development skip button
      final devButton = find.text('Skip for Development');
      expect(devButton, findsOneWidget);
    });
  });
}
