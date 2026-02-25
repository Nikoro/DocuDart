import 'package:meta/meta.dart';

/// A text style definition that compiles to CSS properties.
///
/// All fields are optional — null values are omitted from CSS output,
/// allowing inheritance from parent selectors or CSS variables.
@immutable
class TextStyle {
  const TextStyle({
    this.fontSize,
    this.fontWeight,
    this.lineHeight,
    this.letterSpacing,
    this.fontFamily,
    this.color,
  });

  factory TextStyle.fromJson(Map<String, dynamic> json) => .new(
    fontSize: (json['fontSize'] as num?)?.toDouble(),
    fontWeight: json['fontWeight'] as int?,
    lineHeight: (json['lineHeight'] as num?)?.toDouble(),
    letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
    fontFamily: json['fontFamily'] as String?,
    color: json['color'] as int?,
  );

  /// Font size in rem units (e.g. 2.5 = 2.5rem).
  final double? fontSize;

  /// Font weight (100–900). Common: 400=normal, 500=medium, 600=semi, 700=bold.
  final int? fontWeight;

  /// Line height as a unitless multiplier.
  final double? lineHeight;

  /// Letter spacing in em units (e.g. -0.02 = -0.02em).
  final double? letterSpacing;

  /// Font family override. If null, inherits from parent.
  final String? fontFamily;

  /// Color as int (0xAARRGGBB). If null, inherits from CSS variable.
  final int? color;

  /// Generate CSS declarations for this style.
  Map<String, String> toCssProperties() => {
    if (fontSize != null) 'font-size': '${fontSize}rem',
    if (fontWeight != null) 'font-weight': '$fontWeight',
    if (lineHeight != null) 'line-height': '$lineHeight',
    if (letterSpacing != null) 'letter-spacing': '${letterSpacing}em',
    'font-family': ?fontFamily,
    if (color != null)
      'color': '#${(color! & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
  };

  TextStyle copyWith({
    double? fontSize,
    int? fontWeight,
    double? lineHeight,
    double? letterSpacing,
    String? fontFamily,
    int? color,
  }) => .new(
    fontSize: fontSize ?? this.fontSize,
    fontWeight: fontWeight ?? this.fontWeight,
    lineHeight: lineHeight ?? this.lineHeight,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    fontFamily: fontFamily ?? this.fontFamily,
    color: color ?? this.color,
  );

  /// Merge another style on top — non-null values in [other] win.
  TextStyle merge(TextStyle? other) {
    if (other == null) return this;
    final TextStyle(
      fontSize: otherFontSize,
      fontWeight: otherFontWeight,
      lineHeight: otherLineHeight,
      letterSpacing: otherLetterSpacing,
      fontFamily: otherFontFamily,
      color: otherColor,
    ) = other;
    return TextStyle(
      fontSize: otherFontSize ?? fontSize,
      fontWeight: otherFontWeight ?? fontWeight,
      lineHeight: otherLineHeight ?? lineHeight,
      letterSpacing: otherLetterSpacing ?? letterSpacing,
      fontFamily: otherFontFamily ?? fontFamily,
      color: otherColor ?? color,
    );
  }

  Map<String, dynamic> toJson() => {
    'fontSize': ?fontSize,
    'fontWeight': ?fontWeight,
    'lineHeight': ?lineHeight,
    'letterSpacing': ?letterSpacing,
    'fontFamily': ?fontFamily,
    'color': ?color,
  };
}
