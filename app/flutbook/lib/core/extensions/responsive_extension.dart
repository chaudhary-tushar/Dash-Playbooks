// lib/core/extensions/responsive_extension.dart
import 'package:flutter/material.dart';

/// Responsive layout breakpoints used across Flutbook screens.
///
/// These are used to adapt layouts between phones, tablets and desktop
/// (web / native windowed) form factors. Breakpoints are intentionally
/// kept in a single place so behaviour stays consistent app-wide.
abstract final class ResponsiveLayout {
  static const double phoneMaxWidth = 599;
  static const double tabletMinWidth = 600;
  static const double desktopMinWidth = 1024;

  /// Maximum width applied to main content on very wide windows so lines of
  /// text and grids do not stretch edge-to-edge on large screens.
  static const double contentMaxWidth = 1200;
}

/// Extension providing responsive helpers from [BuildContext].
extension ResponsiveContext on BuildContext {
  /// True when the current width is a narrow (phone) form factor.
  bool get isPhone =>
      MediaQuery.sizeOf(this).width < ResponsiveLayout.tabletMinWidth;

  /// True when the current width is a tablet or compact desktop form factor.
  bool get isTablet {
    final width = MediaQuery.sizeOf(this).width;
    return width >= ResponsiveLayout.tabletMinWidth &&
        width < ResponsiveLayout.desktopMinWidth;
  }

  /// True when the current width is a desktop / large window form factor.
  bool get isDesktop =>
      MediaQuery.sizeOf(this).width >= ResponsiveLayout.desktopMinWidth;

  /// Returns the number of grid columns appropriate for the current width,
  /// producing a denser layout on larger form factors.
  ///
  /// Defaults ([crossAxisCount]) is used when `gridEnabled` is false so the
  /// caller can fall back to a non-grid (list) layout unchanged.
  int responsiveGridColumns({bool gridEnabled = true, int crossAxisCount = 2}) {
    if (!gridEnabled) return crossAxisCount;
    final width = MediaQuery.sizeOf(this).width;
    if (width >= 1600) return 5;
    if (width >= 1300) return 4;
    if (width >= 1024) return 3;
    if (width >= 720) return 3;
    if (width >= 600) return 2;
    return crossAxisCount;
  }

  /// True when the current window is at least as wide as a phone layout.
  bool get isWideEnough =>
      MediaQuery.sizeOf(this).width >= ResponsiveLayout.tabletMinWidth;
}
