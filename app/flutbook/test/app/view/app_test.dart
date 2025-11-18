// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutbook/app/app.dart';
import 'package:flutbook/login/login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
