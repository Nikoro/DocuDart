import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../extensions/component_extensions.dart';
import 'edge_insets.dart';

/// A widget that insets its child by the given padding.
///
/// Mirrors Flutter's `Padding` widget API. Uses `.apply()` to merge CSS
/// padding directly onto the child's root element — no wrapper div.
///
/// **Note**: Do not chain `.apply()` on a `Padding` instance. Jaspr's
/// `.apply()` uses inherited elements that shadow each other. Instead,
/// combine styles in a single `.apply()` call on the child.
///
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(16),
///   child: Text('Hello'),
/// )
/// ```
class Padding extends StatelessComponent {
  const Padding({required this.padding, required this.child, super.key});

  /// The amount of space by which to inset the child.
  final EdgeInsets padding;

  /// The widget below this widget in the tree.
  final Component child;

  @override
  Component build(BuildContext context) {
    return child.apply(styles: Styles(padding: padding.toSpacing()));
  }
}
