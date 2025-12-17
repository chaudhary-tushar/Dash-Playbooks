import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutbook/features/auth/presentation/widgets/login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  testWidgets('LoginButtons Google sign-in calls auth provider', (
    WidgetTester tester,
  ) async {
    final mockAuthNotifier = MockAuthNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.notifier.overrideWith((ref) => mockAuthNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LoginButtons(),
          ),
        ),
      ),
    );

    // Verify the Google login button is present
    expect(find.text('Continue with Google'), findsOneWidget);

    // Tap the Google login button
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    // Verify that signInWithGoogle was called on the mock notifier
    verify(mockAuthNotifier.signInWithGoogle()).called(1);
  });

  testWidgets('LoginButtons shows all expected buttons', (
    WidgetTester tester,
  ) async {
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
    expect(find.text('Skip for Development'), findsOneWidget);
  });
}
