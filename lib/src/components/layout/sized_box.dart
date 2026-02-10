import 'package:docudart/docudart.dart';

/// A box with a specified size.
///
/// If given a [child], forces it to have a specific [width] and/or [height].
/// If not given a child, creates an empty box of the specified size —
/// useful as a fixed spacer in [Row] or [Column].
///
/// ```dart
/// Column(children: [
///   h1([text('Title')]),
///   SizedBox(height: 2.rem),
///   p([text('Description')]),
/// ])
/// ```
class SizedBox extends StatelessComponent {
  const SizedBox({this.width, this.height, this.child, super.key});

  /// Creates a box that will become as small as possible.
  const SizedBox.shrink({this.child, super.key})
    : width = Unit.zero,
      height = Unit.zero;

  /// Creates a box that will become as large as its parent allows.
  const SizedBox.expand({this.child, super.key})
    : width = const Unit.percent(100),
      height = const Unit.percent(100);

  final Unit? width;
  final Unit? height;
  final Component? child;

  @override
  Component build(BuildContext context) {
    return div(styles: Styles(width: width, height: height), [?child]);
  }
}
