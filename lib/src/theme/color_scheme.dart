import 'package:meta/meta.dart';

import 'color_utils.dart';

/// Brightness mode for color scheme generation.
enum Brightness { light, dark }

/// Color scheme for a single theme mode (light or dark).
///
/// Contains 13 colors covering brand, surface, text, chrome, and semantic
/// needs of a documentation site. Each color is an int in 0xAARRGGBB format.
@immutable
class ColorScheme {
  const ColorScheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.codeBackground,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
  });

  /// Handcrafted light mode defaults (dart.dev / flutter.dev inspired).
  const ColorScheme.light({
    this.primary = 0xFF0175C2,
    this.secondary = 0xFF13B9FD,
    this.background = 0xFFFFFFFF,
    this.surface = 0xFFF8F9FA,
    this.surfaceVariant = 0xFFF1F3F5,
    this.text = 0xFF1D1D1D,
    this.textMuted = 0xFF6C757D,
    this.border = 0xFFE0E0E0,
    this.codeBackground = 0xFFF5F5F5,
    this.error = 0xFFDC3545,
    this.success = 0xFF28A745,
    this.warning = 0xFFFFC107,
    this.info = 0xFF17A2B8,
  });

  /// Handcrafted dark mode defaults (dart.dev / flutter.dev inspired).
  const ColorScheme.dark({
    this.primary = 0xFF54C5F8,
    this.secondary = 0xFF13B9FD,
    this.background = 0xFF0D1117,
    this.surface = 0xFF161B22,
    this.surfaceVariant = 0xFF21262D,
    this.text = 0xFFE6EDF3,
    this.textMuted = 0xFF8B949E,
    this.border = 0xFF30363D,
    this.codeBackground = 0xFF161B22,
    this.error = 0xFFFF6B6B,
    this.success = 0xFF51CF66,
    this.warning = 0xFFFFD43B,
    this.info = 0xFF4DABF7,
  });

  /// Generate a complete color scheme from a single seed color.
  ///
  /// All neutral colors (background, surface, text, border) carry a subtle
  /// hue tint from the seed, creating a cohesive palette. Semantic colors
  /// (error, success, warning, info) stay fixed for accessibility.
  factory ColorScheme.fromSeed({
    required int seedColor,
    Brightness brightness = Brightness.light,
  }) {
    final seed = HSL.fromInt(seedColor);
    final h = seed.hue;

    if (brightness == Brightness.light) {
      return ColorScheme(
        primary: seedColor,
        secondary: HSL(h + 30, 0.70, 0.55).toInt(),
        background: HSL(h, 0.05, 0.99).toInt(),
        surface: HSL(h, 0.05, 0.97).toInt(),
        surfaceVariant: HSL(h, 0.08, 0.95).toInt(),
        text: HSL(h, 0.05, 0.12).toInt(),
        textMuted: HSL(h, 0.05, 0.45).toInt(),
        border: HSL(h, 0.10, 0.88).toInt(),
        codeBackground: HSL(h, 0.10, 0.96).toInt(),
        error: 0xFFDC3545,
        success: 0xFF28A745,
        warning: 0xFFFFC107,
        info: 0xFF17A2B8,
      );
    }

    return ColorScheme(
      primary: HSL(h, 0.85, 0.70).toInt(),
      secondary: HSL(h + 30, 0.65, 0.65).toInt(),
      background: HSL(h, 0.15, 0.05).toInt(),
      surface: HSL(h, 0.12, 0.09).toInt(),
      surfaceVariant: HSL(h, 0.15, 0.13).toInt(),
      text: HSL(h, 0.10, 0.92).toInt(),
      textMuted: HSL(h, 0.08, 0.58).toInt(),
      border: HSL(h, 0.15, 0.19).toInt(),
      codeBackground: HSL(h, 0.12, 0.08).toInt(),
      error: 0xFFFF6B6B,
      success: 0xFF51CF66,
      warning: 0xFFFFD43B,
      info: 0xFF4DABF7,
    );
  }

  factory ColorScheme.fromJson(Map<String, dynamic> json) => ColorScheme(
    primary: json['primary'] as int,
    secondary: json['secondary'] as int,
    background: json['background'] as int,
    surface: json['surface'] as int,
    surfaceVariant: json['surfaceVariant'] as int,
    text: json['text'] as int,
    textMuted: json['textMuted'] as int,
    border: json['border'] as int,
    codeBackground: json['codeBackground'] as int,
    error: json['error'] as int,
    success: json['success'] as int,
    warning: json['warning'] as int,
    info: json['info'] as int,
  );

  /// Primary brand color. Used for links, active states, buttons.
  final int primary;

  /// Secondary accent color. Used for hover effects, secondary actions.
  final int secondary;

  /// Page background color.
  final int background;

  /// Elevated surface color (header, sidebar, footer, cards).
  final int surface;

  /// Alternative surface color (table headers, hover states).
  final int surfaceVariant;

  /// Primary text color (headings, body text).
  final int text;

  /// Secondary text color (descriptions, labels, footer text).
  final int textMuted;

  /// Border and divider color.
  final int border;

  /// Inline code and code block background.
  final int codeBackground;

  /// Error / danger semantic color.
  final int error;

  /// Success / tip semantic color.
  final int success;

  /// Warning semantic color.
  final int warning;

  /// Info semantic color.
  final int info;

  /// Convert color int to CSS hex string (#RRGGBB).
  static String toHex(int color) =>
      '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// Convert color int to CSS rgba with alpha.
  static String toRgba(int color, double alpha) {
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    return 'rgba($r, $g, $b, $alpha)';
  }

  /// Generate CSS custom property declarations for this scheme.
  Map<String, String> get cssVariables => {
    '--color-primary': toHex(primary),
    '--color-secondary': toHex(secondary),
    '--color-background': toHex(background),
    '--color-surface': toHex(surface),
    '--color-surface-variant': toHex(surfaceVariant),
    '--color-text': toHex(text),
    '--color-text-muted': toHex(textMuted),
    '--color-border': toHex(border),
    '--color-code-background': toHex(codeBackground),
    '--color-error': toHex(error),
    '--color-success': toHex(success),
    '--color-warning': toHex(warning),
    '--color-info': toHex(info),
  };

  ColorScheme copyWith({
    int? primary,
    int? secondary,
    int? background,
    int? surface,
    int? surfaceVariant,
    int? text,
    int? textMuted,
    int? border,
    int? codeBackground,
    int? error,
    int? success,
    int? warning,
    int? info,
  }) => ColorScheme(
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    border: border ?? this.border,
    codeBackground: codeBackground ?? this.codeBackground,
    error: error ?? this.error,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
  );

  Map<String, dynamic> toJson() => {
    'primary': primary,
    'secondary': secondary,
    'background': background,
    'surface': surface,
    'surfaceVariant': surfaceVariant,
    'text': text,
    'textMuted': textMuted,
    'border': border,
    'codeBackground': codeBackground,
    'error': error,
    'success': success,
    'warning': warning,
    'info': info,
  };
}
