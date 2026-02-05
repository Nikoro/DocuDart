import 'dart:io';

import 'package:yaml/yaml.dart';

import 'docudart_config.dart';

/// Loads DocuDart configuration from config.dart or defaults.
class ConfigLoader {
  /// Load configuration from the current directory.
  ///
  /// For now, this creates a default config. In the future, it will
  /// dynamically load and execute config.dart.
  static Future<DocuDartConfig> load([String? directory]) async {
    final dir = directory ?? Directory.current.path;

    // Try to load title/description from pubspec.yaml
    String? title;
    String? description;

    final pubspecFile = File('$dir/pubspec.yaml');
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

    // Return default config with pubspec values
    // TODO: Implement dynamic loading of config.dart
    return DocuDartConfig(
      title: title,
      description: description,
    );
  }
}
