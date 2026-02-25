import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'edge_insets.dart';

/// A widget that insets its child by the given padding.
///
/// Mirrors Flutter's `Padding` widget API. Renders a `<div>` with CSS padding.
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
    return div(styles: Styles(padding: padding.toSpacing()), [child]);
  }
}
