import 'dart:io';

import 'package:path/path.dart' as p;

import 'docudart_config.dart';
import '../theme/color_resolver.dart';
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
  /// - `Theme.classic()` / `Theme.classic(seedColor: 0xFF...)`
  /// - `Theme.classic(seedColor: Colors.indigo)`
  /// - `Theme.classic(seedColor: Color.value(0xFF...))`
  /// - Same for `material3` and `shadcn`
  static Theme? _extractTheme(String content) {
    // Strip single-line comments to avoid matching commented-out theme lines
    final stripped = content.replaceAll(RegExp(r'//.*'), '');

    // Match Theme.factory(...) allowing one level of nested parens
    // (for Color.value(...) inside the constructor)
    final pattern = RegExp(
      r'Theme\.(classic|material3|shadcn)\s*\(([^)]*(?:\([^)]*\)[^)]*)*)\)',
    );
    final match = pattern.firstMatch(stripped);
    if (match == null) return null;

    final factory = match.group(1)!;
    final args = match.group(2) ?? '';

    final seedColor = _extractSeedColorFromArgs(args);

    return switch (factory) {
      'classic' => Theme.classic(seedColor: seedColor),
      'material3' => Theme.material3(seedColor: seedColor),
      'shadcn' => Theme.shadcn(seedColor: seedColor),
      _ => null,
    };
  }

  /// Extract seedColor from constructor arguments string.
  ///
  /// Recognizes:
  /// - `seedColor: 0xFF006D40` (hex int literal)
  /// - `seedColor: Colors.indigo` (named color)
  /// - `seedColor: Color.value(0xFF006D40)` (Color.value constructor)
  static int? _extractSeedColorFromArgs(String args) {
    // Hex int literal: seedColor: 0xFF...
    final hexPattern = RegExp(r'seedColor\s*:\s*(0x[0-9A-Fa-f]+)');
    final hexMatch = hexPattern.firstMatch(args);
    if (hexMatch != null) return int.tryParse(hexMatch.group(1)!);

    // Named color: seedColor: Colors.xxx
    final namedPattern = RegExp(r'seedColor\s*:\s*Colors\.(\w+)');
    final namedMatch = namedPattern.firstMatch(args);
    if (namedMatch != null) {
      return cssNamedColors[namedMatch.group(1)!.toLowerCase()];
    }

    // Color.value constructor: seedColor: Color.value(0xFF...)
    final valuePattern = RegExp(
      r'seedColor\s*:\s*Color\.value\s*\(\s*(0x[0-9A-Fa-f]+)\s*\)',
    );
    final valueMatch = valuePattern.firstMatch(args);
    if (valueMatch != null) return int.tryParse(valueMatch.group(1)!);

    return null;
  }
}
