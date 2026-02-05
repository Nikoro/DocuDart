import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'base_theme.dart';
import 'theme_colors.dart';
import 'theme_typography.dart';
import '../config/theme_config.dart';

/// A theme loaded from a YAML configuration file.
class CustomTheme extends BaseTheme {
  @override
  final String name;

  @override
  final ThemeColors colors;

  @override
  final ThemeTypography typography;

  @override
  final DarkModeConfig darkMode;

  const CustomTheme({
    required this.name,
    required this.colors,
    required this.typography,
    required this.darkMode,
  });
}

/// Loads custom themes from YAML files.
class ThemeLoader {
  /// Load a theme from a YAML file.
  ///
  /// Theme YAML format:
  /// ```yaml
  /// name: my-theme
  ///
  /// colors:
  ///   primary: "#6366F1"
  ///   secondary: "#8B5CF6"
  ///   background: "#FFFFFF"
  ///   surface: "#F9FAFB"
  ///   text: "#111827"
  ///   textMuted: "#6B7280"
  ///   border: "#E5E7EB"
  ///   codeBackground: "#F3F4F6"
  ///
  /// darkColors:
  ///   primary: "#818CF8"
  ///   secondary: "#A78BFA"
  ///   background: "#111827"
  ///   surface: "#1F2937"
  ///   text: "#F9FAFB"
  ///   textMuted: "#9CA3AF"
  ///   border: "#374151"
  ///   codeBackground: "#1F2937"
  ///
  /// typography:
  ///   fontFamily: "Inter, sans-serif"
  ///   monoFontFamily: "JetBrains Mono, monospace"
  ///   baseFontSize: 16
  ///   lineHeight: 1.6
  ///
  /// darkMode: system  # system, light, dark, or toggle
  /// ```
  static Future<CustomTheme?> loadFromFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      return _parseTheme(yaml, p.basenameWithoutExtension(path));
    } catch (e) {
      print('Warning: Failed to load theme from $path: $e');
      return null;
    }
  }

  /// Load a theme by name from the themes directory.
  static Future<CustomTheme?> loadByName(String name, [String themesDir = 'themes']) async {
    // Try .yaml then .yml extensions
    for (final ext in ['.yaml', '.yml']) {
      final path = p.join(themesDir, '$name$ext');
      final theme = await loadFromFile(path);
      if (theme != null) {
        return theme;
      }
    }
    return null;
  }

  /// Discover all themes in a directory.
  static Future<List<CustomTheme>> discoverThemes([String themesDir = 'themes']) async {
    final dir = Directory(themesDir);
    if (!dir.existsSync()) {
      return [];
    }

    final themes = <CustomTheme>[];

    await for (final entity in dir.list()) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (ext == '.yaml' || ext == '.yml') {
          final theme = await loadFromFile(entity.path);
          if (theme != null) {
            themes.add(theme);
          }
        }
      }
    }

    return themes;
  }

  static CustomTheme _parseTheme(YamlMap yaml, String fallbackName) {
    final name = yaml['name'] as String? ?? fallbackName;

    // Parse colors
    final colorsYaml = yaml['colors'] as YamlMap? ?? YamlMap();
    final darkColorsYaml = yaml['darkColors'] as YamlMap? ?? YamlMap();

    final colors = ThemeColors(
      primary: _parseColor(colorsYaml['primary']) ?? 0xFF0175C2,
      secondary: _parseColor(colorsYaml['secondary']) ?? 0xFF13B9FD,
      background: _parseColor(colorsYaml['background']) ?? 0xFFFFFFFF,
      surface: _parseColor(colorsYaml['surface']) ?? 0xFFF8F9FA,
      text: _parseColor(colorsYaml['text']) ?? 0xFF1D1D1D,
      textMuted: _parseColor(colorsYaml['textMuted']) ?? 0xFF6C757D,
      border: _parseColor(colorsYaml['border']) ?? 0xFFE0E0E0,
      codeBackground: _parseColor(colorsYaml['codeBackground']) ?? 0xFFF5F5F5,
      darkPrimary: _parseColor(darkColorsYaml['primary']) ?? 0xFF54C5F8,
      darkSecondary: _parseColor(darkColorsYaml['secondary']) ?? 0xFF13B9FD,
      darkBackground: _parseColor(darkColorsYaml['background']) ?? 0xFF0D1117,
      darkSurface: _parseColor(darkColorsYaml['surface']) ?? 0xFF161B22,
      darkText: _parseColor(darkColorsYaml['text']) ?? 0xFFE6EDF3,
      darkTextMuted: _parseColor(darkColorsYaml['textMuted']) ?? 0xFF8B949E,
      darkBorder: _parseColor(darkColorsYaml['border']) ?? 0xFF30363D,
      darkCodeBackground: _parseColor(darkColorsYaml['codeBackground']) ?? 0xFF161B22,
    );

    // Parse typography
    final typographyYaml = yaml['typography'] as YamlMap? ?? YamlMap();
    final typography = ThemeTypography(
      fontFamily: typographyYaml['fontFamily'] as String? ??
          'Inter, system-ui, -apple-system, sans-serif',
      monoFontFamily: typographyYaml['monoFontFamily'] as String? ??
          'JetBrains Mono, Fira Code, monospace',
      baseFontSize: (typographyYaml['baseFontSize'] as num?)?.toDouble() ?? 16,
      lineHeight: (typographyYaml['lineHeight'] as num?)?.toDouble() ?? 1.6,
      headingLineHeight:
          (typographyYaml['headingLineHeight'] as num?)?.toDouble() ?? 1.3,
    );

    // Parse dark mode config
    final darkModeStr = yaml['darkMode'] as String? ?? 'system';
    final darkMode = _parseDarkModeConfig(darkModeStr);

    return CustomTheme(
      name: name,
      colors: colors,
      typography: typography,
      darkMode: darkMode,
    );
  }

  /// Parse a color value from string or int.
  ///
  /// Supports:
  /// - Hex strings: "#FF0000", "FF0000", "#F00"
  /// - Integer values: 0xFF0000
  static int? _parseColor(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is String) {
      var hex = value.trim();

      // Remove # prefix
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }

      // Handle shorthand hex (e.g., #F00 -> #FF0000)
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join();
      }

      // Add alpha if not present
      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      return int.tryParse(hex, radix: 16);
    }

    return null;
  }

  static DarkModeConfig _parseDarkModeConfig(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return DarkModeConfig.light;
      case 'dark':
        return DarkModeConfig.dark;
      case 'toggle':
        return DarkModeConfig.toggle;
      case 'system':
      default:
        return DarkModeConfig.system;
    }
  }
}
