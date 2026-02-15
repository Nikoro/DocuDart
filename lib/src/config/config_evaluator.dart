import 'dart:io';

import 'package:path/path.dart' as p;

import 'docudart_config.dart';
import '../theme/theme.dart';
import '../models/theme_mode.dart';

/// Parses serializable fields from config.dart by reading it as text.
///
/// This avoids running a subprocess (which fails because config.dart
/// imports package:docudart and user components). The managed Jaspr
/// project imports config.dart directly for function fields (header,
/// footer, sidebar, home).
class ConfigEvaluator {
  /// Parse config.dart in the given website directory.
  /// Returns null if config.dart doesn't exist.
  static Future<Config?> evaluate(String websiteDir) async {
    final configFile = File(p.join(websiteDir, 'config.dart'));
    if (!configFile.existsSync()) {
      return null;
    }

    try {
      final content = await configFile.readAsString();
      return _parseConfig(content);
    } catch (e) {
      // Silent fallback — YAML loader will handle it
      return null;
    }
  }

  /// Parse serializable fields from config.dart source text.
  static Config? _parseConfig(String content) {
    final title = _extractString(content, 'title');
    final description = _extractString(content, 'description');
    final docsDir = _extractString(content, 'docsDir') ?? 'docs';
    final assetsDir = _extractString(content, 'assetsDir') ?? 'assets';
    final outputDir = _extractString(content, 'outputDir') ?? 'build/web';
    final themeMode = _extractThemeMode(content);
    final theme = _extractTheme(content);

    return Config(
      title: title,
      description: description,
      docsDir: docsDir,
      assetsDir: assetsDir,
      outputDir: outputDir,
      themeMode: themeMode,
      theme: theme,
    );
  }

  /// Extract a string value for a named field: `fieldName: 'value'`
  static String? _extractString(String content, String field) {
    // Match: fieldName: 'value' or fieldName: "value"
    final pattern = RegExp(
      r'''(?:^|\s)''' + RegExp.escape(field) + r'''\s*:\s*(['"])(.*?)\1''',
    );
    final match = pattern.firstMatch(content);
    return match?.group(2);
  }

  /// Extract ThemeMode from: `themeMode: ThemeMode.system` or `themeMode: .system`
  static ThemeMode _extractThemeMode(String content) {
    final pattern = RegExp(r'themeMode\s*:\s*(?:ThemeMode\.)?(\w+)');
    final match = pattern.firstMatch(content);
    if (match == null) return ThemeMode.system;
    return ThemeMode.fromJson(match.group(1)!);
  }

  /// Extract Theme from config.dart source text.
  ///
  /// Recognizes:
  /// - `Theme.classic()` / `Theme.classic(primaryColor: 0xFF...)`
  /// - `Theme.material3()` / `Theme.material3(primaryColor: 0xFF...)`
  /// - `Theme.shadcn()` / `Theme.shadcn(primaryColor: 0xFF...)`
  static Theme? _extractTheme(String content) {
    // Strip single-line comments to avoid matching commented-out theme lines
    final stripped = content.replaceAll(RegExp(r'//.*'), '');

    // Match Theme.factory(primaryColor: 0xFF...) or Theme.factory()
    final pattern = RegExp(r'Theme\.(classic|material3|shadcn)\s*\(([^)]*)\)');
    final match = pattern.firstMatch(stripped);
    if (match == null) return null;

    final factory = match.group(1)!;
    final args = match.group(2) ?? '';

    // Extract primaryColor if present
    final primaryColor = _extractPrimaryColorFromArgs(args);

    return switch (factory) {
      'classic' => Theme.classic(primaryColor: primaryColor),
      'material3' => Theme.material3(primaryColor: primaryColor),
      'shadcn' => Theme.shadcn(primaryColor: primaryColor),
      _ => null,
    };
  }

  /// Extract primaryColor from constructor arguments string.
  static int? _extractPrimaryColorFromArgs(String args) {
    final pattern = RegExp(r'primaryColor\s*:\s*(0x[0-9A-Fa-f]+)');
    final match = pattern.firstMatch(args);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}
