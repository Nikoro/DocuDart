import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'package:docudart/src/cli/errors.dart';
import 'package:docudart/src/config/config_evaluator.dart';
import 'package:docudart/src/config/docudart_config.dart';
import 'package:docudart/src/models/license.dart';
import 'package:docudart/src/models/license_parser.dart';
import 'package:docudart/src/models/pubspec.dart';
import 'package:docudart/src/models/repository.dart';
import 'package:docudart/src/theme/theme.dart';
import 'package:docudart/src/theme/theme_loader.dart';

/// Loads DocuDart configuration from config.dart or defaults.
abstract final class ConfigLoader {
  /// Load configuration from the current directory.
  ///
  /// The loader will:
  /// 1. Try to evaluate config.dart (Dart-based config)
  /// 2. Fall back to pubspec.yaml + docudart.yaml (YAML-based config)
  /// 3. Absolutize directory paths relative to the website directory
  static Future<Config> load([String? directory]) async {
    final dir = directory ?? Directory.current.path;

    // Try to evaluate config.dart first (the Dart-based config)
    final dartConfig = await ConfigEvaluator.evaluate(dir);
    if (dartConfig != null) {
      final Config(:docsDir, :outputDir, :assetsDir) = dartConfig;
      return dartConfig.copyWith(
        docsDir: _absolutize(dir, docsDir),
        outputDir: _absolutize(dir, outputDir),
        assetsDir: _absolutize(dir, assetsDir),
      );
    }

    // Fall back to YAML-based loading
    return _loadFromYaml(dir);
  }

  static String _absolutize(String dir, String path) {
    final resolved = p.isAbsolute(path)
        ? p.canonicalize(path)
        : p.canonicalize(p.join(dir, path));
    if (!p.isWithin(dir, resolved) && resolved != p.canonicalize(dir)) {
      throw DocuDartErrors.invalidConfig(
        'Directory path "$path" resolves outside the project root.',
      );
    }
    return resolved;
  }

  /// Load the parent project's pubspec.yaml from the website directory.
  ///
  /// Looks one directory up from [websiteDir] for the project root's
  /// pubspec.yaml. Falls back to the website's own pubspec if the
  /// parent doesn't exist.
  static Future<Pubspec> loadParentPubspec(String websiteDir) async {
    final parentDir = p.dirname(websiteDir);
    final parentPubspec = File(p.join(parentDir, 'pubspec.yaml'));

    if (parentPubspec.existsSync()) {
      return _parsePubspecFile(parentPubspec.path);
    }

    // Fallback: use the website's own pubspec
    final websitePubspec = File(p.join(websiteDir, 'pubspec.yaml'));
    if (websitePubspec.existsSync()) {
      return _parsePubspecFile(websitePubspec.path);
    }

    return const Pubspec(
      name: 'unknown',
      environment: Environment(sdk: 'any'),
    );
  }

  static Future<Pubspec> _parsePubspecFile(String path) async {
    try {
      final content = await File(path).readAsString();
      final yaml = loadYaml(content) as YamlMap;
      final env = yaml['environment'] as YamlMap?;

      return Pubspec(
        name: yaml['name'] as String? ?? 'unknown',
        version: yaml['version']?.toString(),
        description: yaml['description'] as String?,
        homepage: yaml['homepage'] as String?,
        repository: yaml['repository'] != null
            ? Repository(yaml['repository'] as String)
            : null,
        issueTracker: yaml['issue_tracker'] as String?,
        documentation: yaml['documentation'] as String?,
        publishTo: yaml['publish_to'] as String?,
        funding: switch (yaml['funding'] as YamlList?) {
          final list? => [for (final e in list) e.toString()],
          null => null,
        },
        topics: switch (yaml['topics'] as YamlList?) {
          final list? => [for (final e in list) e.toString()],
          null => null,
        },
        environment: Environment(
          sdk: env?['sdk']?.toString() ?? 'any',
          flutter: env?['flutter']?.toString(),
        ),
      );
    } catch (e) {
      CliPrinter.warning('Failed to parse pubspec.yaml: $e');
      return const Pubspec(
        name: 'unknown',
        environment: Environment(sdk: 'any'),
      );
    }
  }

  /// Load the parent project's LICENSE file from the website directory.
  ///
  /// Looks one directory up from [websiteDir] for LICENSE, LICENSE.md,
  /// LICENSE.txt, or LICENCE. Parses the content to extract license type,
  /// year, and copyright holder. Returns null if no license file is found.
  static Future<License?> loadParentLicense(String websiteDir) async {
    final parentDir = p.dirname(websiteDir);
    const filenames = ['LICENSE', 'LICENSE.md', 'LICENSE.txt', 'LICENCE'];

    for (final name in filenames) {
      final file = File(p.join(parentDir, name));
      if (file.existsSync()) {
        try {
          final content = await file.readAsString();
          return LicenseParser.parse(content);
        } catch (e) {
          CliPrinter.warning('Failed to parse LICENSE file: $e');
          return null;
        }
      }
    }

    return null;
  }

  /// Load the parent project's CHANGELOG.md from the website directory.
  ///
  /// Looks one directory up from [websiteDir] for the project root's
  /// CHANGELOG.md. Returns null if the file doesn't exist.
  static Future<String?> loadParentChangelog(String websiteDir) async {
    final parentDir = p.dirname(websiteDir);
    final changelogFile = File(p.join(parentDir, 'CHANGELOG.md'));

    if (!changelogFile.existsSync()) {
      return null;
    }

    try {
      return await changelogFile.readAsString();
    } catch (e) {
      CliPrinter.warning('Failed to read CHANGELOG.md: $e');
      return null;
    }
  }

  static Future<Config> _loadFromYaml(String dir) async {
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
      } catch (e) {
        CliPrinter.warning('Failed to parse pubspec.yaml: $e');
      }
    }

    // Try to load additional config from docudart.yaml
    Theme theme = Theme.classic();
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
            CliPrinter.warning(
              'Theme "$themeName" not found, using default theme',
            );
          }
        }
      } catch (e) {
        CliPrinter.warning('Failed to load docudart.yaml: $e');
      }
    }

    // Return config with absolutized directory paths
    return Config(
      title: title,
      description: description,
      theme: theme,
      docsDir: _absolutize(dir, docsDir ?? 'docs'),
      outputDir: _absolutize(dir, outputDir ?? 'build/web'),
      assetsDir: _absolutize(dir, assetsDir ?? 'assets'),
    );
  }
}
