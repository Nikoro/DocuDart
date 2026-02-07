import 'dart:io';

import 'package:path/path.dart' as p;

import 'docudart_config.dart';
import '../theme/default_theme.dart';
import 'theme_config.dart';

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
    final logo = _extractString(content, 'logo');
    final docsDir = _extractString(content, 'docsDir') ?? 'docs';
    final pagesDir = _extractString(content, 'pagesDir') ?? 'pages';
    final assetsDir = _extractString(content, 'assetsDir') ?? 'assets';
    final outputDir = _extractString(content, 'outputDir') ?? 'build/web';
    final baseUrl = _extractString(content, 'baseUrl') ?? '/';
    final cleanUrls = _extractBool(content, 'cleanUrls') ?? true;
    final themeMode = _extractThemeMode(content);
    final primaryColor = _extractPrimaryColor(content);

    return Config(
      title: title,
      description: description,
      logo: logo,
      docsDir: docsDir,
      pagesDir: pagesDir,
      assetsDir: assetsDir,
      outputDir: outputDir,
      baseUrl: baseUrl,
      cleanUrls: cleanUrls,
      themeMode: themeMode,
      theme: primaryColor != null
          ? DefaultTheme(primaryColor: primaryColor)
          : const DefaultTheme(),
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

  /// Extract a bool value for a named field: `fieldName: true/false`
  static bool? _extractBool(String content, String field) {
    final pattern = RegExp(
      r'''(?:^|\s)''' + RegExp.escape(field) + r'''\s*:\s*(true|false)''',
    );
    final match = pattern.firstMatch(content);
    if (match == null) return null;
    return match.group(1) == 'true';
  }

  /// Extract ThemeMode from: `themeMode: ThemeMode.system`
  static ThemeMode _extractThemeMode(String content) {
    final pattern = RegExp(r'themeMode\s*:\s*ThemeMode\.(\w+)');
    final match = pattern.firstMatch(content);
    if (match == null) return ThemeMode.system;
    return ThemeMode.fromJson(match.group(1)!);
  }

  /// Extract primaryColor from: `primaryColor: 0xFF0175C2`
  /// Only matches uncommented lines.
  static int? _extractPrimaryColor(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trimLeft();
      // Skip commented lines
      if (trimmed.startsWith('//')) continue;
      final pattern = RegExp(r'primaryColor\s*:\s*(0x[0-9A-Fa-f]+)');
      final match = pattern.firstMatch(trimmed);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }
    return null;
  }
}
