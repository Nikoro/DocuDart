import 'package:meta/meta.dart';

/// Describes the decoration of a [Container].
///
/// Mirrors Flutter's `BoxDecoration`. Converted to CSS inline styles.
///
/// ```dart
/// BoxDecoration(
///   color: 0xFFF5F5F5,
///   borderRadius: BorderRadius.circular(8),
///   border: Border.all(color: 0xFFE0E0E0),
///   boxShadow: [BoxShadow(blurRadius: 4, color: 0x1A000000)],
/// )
/// ```
@immutable
class BoxDecoration {
  const BoxDecoration({
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  /// Background color (ARGB int).
  final int? color;

  /// Border radius.
  final BorderRadius? borderRadius;

  /// Border.
  final Border? border;

  /// Box shadows.
  final List<BoxShadow>? boxShadow;

  /// Convert to CSS property map.
  Map<String, String> toCssProperties() {
    return {
      if (color != null) 'background-color': _hexColor(color!),
      if (borderRadius != null) 'border-radius': borderRadius!.toCss(),
      if (border != null) 'border': border!.toCss(),
      if (boxShadow != null && boxShadow!.isNotEmpty)
        'box-shadow': boxShadow!.map((s) => s.toCss()).join(', '),
    };
  }
}

/// Border radius for each corner of a rectangle.
///
/// Mirrors Flutter's `BorderRadius`.
@immutable
class BorderRadius {
  const BorderRadius.only({
    this.topLeft = 0,
    this.topRight = 0,
    this.bottomLeft = 0,
    this.bottomRight = 0,
  });

  const BorderRadius.all(double radius)
    : topLeft = radius,
      topRight = radius,
      bottomLeft = radius,
      bottomRight = radius;

  const BorderRadius.circular(double radius)
    : topLeft = radius,
      topRight = radius,
      bottomLeft = radius,
      bottomRight = radius;

  static const BorderRadius zero = BorderRadius.all(0);

  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  String toCss() {
    if (topLeft == topRight &&
        topRight == bottomRight &&
        bottomRight == bottomLeft) {
      return '${topLeft}px';
    }
    return '${topLeft}px ${topRight}px ${bottomRight}px ${bottomLeft}px';
  }
}

/// A border consisting of four sides.
///
/// Mirrors Flutter's `Border`.
@immutable
class Border {
  const Border({this.top, this.right, this.bottom, this.left});

  Border.all({int color = 0xFF000000, double width = 1.0})
    : top = BorderSide(color: color, width: width),
      right = BorderSide(color: color, width: width),
      bottom = BorderSide(color: color, width: width),
      left = BorderSide(color: color, width: width);

  final BorderSide? top;
  final BorderSide? right;
  final BorderSide? bottom;
  final BorderSide? left;

  String toCss() {
    // If all sides are the same, use shorthand.
    if (top != null && top == right && right == bottom && bottom == left) {
      return top!.toCss();
    }
    // Otherwise return top side (most common use case for shorthand).
    return top?.toCss() ?? 'none';
  }
}

/// A single side of a border.
///
/// Mirrors Flutter's `BorderSide`.
@immutable
class BorderSide {
  const BorderSide({this.color = 0xFF000000, this.width = 1.0});

  static const BorderSide none = BorderSide(width: 0);

  /// Color (ARGB int).
  final int color;

  /// Width in pixels.
  final double width;

  String toCss() => '${width}px solid ${_hexColor(color)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorderSide && color == other.color && width == other.width;

  @override
  int get hashCode => Object.hash(color, width);
}

/// A shadow cast by a box.
///
/// Mirrors Flutter's `BoxShadow`.
@immutable
class BoxShadow {
  const BoxShadow({
    this.color = 0x66000000,
    this.blurRadius = 0,
    this.spreadRadius = 0,
    this.offsetX = 0,
    this.offsetY = 0,
  });

  /// Shadow color (ARGB int).
  final int color;

  /// Blur radius in pixels.
  final double blurRadius;

  /// Spread radius in pixels.
  final double spreadRadius;

  /// Horizontal offset in pixels.
  final double offsetX;

  /// Vertical offset in pixels.
  final double offsetY;

  String toCss() {
    final c = _rgbaColor(color);
    return '${offsetX}px ${offsetY}px ${blurRadius}px ${spreadRadius}px $c';
  }
}

/// Alignment of a child within its parent.
///
/// Mirrors Flutter's `Alignment` with static constants.
@immutable
class Alignment {
  const Alignment(this.x, this.y);

  /// Horizontal alignment (-1 = left, 0 = center, 1 = right).
  final double x;

  /// Vertical alignment (-1 = top, 0 = center, 1 = bottom).
  final double y;

  static const Alignment topLeft = Alignment(-1, -1);
  static const Alignment topCenter = Alignment(0, -1);
  static const Alignment topRight = Alignment(1, -1);
  static const Alignment centerLeft = Alignment(-1, 0);
  static const Alignment center = Alignment(0, 0);
  static const Alignment centerRight = Alignment(1, 0);
  static const Alignment bottomLeft = Alignment(-1, 1);
  static const Alignment bottomCenter = Alignment(0, 1);
  static const Alignment bottomRight = Alignment(1, 1);

  /// Convert to CSS justify-content value.
  String get justifyContent => switch (x) {
    < 0 => 'flex-start',
    0 => 'center',
    _ => 'flex-end',
  };

  /// Convert to CSS align-items value.
  String get alignItems => switch (y) {
    < 0 => 'flex-start',
    0 => 'center',
    _ => 'flex-end',
  };
}

/// Immutable layout constraints for a box.
///
/// Mirrors Flutter's `BoxConstraints`.
@immutable
class BoxConstraints {
  const BoxConstraints({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  const BoxConstraints.tightFor({double? width, double? height})
    : minWidth = width,
      maxWidth = width,
      minHeight = height,
      maxHeight = height;

  /// Minimum width in pixels.
  final double? minWidth;

  /// Maximum width in pixels.
  final double? maxWidth;

  /// Minimum height in pixels.
  final double? minHeight;

  /// Maximum height in pixels.
  final double? maxHeight;

  /// Convert to CSS property map.
  Map<String, String> toCssProperties() {
    return {
      if (minWidth != null) 'min-width': '${minWidth}px',
      if (maxWidth != null) 'max-width': '${maxWidth}px',
      if (minHeight != null) 'min-height': '${minHeight}px',
      if (maxHeight != null) 'max-height': '${maxHeight}px',
    };
  }
}

/// Convert ARGB int to hex color string.
String _hexColor(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Convert ARGB int to rgba() color string.
String _rgbaColor(int argb) {
  final a = ((argb >> 24) & 0xFF) / 255;
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  return 'rgba($r, $g, $b, ${a.toStringAsFixed(2)})';
}
