import 'package:docudart/docudart.dart';

/// How children are placed along the main axis of a [Row] or [Column].
///
/// Maps to CSS `justify-content`.
enum MainAxisAlignment {
  /// Place children at the start of the main axis.
  start(JustifyContent.start),

  /// Place children at the end of the main axis.
  end(JustifyContent.end),

  /// Place children at the center of the main axis.
  center(JustifyContent.center),

  /// Evenly space children; first and last are flush with edges.
  spaceBetween(JustifyContent.spaceBetween),

  /// Evenly space children with half-size space at edges.
  spaceAround(JustifyContent.spaceAround),

  /// Evenly space children with equal space everywhere.
  spaceEvenly(JustifyContent.spaceEvenly);

  const MainAxisAlignment(this.justifyContent);
  final JustifyContent justifyContent;
}

/// How children are placed along the cross axis of a [Row] or [Column].
///
/// Maps to CSS `align-items`.
enum CrossAxisAlignment {
  /// Place children at the start of the cross axis.
  start(AlignItems.start),

  /// Place children at the end of the cross axis.
  end(AlignItems.end),

  /// Place children at the center of the cross axis.
  center(AlignItems.center),

  /// Force children to fill the cross axis.
  stretch(AlignItems.stretch),

  /// Align children along their text baseline.
  baseline(AlignItems.baseline);

  const CrossAxisAlignment(this.alignItems);
  final AlignItems alignItems;
}

/// How much space the flex container should occupy along the main axis.
enum MainAxisSize {
  /// The container occupies all available space along the main axis.
  max,

  /// The container only takes as much space as its children need.
  min,
}
