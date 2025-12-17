import 'package:flutbook/features/auth/presentation/widgets/login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Google login button UI test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LoginButtons(),
          ),
        ),
      ),
    );

    // Verify the Google login button is present
    expect(find.text('Continue with Google'), findsOneWidget);

    // Verify all expected buttons are present
    expect(find.text('Continue with Facebook'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Skip for Development'), findsOneWidget);

    // Verify the Google button has the correct icon
    final googleButton = tester.widget<InkWell>(
      find.byWidgetPredicate(
        (widget) =>
            widget is InkWell &&
            widget.child is Container &&
            (widget.child! as Container).child is Row &&
            ((widget.child! as Container).child! as Row).children.any(
              (child) =>
                  child is Image &&
                  child.image.toString().contains('google.png'),
            ),
      ),
    );

    expect(googleButton, isNotNull);
    expect(googleButton.onTap, isNotNull);
  });

  testWidgets('Google login button is tappable', (WidgetTester tester) async {
    const buttonTapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => const LoginButtons(),
            ),
          ),
        ),
      ),
    );

    // Find the Google login button by its text
    final googleButtonFinder = find.text('Continue with Google');
    expect(googleButtonFinder, findsOneWidget);

    // The button should be tappable (not null onTap)
    final inkWellFinder = find.ancestor(
      of: googleButtonFinder,
      matching: find.byType(InkWell),
    );

    expect(inkWellFinder, findsOneWidget);

    final inkWell = tester.widget<InkWell>(inkWellFinder);
    expect(inkWell.onTap, isNotNull);
  });
}
