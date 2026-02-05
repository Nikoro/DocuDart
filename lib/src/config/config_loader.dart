import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'docudart_config.dart';
import '../theme/base_theme.dart';
import '../theme/default_theme.dart';
import '../theme/theme_loader.dart';

/// Loads DocuDart configuration from config.dart or defaults.
class ConfigLoader {
  /// Load configuration from the current directory.
  ///
  /// The loader will:
  /// 1. Read pubspec.yaml for title/description
  /// 2. Look for docudart.yaml for additional configuration
  /// 3. Try to load a custom theme if specified
  /// 4. Fall back to defaults for any missing values
  static Future<DocuDartConfig> load([String? directory]) async {
    final dir = directory ?? Directory.current.path;

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
            print('Warning: Theme "$themeName" not found, using default theme');
          }
        }
      } catch (e) {
        print('Warning: Failed to load docudart.yaml: $e');
      }
    }

    // Return config with loaded values
    return DocuDartConfig(
      title: title,
      description: description,
      theme: theme,
      docsDir: docsDir ?? 'docs',
      outputDir: outputDir ?? 'build/web',
      assetsDir: assetsDir ?? 'assets',
    );
  }
}
