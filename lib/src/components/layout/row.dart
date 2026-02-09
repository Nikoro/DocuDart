import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import 'flex_enums.dart';

/// A component that displays its children in a horizontal array.
///
/// Maps to a CSS flexbox container with `flex-direction: row`.
///
/// ```dart
/// Row(
///   mainAxisAlignment: MainAxisAlignment.spaceBetween,
///   crossAxisAlignment: CrossAxisAlignment.center,
///   spacing: 8.px,
///   children: [
///     .text('Left'),
///     .text('Right'),
///   ],
/// )
/// ```
class Row extends StatelessComponent {
  const Row({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
    super.key,
  });

  /// The children to lay out horizontally.
  final List<Component> children;

  /// How children are aligned along the horizontal (main) axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How children are aligned along the vertical (cross) axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much horizontal space the row should occupy.
  ///
  /// [MainAxisSize.max] fills all available width.
  /// [MainAxisSize.min] shrinks to fit content.
  final MainAxisSize mainAxisSize;

  /// The gap between children. Maps to CSS `gap`.
  final Unit? spacing;

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: Display.flex,
        flexDirection: FlexDirection.row,
        justifyContent: mainAxisAlignment.justifyContent,
        alignItems: crossAxisAlignment.alignItems,
        width: mainAxisSize == MainAxisSize.max ? 100.percent : null,
        gap: spacing != null ? Gap.column(spacing!) : null,
      ),
      children,
    );
  }
}

/// A component that displays its children in a vertical array.
///
/// Maps to a CSS flexbox container with `flex-direction: column`.
///
/// ```dart
/// Column(
///   mainAxisAlignment: MainAxisAlignment.center,
///   crossAxisAlignment: CrossAxisAlignment.stretch,
///   spacing: 16.px,
///   children: [
///     .text('Top'),
///     .text('Bottom'),
///   ],
/// )
/// ```
class Column extends StatelessComponent {
  const Column({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
    super.key,
  });

  /// The children to lay out vertically.
  final List<Component> children;

  /// How children are aligned along the vertical (main) axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How children are aligned along the horizontal (cross) axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much vertical space the column should occupy.
  ///
  /// [MainAxisSize.max] fills all available height.
  /// [MainAxisSize.min] shrinks to fit content.
  final MainAxisSize mainAxisSize;

  /// The gap between children. Maps to CSS `gap`.
  final Unit? spacing;

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: Display.flex,
        flexDirection: FlexDirection.column,
        justifyContent: mainAxisAlignment.justifyContent,
        alignItems: crossAxisAlignment.alignItems,
        height: mainAxisSize == MainAxisSize.max ? 100.percent : null,
        gap: spacing != null ? Gap.row(spacing!) : null,
      ),
      children,
    );
  }
}
