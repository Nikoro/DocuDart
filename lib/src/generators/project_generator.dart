import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../cli/errors.dart';
import '../services/package_resolver.dart';
import 'project_templates.dart';

/// Default timeout for HTTP requests to external services.
const _httpTimeout = Duration(seconds: 5);

/// Template options for project initialization.
enum InitTemplate {
  /// Basic setup with config, landing page, and docs.
  defaultTemplate,

  /// Full template with all feature examples.
  full,
}

/// Generates a new DocuDart project structure inside a named subdirectory.
class ProjectGenerator {
  final _templates = ProjectTemplates();

  /// Generate project files in a [folderName]/ subdirectory of [directory].
  Future<void> generate({
    required String directory,
    required InitTemplate template,
    required String folderName,
  }) async {
    final websiteDir = p.join(directory, folderName);
    final dir = Directory(websiteDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    // Load info from the project root's pubspec.yaml
    final pubspecInfo = await _loadPubspecInfo(directory);
    final title = pubspecInfo['name'] ?? 'My Documentation';
    final description = pubspecInfo['description'] ?? 'Documentation site';
    // Check if CHANGELOG.md exists in the project root
    final hasChangelog = File(p.join(directory, 'CHANGELOG.md')).existsSync();
    // Check if the package exists on pub.dev
    CliPrinter.step('Checking pub.dev for package...');
    final pubDevUrl = await _resolvePubDevUrl(pubspecInfo['name']);

    // Resolve linting dependency from parent's analysis_options.yaml
    final lintDependency = await _resolveLintDependency(directory);

    // Create directory structure inside website/
    await _createDirectories(websiteDir);

    // Generate website/pubspec.yaml with path dependency to docudart
    await _generateWebsitePubspec(
      websiteDir,
      title,
      lintDependency: lintDependency,
    );

    // Generate wrapper components (header, footer, sidebar)
    await _templates.generateComponents(websiteDir, title);

    // Generate changelog page if CHANGELOG.md exists in the parent project
    if (hasChangelog) {
      await _templates.generateChangelogPage(websiteDir);
    }

    // Generate config.dart
    await _templates.generateConfig(
      websiteDir,
      title,
      description,
      pubDevUrl,
      hasChangelog: hasChangelog,
    );

    // Generate labels.dart
    await _templates.generateLabels(websiteDir);

    // Generate landing page
    await _templates.generateLandingPage(websiteDir, title, description);

    // Generate documentation files (look for README.md in project root)
    await _templates.generateDocs(
      websiteDir,
      directory,
      template == InitTemplate.full,
    );

    // Generate default favicon files
    await _generateFavicons(websiteDir);

    // Generate default logo
    await _generateLogo(websiteDir);

    // Generate README.md
    await _templates.generateReadme(websiteDir, title);

    // Update .gitignore at project root
    await _updateGitignore(directory, folderName);

    // Run dart pub get in website/
    CliPrinter.step('Installing dependencies...');
    final result = await Process.run('dart', [
      'pub',
      'get',
    ], workingDirectory: websiteDir);
    if (result.exitCode != 0) {
      CliPrinter.warning('dart pub get failed: ${result.stderr}');
    }

    // Format generated Dart files
    final formatResult = await Process.run('dart', [
      'format',
      '.',
    ], workingDirectory: websiteDir);
    if (formatResult.exitCode != 0) {
      CliPrinter.warning('dart format failed: ${formatResult.stderr}');
    }

    CliPrinter.success('Created project structure:');
    CliPrinter.line('  $folderName/');
    CliPrinter.line('    pubspec.yaml');
    CliPrinter.line('    config.dart');
    CliPrinter.line('    labels.dart');
    CliPrinter.line('    README.md');
    CliPrinter.line('    docs/');
    CliPrinter.line('    pages/');
    CliPrinter.line('      landing_page.dart');
    CliPrinter.line('    components/');
    CliPrinter.line('      header.dart');
    CliPrinter.line('      footer.dart');
    CliPrinter.line('      button.dart');
    CliPrinter.line('      sidebar.dart');
    CliPrinter.line('    assets/');
    CliPrinter.line('      light/');
    CliPrinter.line('        logo/');
    CliPrinter.line('      dark/');
    CliPrinter.line('        logo/');
    CliPrinter.line('      favicon/');
    CliPrinter.line('    themes/');
  }

  Future<Map<String, String?>> _loadPubspecInfo(String directory) async {
    final pubspecFile = File(p.join(directory, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return {};
    }

    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      return {
        'name': yaml['name'] as String?,
        'description': yaml['description'] as String?,
        'repository': yaml['repository'] as String?,
      };
    } catch (e) {
      CliPrinter.warning('Failed to read pubspec.yaml: $e');
      return {};
    }
  }

  /// Resolve a linting package from the parent project's pubspec.yaml.
  ///
  /// Checks for `lints` or `flutter_lints` in dev_dependencies/dependencies
  /// and returns the name and version if found.
  Future<Map<String, String>?> _resolveLintDependency(String directory) async {
    final pubspecFile = File(p.join(directory, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return null;

    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content);
      if (yaml is! YamlMap) return null;

      const lintPackages = ['lints', 'flutter_lints'];

      for (final section in ['dev_dependencies', 'dependencies']) {
        final deps = yaml[section];
        if (deps is! YamlMap) continue;
        for (final package in lintPackages) {
          if (deps.containsKey(package)) {
            final version = deps[package];
            if (version is String) {
              return {'name': package, 'version': version};
            }
          }
        }
      }

      return null;
    } catch (e) {
      CliPrinter.warning('Failed to resolve lint dependency: $e');
      return null;
    }
  }

  /// Check if a package exists on pub.dev by making a HEAD request.
  /// Returns the specific package URL if it exists, or the generic pub.dev URL.
  Future<String> _resolvePubDevUrl(String? packageName) async {
    if (packageName == null || packageName.isEmpty) {
      return 'https://pub.dev';
    }

    try {
      final client = HttpClient();
      client.connectionTimeout = _httpTimeout;
      final request = await client.headUrl(
        Uri.parse('https://pub.dev/packages/$packageName'),
      );
      final response = await request.close();
      client.close();

      if (response.statusCode == 200) {
        return 'https://pub.dev/packages/$packageName';
      }
      return 'https://pub.dev';
    } catch (_) {
      // No internet, timeout, DNS failure, etc.
      return 'https://pub.dev';
    }
  }

  Future<void> _createDirectories(String websiteDir) async {
    final dirs = ['docs', 'pages', 'components', 'assets', 'themes'];
    for (final dir in dirs) {
      final path = p.join(websiteDir, dir);
      await Directory(path).create(recursive: true);
    }
  }

  Future<void> _generateFavicons(String websiteDir) async {
    final docudartRoot = await PackageResolver.resolveDocudartPath();
    final sourceDir = Directory(
      p.join(docudartRoot, 'lib', 'src', 'assets', 'favicon'),
    );
    if (!sourceDir.existsSync()) return;

    final targetDir = Directory(p.join(websiteDir, 'assets', 'favicon'));
    await targetDir.create(recursive: true);

    await for (final entity in sourceDir.list()) {
      if (entity is File) {
        final targetPath = p.join(targetDir.path, p.basename(entity.path));
        if (!File(targetPath).existsSync()) {
          await entity.copy(targetPath);
        }
      }
    }
  }

  Future<void> _generateLogo(String websiteDir) async {
    final docudartRoot = await PackageResolver.resolveDocudartPath();
    final sourceDir = Directory(
      p.join(docudartRoot, 'lib', 'src', 'assets', 'logo'),
    );
    if (!sourceDir.existsSync()) return;

    for (final variant in ['light', 'dark']) {
      final variantSource = Directory(p.join(sourceDir.path, variant));
      if (!variantSource.existsSync()) continue;

      final targetDir = Directory(
        p.join(websiteDir, 'assets', variant, 'logo'),
      );
      await targetDir.create(recursive: true);

      await for (final entity in variantSource.list()) {
        if (entity is File) {
          final targetPath = p.join(targetDir.path, p.basename(entity.path));
          if (!File(targetPath).existsSync()) {
            await entity.copy(targetPath);
          }
        }
      }
    }
  }

  Future<void> _generateWebsitePubspec(
    String websiteDir,
    String title, {
    Map<String, String>? lintDependency,
  }) async {
    final docudartPath = await PackageResolver.relativePathTo(websiteDir);
    final packageName = _sanitizePackageName(title);

    final devDeps = lintDependency != null
        ? "\ndev_dependencies:\n  ${lintDependency['name']}: ${lintDependency['version']}\n"
        : '';

    final pubspec =
        '''
name: ${packageName}_docs
description: Documentation site powered by DocuDart
publish_to: none

environment:
  sdk: ^3.10.0

dependencies:
  docudart:
    path: $docudartPath
$devDeps''';

    await File(p.join(websiteDir, 'pubspec.yaml')).writeAsString(pubspec);
  }

  String _sanitizePackageName(String name) {
    // Convert to lowercase, replace non-alphanumeric with underscore
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  Future<void> _updateGitignore(String projectDir, String folderName) async {
    final gitignoreFile = File(p.join(projectDir, '.gitignore'));
    final content = gitignoreFile.existsSync()
        ? await gitignoreFile.readAsString()
        : '';

    final additions = <String>[];

    // Add DocuDart-specific entries
    if (!content.contains('$folderName/.dart_tool/')) {
      additions.add('$folderName/.dart_tool/');
    }
    if (!content.contains('$folderName/build/')) {
      additions.add('$folderName/build/');
    }

    if (additions.isNotEmpty) {
      final newContent =
          '${content.trimRight()}\n\n# DocuDart\n${additions.join('\n')}\n';
      await gitignoreFile.writeAsString(newContent);
    }
  }
}
