import 'package:jaspr/jaspr.dart';

import 'package:docudart/src/extensions/component_extensions.dart';

/// A tooltip that wraps a child widget.
///
/// Mirrors Flutter's `Tooltip` widget. Uses the HTML `title` attribute
/// for native browser tooltip behavior.
///
/// ```dart
/// Tooltip(
///   message: 'Delete this item',
///   child: IconButton(icon: Icon(Icons.delete)),
/// )
/// ```
class Tooltip extends StatelessComponent {
  const Tooltip({required this.message, required this.child, super.key});

  /// The text to display in the tooltip.
  final String message;

  /// The widget below this widget in the tree.
  final Component child;

  @override
  Component build(BuildContext context) {
    return child.apply(attributes: {'title': message});
  }
}
