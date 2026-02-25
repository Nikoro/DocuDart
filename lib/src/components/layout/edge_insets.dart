import 'package:jaspr/dom.dart' show Spacing, Unit;
import 'package:meta/meta.dart';

/// Flutter-like edge insets for padding and margin.
///
/// Mirrors Flutter's `EdgeInsets` API. Values are in logical pixels (px).
///
/// ```dart
/// EdgeInsets.all(16)
/// EdgeInsets.symmetric(horizontal: 24, vertical: 12)
/// EdgeInsets.only(left: 8, top: 16)
/// EdgeInsets.fromLTRB(8, 16, 8, 16)
/// ```
@immutable
class EdgeInsets {
  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom);

  const EdgeInsets.all(double value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  const EdgeInsets.symmetric({double horizontal = 0, double vertical = 0})
    : left = horizontal,
      right = horizontal,
      top = vertical,
      bottom = vertical;

  const EdgeInsets.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  static const EdgeInsets zero = EdgeInsets.all(0);

  final double left;
  final double top;
  final double right;
  final double bottom;

  /// Convert to Jaspr's [Spacing] type for use in `Styles(padding: ...)`.
  Spacing toSpacing() {
    if (left == top && top == right && right == bottom) {
      if (left == 0) return .zero;
      return Spacing.all(Unit.pixels(left));
    }
    if (left == right && top == bottom) {
      return Spacing.symmetric(
        horizontal: Unit.pixels(left),
        vertical: Unit.pixels(top),
      );
    }
    return Spacing.fromLTRB(
      Unit.pixels(left),
      Unit.pixels(top),
      Unit.pixels(right),
      Unit.pixels(bottom),
    );
  }

  EdgeInsets copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => .fromLTRB(
    left ?? this.left,
    top ?? this.top,
    right ?? this.right,
    bottom ?? this.bottom,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EdgeInsets &&
          left == other.left &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);
}
