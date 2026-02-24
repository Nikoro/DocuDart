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
    this.padding,
    super.key,
  });

  /// The icon widget to display inside the button.
  final Component icon;

  /// Optional click callback.
  final VoidCallback? onPressed;

  /// Tooltip text — maps to HTML `title` and `aria-label` attributes.
  final String? tooltip;

  /// Custom padding. Defaults to the CSS-defined `0.5rem` when null.
  final Padding? padding;

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'icon-button',
      styles: padding != null ? Styles(padding: padding) : null,
      onClick: onPressed,
      attributes: {'aria-label': ?tooltip, 'title': ?tooltip},
      [icon],
    );
  }
}
