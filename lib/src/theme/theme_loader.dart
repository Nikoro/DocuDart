import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../cli/errors.dart';
import 'color_scheme.dart';
import 'theme.dart';

/// Loads custom themes from YAML files.
class ThemeLoader {
  /// Load a theme from a YAML file.
  static Future<Theme?> loadFromFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      return _parseTheme(yaml, p.basenameWithoutExtension(path));
    } catch (e) {
      CliPrinter.warning('Failed to load theme from $path: $e');
      return null;
    }
  }

  /// Load a theme by name from the themes directory.
  static Future<Theme?> loadByName(
    String name, [
    String themesDir = 'themes',
  ]) async {
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
  static Future<List<Theme>> discoverThemes([
    String themesDir = 'themes',
  ]) async {
    final dir = Directory(themesDir);
    if (!dir.existsSync()) {
      return [];
    }

    final themes = <Theme>[];

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

  static Theme _parseTheme(YamlMap yaml, String fallbackName) {
    final name = yaml['name'] as String? ?? fallbackName;

    // Parse color schemes
    final lightColors = _parseColorScheme(
      yaml['lightColorScheme'] as YamlMap?,
      const ColorScheme.light(),
    );
    final darkColors = _parseColorScheme(
      yaml['darkColorScheme'] as YamlMap?,
      const ColorScheme.dark(),
    );

    return Theme(
      name: name,
      lightColorScheme: lightColors,
      darkColorScheme: darkColors,
    );
  }

  static ColorScheme _parseColorScheme(YamlMap? yaml, ColorScheme defaults) {
    if (yaml == null) return defaults;

    return ColorScheme(
      primary: _parseColor(yaml['primary']) ?? defaults.primary,
      secondary: _parseColor(yaml['secondary']) ?? defaults.secondary,
      background: _parseColor(yaml['background']) ?? defaults.background,
      surface: _parseColor(yaml['surface']) ?? defaults.surface,
      surfaceVariant:
          _parseColor(yaml['surfaceVariant']) ?? defaults.surfaceVariant,
      text: _parseColor(yaml['text']) ?? defaults.text,
      textMuted: _parseColor(yaml['textMuted']) ?? defaults.textMuted,
      border: _parseColor(yaml['border']) ?? defaults.border,
      codeBackground:
          _parseColor(yaml['codeBackground']) ?? defaults.codeBackground,
      error: _parseColor(yaml['error']) ?? defaults.error,
      success: _parseColor(yaml['success']) ?? defaults.success,
      warning: _parseColor(yaml['warning']) ?? defaults.warning,
      info: _parseColor(yaml['info']) ?? defaults.info,
    );
  }

  /// Parse a color value from string or int.
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
}
