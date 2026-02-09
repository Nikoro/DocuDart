import 'package:meta/meta.dart';

/// Color configuration for a theme.
@immutable
class ThemeColors {
  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.codeBackground,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkText,
    required this.darkTextMuted,
    required this.darkBorder,
    required this.darkCodeBackground,
  });

  factory ThemeColors.fromJson(Map<String, dynamic> json) => ThemeColors(
    primary: json['primary'] as int,
    secondary: json['secondary'] as int,
    background: json['background'] as int,
    surface: json['surface'] as int,
    text: json['text'] as int,
    textMuted: json['textMuted'] as int,
    border: json['border'] as int,
    codeBackground: json['codeBackground'] as int,
    darkPrimary: json['darkPrimary'] as int,
    darkSecondary: json['darkSecondary'] as int,
    darkBackground: json['darkBackground'] as int,
    darkSurface: json['darkSurface'] as int,
    darkText: json['darkText'] as int,
    darkTextMuted: json['darkTextMuted'] as int,
    darkBorder: json['darkBorder'] as int,
    darkCodeBackground: json['darkCodeBackground'] as int,
  );
  // Light mode colors
  final int primary;
  final int secondary;
  final int background;
  final int surface;
  final int text;
  final int textMuted;
  final int border;
  final int codeBackground;

  // Dark mode colors
  final int darkPrimary;
  final int darkSecondary;
  final int darkBackground;
  final int darkSurface;
  final int darkText;
  final int darkTextMuted;
  final int darkBorder;
  final int darkCodeBackground;

  /// Convert color int to CSS hex string.
  static String toHex(int color) {
    return '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  /// Get CSS variable declarations for light mode.
  Map<String, String> get lightCssVariables => {
    '--color-primary': toHex(primary),
    '--color-secondary': toHex(secondary),
    '--color-background': toHex(background),
    '--color-surface': toHex(surface),
    '--color-text': toHex(text),
    '--color-text-muted': toHex(textMuted),
    '--color-border': toHex(border),
    '--color-code-background': toHex(codeBackground),
  };

  /// Get CSS variable declarations for dark mode.
  Map<String, String> get darkCssVariables => {
    '--color-primary': toHex(darkPrimary),
    '--color-secondary': toHex(darkSecondary),
    '--color-background': toHex(darkBackground),
    '--color-surface': toHex(darkSurface),
    '--color-text': toHex(darkText),
    '--color-text-muted': toHex(darkTextMuted),
    '--color-border': toHex(darkBorder),
    '--color-code-background': toHex(darkCodeBackground),
  };

  Map<String, dynamic> toJson() => {
    'primary': primary,
    'secondary': secondary,
    'background': background,
    'surface': surface,
    'text': text,
    'textMuted': textMuted,
    'border': border,
    'codeBackground': codeBackground,
    'darkPrimary': darkPrimary,
    'darkSecondary': darkSecondary,
    'darkBackground': darkBackground,
    'darkSurface': darkSurface,
    'darkText': darkText,
    'darkTextMuted': darkTextMuted,
    'darkBorder': darkBorder,
    'darkCodeBackground': darkCodeBackground,
  };
}
