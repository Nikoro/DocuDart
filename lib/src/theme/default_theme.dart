import 'package:meta/meta.dart';

import 'base_theme.dart';
import 'theme_colors.dart';
import 'theme_typography.dart';
import '../config/theme_config.dart';

/// Default theme with Flutter docs style (blue accents, card-based layout).
@immutable
class DefaultTheme extends BaseTheme {
  /// Primary color override.
  final int? primaryColor;

  @override
  final DarkModeConfig darkMode;

  const DefaultTheme({
    this.primaryColor,
    this.darkMode = DarkModeConfig.system,
  });

  @override
  String get name => 'default';

  @override
  ThemeColors get colors => ThemeColors(
    primary: primaryColor ?? 0xFF0175C2, // Flutter blue
    secondary: 0xFF13B9FD,
    background: 0xFFFFFFFF,
    surface: 0xFFF8F9FA,
    text: 0xFF1D1D1D,
    textMuted: 0xFF6C757D,
    border: 0xFFE0E0E0,
    codeBackground: 0xFFF5F5F5,
    // Dark mode colors
    darkPrimary: 0xFF54C5F8,
    darkSecondary: 0xFF13B9FD,
    darkBackground: 0xFF0D1117,
    darkSurface: 0xFF161B22,
    darkText: 0xFFE6EDF3,
    darkTextMuted: 0xFF8B949E,
    darkBorder: 0xFF30363D,
    darkCodeBackground: 0xFF161B22,
  );

  @override
  ThemeTypography get typography => const ThemeTypography(
    fontFamily: 'Inter, system-ui, -apple-system, sans-serif',
    monoFontFamily: 'JetBrains Mono, Fira Code, monospace',
    baseFontSize: 16,
    lineHeight: 1.6,
    headingLineHeight: 1.3,
  );

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'type': 'default',
    if (primaryColor != null) 'primaryColor': primaryColor,
  };
}
