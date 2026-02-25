import 'package:meta/meta.dart';

import 'text_style.dart';

/// Typography configuration for a DocuDart site.
///
/// Defines font families, base font size, and individual text styles
/// for headings (h1–h6), body text, and code.
@immutable
class TextTheme {
  const TextTheme({
    this.fontFamily = 'system-ui, -apple-system, sans-serif',
    this.monoFontFamily = 'monospace',
    this.fontImportUrl,
    this.baseFontSize = 16,
    this.bodyLineHeight = 1.6,
    this.headingLineHeight = 1.3,
    this.h1 = const TextStyle(fontSize: 2.5, fontWeight: 700),
    this.h2 = const TextStyle(fontSize: 1.75, fontWeight: 600),
    this.h3 = const TextStyle(fontSize: 1.25, fontWeight: 600),
    this.h4 = const TextStyle(fontSize: 1.0, fontWeight: 600),
    this.h5 = const TextStyle(fontSize: 0.875, fontWeight: 600),
    this.h6 = const TextStyle(fontSize: 0.75, fontWeight: 600),
    this.body = const TextStyle(
      fontSize: 1.0,
      fontWeight: 400,
      lineHeight: 1.6,
    ),
    this.code = const TextStyle(fontSize: 0.875),
  });

  /// dart.dev / flutter.dev style typography.
  const TextTheme.classic({
    this.fontFamily = 'Inter, system-ui, -apple-system, sans-serif',
    this.monoFontFamily = 'JetBrains Mono, Fira Code, monospace',
    this.fontImportUrl =
        'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap',
    this.baseFontSize = 16,
    this.bodyLineHeight = 1.6,
    this.headingLineHeight = 1.3,
    this.h1 = const TextStyle(fontSize: 2.5, fontWeight: 700),
    this.h2 = const TextStyle(fontSize: 1.75, fontWeight: 600),
    this.h3 = const TextStyle(fontSize: 1.25, fontWeight: 600),
    this.h4 = const TextStyle(fontSize: 1.0, fontWeight: 600),
    this.h5 = const TextStyle(fontSize: 0.875, fontWeight: 600),
    this.h6 = const TextStyle(fontSize: 0.75, fontWeight: 600),
    this.body = const TextStyle(
      fontSize: 1.0,
      fontWeight: 400,
      lineHeight: 1.6,
    ),
    this.code = const TextStyle(fontSize: 0.875),
  });

  /// Material Design 3 style typography.
  const TextTheme.material3({
    this.fontFamily = 'Roboto, system-ui, sans-serif',
    this.monoFontFamily = 'Roboto Mono, monospace',
    this.fontImportUrl =
        'https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&family=Roboto+Mono:wght@400;500&display=swap',
    this.baseFontSize = 16,
    this.bodyLineHeight = 1.5,
    this.headingLineHeight = 1.25,
    this.h1 = const TextStyle(
      fontSize: 2.25,
      fontWeight: 400,
      letterSpacing: -0.02,
    ),
    this.h2 = const TextStyle(
      fontSize: 1.75,
      fontWeight: 400,
      letterSpacing: -0.01,
    ),
    this.h3 = const TextStyle(fontSize: 1.5, fontWeight: 400),
    this.h4 = const TextStyle(fontSize: 1.125, fontWeight: 500),
    this.h5 = const TextStyle(fontSize: 0.875, fontWeight: 500),
    this.h6 = const TextStyle(fontSize: 0.75, fontWeight: 500),
    this.body = const TextStyle(
      fontSize: 1.0,
      fontWeight: 400,
      lineHeight: 1.5,
      letterSpacing: 0.01,
    ),
    this.code = const TextStyle(fontSize: 0.875),
  });

  /// shadcn/ui style typography.
  const TextTheme.shadcn({
    this.fontFamily = 'Inter, system-ui, -apple-system, sans-serif',
    this.monoFontFamily = 'JetBrains Mono, Fira Code, monospace',
    this.fontImportUrl =
        'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap',
    this.baseFontSize = 16,
    this.bodyLineHeight = 1.7,
    this.headingLineHeight = 1.2,
    this.h1 = const TextStyle(
      fontSize: 2.25,
      fontWeight: 800,
      letterSpacing: -0.03,
    ),
    this.h2 = const TextStyle(
      fontSize: 1.875,
      fontWeight: 700,
      letterSpacing: -0.02,
    ),
    this.h3 = const TextStyle(
      fontSize: 1.5,
      fontWeight: 600,
      letterSpacing: -0.01,
    ),
    this.h4 = const TextStyle(fontSize: 1.25, fontWeight: 600),
    this.h5 = const TextStyle(fontSize: 1.0, fontWeight: 600),
    this.h6 = const TextStyle(fontSize: 0.875, fontWeight: 600),
    this.body = const TextStyle(
      fontSize: 1.0,
      fontWeight: 400,
      lineHeight: 1.7,
    ),
    this.code = const TextStyle(fontSize: 0.875),
  });

