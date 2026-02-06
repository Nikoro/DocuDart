import 'package:meta/meta.dart';

/// Color configuration for a theme.
@immutable
class ThemeColors {
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
}
