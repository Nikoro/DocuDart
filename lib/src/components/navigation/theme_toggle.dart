import 'package:docudart/docudart.dart';

/// A theme toggle button that switches between light and dark mode.
///
/// Renders both [light] and [dark] icon components in the DOM.
/// CSS visibility rules based on `[data-theme]` on `<html>` show the
/// appropriate icon. Clicking toggles the theme via the existing
/// `theme.js` click handler on `.theme-toggle`.
class ThemeToggle extends StatelessComponent {
  const ThemeToggle({required this.light, required this.dark, super.key});

  /// Icon shown when the current theme is light (to indicate "switch to dark").
  final Component light;

  /// Icon shown when the current theme is dark (to indicate "switch to light").
  final Component dark;

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'theme-toggle',
      attributes: {'aria-label': 'Toggle theme', 'title': 'Toggle theme'},
      [
        span(classes: 'theme-toggle-light', [light]),
        span(classes: 'theme-toggle-dark', [dark]),
      ],
    );
  }
}
