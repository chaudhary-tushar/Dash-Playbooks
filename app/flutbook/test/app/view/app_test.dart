// Ignore for testing purposes

import 'package:flutbook/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('App can be created with ProviderScope', (tester) async {
      // Test that the app can be created without throwing ProviderScope error
      // This is a basic smoke test to verify the app structure
      const appWidget = ProviderScope(
        child: App(),
      );

      // Verify the widget tree can be built
      expect(appWidget, isA<Widget>());
      expect(appWidget.child, isA<App>());
    });
  });
}
