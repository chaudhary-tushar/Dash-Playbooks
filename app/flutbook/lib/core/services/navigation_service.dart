import 'package:flutter/material.dart';

class NavigationService {
  factory NavigationService() => _instance;

  NavigationService._internal();
  static final NavigationService _instance = NavigationService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<void> navigateToLibrary() async {
    if (context != null) {
      await navigatorKey.currentState?.pushReplacementNamed('/directory');
    }
  }

  static Future<void> navigateTo(String routeName, {Object? arguments}) async {
    if (context != null) {
      await navigatorKey.currentState?.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    }
  }
}