  factory TextTheme.fromJson(Map<String, dynamic> json) => .new(
    fontFamily:
        json['fontFamily'] as String? ?? 'system-ui, -apple-system, sans-serif',
    monoFontFamily: json['monoFontFamily'] as String? ?? 'monospace',
    fontImportUrl: json['fontImportUrl'] as String?,
    baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 16,
    bodyLineHeight: (json['bodyLineHeight'] as num?)?.toDouble() ?? 1.6,
    headingLineHeight: (json['headingLineHeight'] as num?)?.toDouble() ?? 1.3,
    h1:
        _styleFromJson(json['h1']) ??
        const TextStyle(fontSize: 2.5, fontWeight: 700),
    h2:
        _styleFromJson(json['h2']) ??
        const TextStyle(fontSize: 1.75, fontWeight: 600),
    h3:
        _styleFromJson(json['h3']) ??
        const TextStyle(fontSize: 1.25, fontWeight: 600),
    h4:
        _styleFromJson(json['h4']) ??
        const TextStyle(fontSize: 1.0, fontWeight: 600),
    h5:
        _styleFromJson(json['h5']) ??
        const TextStyle(fontSize: 0.875, fontWeight: 600),
    h6:
        _styleFromJson(json['h6']) ??
        const TextStyle(fontSize: 0.75, fontWeight: 600),
    body:
        _styleFromJson(json['body']) ??
        const TextStyle(fontSize: 1.0, fontWeight: 400, lineHeight: 1.6),
    code: _styleFromJson(json['code']) ?? const TextStyle(fontSize: 0.875),
  );

  /// Primary font family for body text.
  final String fontFamily;

  /// Monospace font family for code.
  final String monoFontFamily;

  /// Google Fonts import URL. If null, no font import link is generated.
  final String? fontImportUrl;

  /// Base font size in pixels.
  final double baseFontSize;

  /// Default line height for body text.
  final double bodyLineHeight;

  /// Default line height for headings.
  final double headingLineHeight;

  /// Heading 1 style.
  final TextStyle h1;

  /// Heading 2 style.
  final TextStyle h2;

  /// Heading 3 style.
  final TextStyle h3;

  /// Heading 4 style.
  final TextStyle h4;

  /// Heading 5 style.
  final TextStyle h5;

  /// Heading 6 style.
  final TextStyle h6;

  /// Body text style.
  final TextStyle body;

  /// Code text style.
  final TextStyle code;

  /// Generate CSS variable declarations for base typography.
  Map<String, String> get cssVariables => {
    '--font-family': fontFamily,
    '--font-family-mono': monoFontFamily,
    '--font-size-base': '${baseFontSize}px',
    '--line-height': '$bodyLineHeight',
    '--line-height-heading': '$headingLineHeight',
  };

  TextTheme copyWith({
    String? fontFamily,
    String? monoFontFamily,
    String? fontImportUrl,
    double? baseFontSize,
    double? bodyLineHeight,
    double? headingLineHeight,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? h5,
    TextStyle? h6,
    TextStyle? body,
    TextStyle? code,
  }) => .new(
    fontFamily: fontFamily ?? this.fontFamily,
    monoFontFamily: monoFontFamily ?? this.monoFontFamily,
    fontImportUrl: fontImportUrl ?? this.fontImportUrl,
    baseFontSize: baseFontSize ?? this.baseFontSize,
    bodyLineHeight: bodyLineHeight ?? this.bodyLineHeight,
    headingLineHeight: headingLineHeight ?? this.headingLineHeight,
    h1: h1 ?? this.h1,
    h2: h2 ?? this.h2,
    h3: h3 ?? this.h3,
    h4: h4 ?? this.h4,
    h5: h5 ?? this.h5,
    h6: h6 ?? this.h6,
    body: body ?? this.body,
    code: code ?? this.code,
  );

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'monoFontFamily': monoFontFamily,
    'fontImportUrl': ?fontImportUrl,
    'baseFontSize': baseFontSize,
    'bodyLineHeight': bodyLineHeight,
    'headingLineHeight': headingLineHeight,
    'h1': h1.toJson(),
    'h2': h2.toJson(),
    'h3': h3.toJson(),
    'h4': h4.toJson(),
    'h5': h5.toJson(),
    'h6': h6.toJson(),
    'body': body.toJson(),
    'code': code.toJson(),
  };

  static TextStyle? _styleFromJson(dynamic json) {
    if (json == null) return null;
    return TextStyle.fromJson(json as Map<String, dynamic>);
  }
}
