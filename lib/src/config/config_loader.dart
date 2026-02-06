import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'config_evaluator.dart';
import 'docudart_config.dart';
import '../theme/base_theme.dart';
import '../theme/default_theme.dart';
import '../theme/theme_loader.dart';

/// Loads DocuDart configuration from config.dart or defaults.
class ConfigLoader {
  /// Load configuration from the current directory.
  ///
  /// The loader will:
  /// 1. Try to evaluate config.dart (Dart-based config)
  /// 2. Fall back to pubspec.yaml + docudart.yaml (YAML-based config)
  /// 3. Absolutize directory paths relative to the website directory
  static Future<DocuDartConfig> load([String? directory]) async {
    final dir = directory ?? Directory.current.path;

    // Try to evaluate config.dart first (the Dart-based config)
    final dartConfig = await ConfigEvaluator.evaluate(dir);
    if (dartConfig != null) {
      return dartConfig.copyWith(
        docsDir: _absolutize(dir, dartConfig.docsDir),
        outputDir: _absolutize(dir, dartConfig.outputDir),
        assetsDir: _absolutize(dir, dartConfig.assetsDir),
      );
    }

    // Fall back to YAML-based loading
    return _loadFromYaml(dir);
  }

  static String _absolutize(String dir, String path) {
    if (p.isAbsolute(path)) return p.normalize(path);
    return p.normalize(p.join(dir, path));
  }

  static Future<DocuDartConfig> _loadFromYaml(String dir) async {
    // Try to load title/description from pubspec.yaml
    String? title;
    String? description;

    final pubspecFile = File(p.join(dir, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      try {
        final content = await pubspecFile.readAsString();
        final yaml = loadYaml(content) as YamlMap;
        title = yaml['name'] as String?;
        description = yaml['description'] as String?;
      } catch (_) {
        // Ignore errors reading pubspec
      }
    }

    // Try to load additional config from docudart.yaml
    BaseTheme theme = const DefaultTheme();
    String? docsDir;
    String? outputDir;
    String? assetsDir;

    final configYamlFile = File(p.join(dir, 'docudart.yaml'));
    if (configYamlFile.existsSync()) {
      try {
        final content = await configYamlFile.readAsString();
        final yaml = loadYaml(content) as YamlMap;

        // Override title/description if specified
        title = yaml['title'] as String? ?? title;
        description = yaml['description'] as String? ?? description;

        // Load directories
        docsDir = yaml['docsDir'] as String?;
        outputDir = yaml['outputDir'] as String?;
        assetsDir = yaml['assetsDir'] as String?;

        // Load custom theme
        final themeName = yaml['theme'] as String?;
        if (themeName != null && themeName != 'default') {
          final customTheme = await ThemeLoader.loadByName(
            themeName,
            p.join(dir, 'themes'),
          );
          if (customTheme != null) {
            theme = customTheme;
          } else {
            print(
                'Warning: Theme "$themeName" not found, using default theme');
          }
        }
      } catch (e) {
        print('Warning: Failed to load docudart.yaml: $e');
      }
    }

    // Return config with absolutized directory paths
    return DocuDartConfig(
      title: title,
      description: description,
      theme: theme,
      docsDir: p.normalize(p.join(dir, docsDir ?? 'docs')),
      outputDir: p.normalize(p.join(dir, outputDir ?? 'build/web')),
      assetsDir: p.normalize(p.join(dir, assetsDir ?? 'assets')),
    );
  }
}
