import 'dart:io';

import 'package:jaspr/dom.dart' show Color;
import 'package:path/path.dart' as p;

import 'package:docudart/src/config/docudart_config.dart';
import 'package:docudart/src/theme/color_resolver.dart';
import 'package:docudart/src/theme/theme.dart';
import 'package:docudart/src/models/theme_mode.dart';

/// Parses serializable fields from config.dart by reading it as text.
///
/// This avoids running a subprocess (which fails because config.dart
/// imports package:docudart and user components). The managed Jaspr
/// project imports config.dart directly for function fields (header,
/// footer, sidebar, home).
abstract final class ConfigEvaluator {
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

  static final _commentPattern = RegExp(r'//.*');
  static final _themeModePattern = RegExp(
    r'themeMode\s*:\s*(?:ThemeMode\.)?(\w+)',
  );
  static final _themePattern = RegExp(
    r'Theme\.(classic|material3|shadcn)\s*\(([^()]*(?:\([^)]*\)[^()]*)*)\)',
  );

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
    final match = _themeModePattern.firstMatch(content);
    if (match == null) return .system;
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
    final stripped = content.replaceAll(_commentPattern, '');

    final match = _themePattern.firstMatch(stripped);
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
  /// - `seedColor: Colors.indigo` (named color)
  /// - `seedColor: Color.value(0xFF006D40)` (Color.value constructor)
  static Color? _extractSeedColorFromArgs(String args) {
    // Named color: seedColor: Colors.xxx
    final namedPattern = RegExp(r'seedColor\s*:\s*Colors\.(\w+)');
    final namedMatch = namedPattern.firstMatch(args);
    if (namedMatch != null) {
      final argb = cssNamedColors[namedMatch.group(1)!.toLowerCase()];
      if (argb != null) return Color.value(argb);
    }

    // Color.value constructor: seedColor: Color.value(0xFF...)
    final valuePattern = RegExp(
      r'seedColor\s*:\s*Color\.value\s*\(\s*(0x[0-9A-Fa-f]+)\s*\)',
    );
    final valueMatch = valuePattern.firstMatch(args);
    if (valueMatch != null) {
      final parsed = int.tryParse(valueMatch.group(1)!);
      if (parsed != null) return Color.value(parsed);
    }

    return null;
  }
}
