import 'package:flutter/material.dart';

class NavigationService {
  factory NavigationService() => _instance;

  NavigationService._internal();
  static final NavigationService _instance = NavigationService._internal();

  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static BuildContext? get context => _navigatorKey.currentContext;

  static Future<void> navigateToLibrary() async {
    await _waitForNavigatorReady(() async {
      final currentState = _navigatorKey.currentState;
      if (currentState != null) {
        await currentState.pushReplacementNamed('/directory');
      }
    });
  }

  static Future<void> navigateTo(String routeName, {Object? arguments}) async {
    await _waitForNavigatorReady(() async {
      final currentState = _navigatorKey.currentState;
      if (currentState != null) {
        await currentState.pushReplacementNamed(
          routeName,
          arguments: arguments,
        );
      }
    });
  }

  // Helper method to wait for the navigator to be ready
  static Future<void> _waitForNavigatorReady(Future<void> Function() navigationAction) async {
    int attempts = 0;
    const maxAttempts = 10;
    const delay = Duration(milliseconds: 100);

    while (attempts < maxAttempts) {
      // Check if the navigator key is globally mounted before accessing currentState
      if (_navigatorKey.currentContext != null && _navigatorKey.currentState != null) {
        await navigationAction();
        return;
      }

      await Future.delayed(delay);
      attempts++;
    }

    // If navigator is still not ready after max attempts, log an error
    debugPrint('Warning: Navigator was not ready after ${maxAttempts * 100}ms');
  }
  
  // Method to check if navigator is ready
  static bool get isNavigatorReady {
    return _navigatorKey.currentContext != null && _navigatorKey.currentState != null;
  }
}
