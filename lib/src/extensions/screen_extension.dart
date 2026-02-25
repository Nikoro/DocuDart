import 'package:docudart/docudart.dart';

/// Breakpoint thresholds for responsive rendering.
///
/// - Mobile: 0–768px
/// - Tablet: 769–1024px
/// - Desktop: 1025px+
class Screen {
  const Screen();

  /// Renders all three variants; CSS media queries show the matching one.
  ///
  /// ```dart
  /// context.screen.when(
  ///   mobile: () => MobileNav(),
  ///   tablet: () => TabletNav(),
  ///   desktop: () => DesktopNav(),
  /// )
  /// ```
  Component when({
    required Component Function() mobile,
    required Component Function() tablet,
    required Component Function() desktop,
  }) {
    return div(styles: Styles(display: Display.contents), [
      div(classes: 'screen-mobile', [mobile()]),
      div(classes: 'screen-tablet', [tablet()]),
      div(classes: 'screen-desktop', [desktop()]),
    ]);
  }

  /// Renders provided variants with an optional [orElse] fallback for
  /// unspecified breakpoints.
  ///
  /// When [orElse] is provided, unspecified breakpoints use the fallback:
  /// ```dart
  /// context.screen.maybeWhen(
  ///   mobile: () => HamburgerMenu(),
  ///   orElse: () => FullNav(),
  /// )
  /// ```
  ///
  /// When [orElse] is omitted, only the specified breakpoints are rendered
  /// and `null` is returned if none are specified:
  /// ```dart
  /// // Returns Component? — use with null-aware `?` in children lists
  /// ?context.screen.maybeWhen(
  ///   mobile: () => SidebarToggle(),
  ///   tablet: () => SidebarToggle(),
  /// ),
  /// ```
  Component? maybeWhen({
    Component Function()? mobile,
    Component Function()? tablet,
    Component Function()? desktop,
    Component Function()? orElse,
  }) {
    final mobileBuilder = mobile ?? orElse;
    final tabletBuilder = tablet ?? orElse;
    final desktopBuilder = desktop ?? orElse;

    final children = [
      if (mobileBuilder != null)
        div(classes: 'screen-mobile', [mobileBuilder()]),
      if (tabletBuilder != null)
        div(classes: 'screen-tablet', [tabletBuilder()]),
      if (desktopBuilder != null)
        div(classes: 'screen-desktop', [desktopBuilder()]),
    ];

    if (children.isEmpty) return null;
    return div(styles: Styles(display: Display.contents), children);
  }
}

/// Provides responsive screen utilities via [BuildContext].
extension ScreenContext on BuildContext {
  /// Access responsive rendering helpers.
  ///
  /// ```dart
  /// context.screen.when(
  ///   mobile: () => MobileLayout(),
  ///   tablet: () => TabletLayout(),
  ///   desktop: () => DesktopLayout(),
  /// )
  /// ```
  Screen get screen => const .new();
}
