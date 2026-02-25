import 'package:jaspr/jaspr.dart';

import '../../theme/theme.dart' as dd;

/// Provides [Theme] data to descendant components via the component tree.
///
/// Wrap your app (or any subtree) with [ThemeProvider] to make [Theme]
/// accessible through [BuildContext]:
///
/// ```dart
/// ThemeProvider(
///   theme: Theme.material3(),
///   child: MyApp(),
/// )
/// ```
///
/// Then access it from any descendant component:
///
/// ```dart
/// @override
/// Component build(BuildContext context) {
///   final cardTheme = context.theme.cardTheme;
///   final sidebarTheme = context.theme.sidebarTheme;
/// }
/// ```
class ThemeProvider extends InheritedComponent {
  const ThemeProvider({required this.theme, required super.child, super.key});

  final dd.Theme theme;

  @override
  bool updateShouldNotify(covariant ThemeProvider oldComponent) {
    return theme != oldComponent.theme;
  }
}

/// Extension on [BuildContext] to conveniently access [Theme] data
/// provided by an ancestor [ThemeProvider].
extension ThemeContext on BuildContext {
  /// Returns the [Theme] from the nearest ancestor [ThemeProvider].
  ///
  /// Falls back to [Theme.classic()] if no [ThemeProvider] is found.
  dd.Theme get theme {
    final provider = dependOnInheritedComponentOfExactType<ThemeProvider>();
    return provider?.theme ?? dd.Theme.classic();
  }
}
