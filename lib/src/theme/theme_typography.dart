import 'package:meta/meta.dart';

/// Typography configuration for a theme.
@immutable
class ThemeTypography {
  /// Primary font family for body text.
  final String fontFamily;

  /// Monospace font family for code.
  final String monoFontFamily;

  /// Base font size in pixels.
  final double baseFontSize;

  /// Line height for body text.
  final double lineHeight;

  /// Line height for headings.
  final double headingLineHeight;

  const ThemeTypography({
    this.fontFamily = 'system-ui, -apple-system, sans-serif',
    this.monoFontFamily = 'monospace',
    this.baseFontSize = 16,
    this.lineHeight = 1.6,
    this.headingLineHeight = 1.3,
  });

  /// Get CSS variable declarations.
  Map<String, String> get cssVariables => {
    '--font-family': fontFamily,
    '--font-family-mono': monoFontFamily,
    '--font-size-base': '${baseFontSize}px',
    '--line-height': '$lineHeight',
    '--line-height-heading': '$headingLineHeight',
  };

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'monoFontFamily': monoFontFamily,
    'baseFontSize': baseFontSize,
    'lineHeight': lineHeight,
    'headingLineHeight': headingLineHeight,
  };

  factory ThemeTypography.fromJson(Map<String, dynamic> json) =>
      ThemeTypography(
        fontFamily: json['fontFamily'] as String? ??
            'system-ui, -apple-system, sans-serif',
        monoFontFamily: json['monoFontFamily'] as String? ?? 'monospace',
        baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 16,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.6,
        headingLineHeight:
            (json['headingLineHeight'] as num?)?.toDouble() ?? 1.3,
      );
}
