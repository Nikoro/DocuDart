import 'package:docudart/docudart.dart';

/// A button that displays an icon with optional click handling.
///
/// Mirrors Flutter's `IconButton` API. Renders a `<button>` element
/// with the given [icon] child and optional [tooltip] for accessibility.
///
/// ```dart
/// IconButton(
///   icon: Icon(MaterialIcons.menu),
///   tooltip: 'Open menu',
/// )
/// ```
class IconButton extends StatelessComponent {
  const IconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
    super.key,
  });

  /// The icon widget to display inside the button.
  final Component icon;

  /// Optional click callback.
  final VoidCallback? onPressed;

  /// Tooltip text — maps to HTML `title` and `aria-label` attributes.
  final String? tooltip;

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'icon-button',
      onClick: onPressed,
      attributes: {'aria-label': ?tooltip, 'title': ?tooltip},
      [icon],
    );
  }
}
