import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'package:docudart/src/extensions/component_extensions.dart';

/// A box with a specified size.
///
/// When given a [child], uses `.apply()` to merge width/height directly onto
/// the child — no wrapper div. Without a child, renders an empty `<div>` for
/// spacer usage.
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
    if (child != null) {
      return child!.apply(
        styles: Styles(width: width, height: height),
      );
    }
    return div(
      styles: Styles(width: width, height: height),
      [],
    );
  }
}
