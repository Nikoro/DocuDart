import 'package:jaspr/jaspr.dart';

import 'flexible.dart';

/// A component that forces its child to fill the available space
/// along the main axis of a [Row] or [Column].
///
/// Equivalent to `Flexible(fit: FlexFit.tight, ...)`.
class Expanded extends StatelessComponent {
  /// The flex factor. Higher values take proportionally more space.
  final int flex;

  /// The child component to expand.
  final Component child;

  const Expanded({this.flex = 1, required this.child, super.key});

  @override
  Component build(BuildContext context) {
    return Flexible(
      flex: flex,
      fit: FlexFit.tight,
      child: child,
    );
  }
}
