import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'package_resolver.dart';
import 'readme_parser.dart';

/// Template options for project initialization.
enum InitTemplate {
  /// Basic setup with config, landing page, and docs.
  defaultTemplate,

  /// Full template with all feature examples.
  full,
}

/// Generates a new DocuDart project structure inside a website/ subdirectory.
class ProjectGenerator {
  /// Generate project files in a website/ subdirectory of [directory].
  Future<void> generate({
    required String directory,
    required InitTemplate template,
  }) async {
    final websiteDir = p.join(directory, 'website');
    final dir = Directory(websiteDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    // Load info from the project root's pubspec.yaml
    final pubspecInfo = await _loadPubspecInfo(directory);
    final title = pubspecInfo['name'] ?? 'My Documentation';
    final description = pubspecInfo['description'] ?? 'Documentation site';
    // Check if the package exists on pub.dev
    print('Checking pub.dev for package...');
    final pubDevUrl = await _resolvePubDevUrl(pubspecInfo['name']);

    // Resolve linting dependency from parent's analysis_options.yaml
    final lintDependency = await _resolveLintDependency(directory);

    // Create directory structure inside website/
    await _createDirectories(websiteDir);

    // Generate website/pubspec.yaml with path dependency to docudart
    await _generateWebsitePubspec(websiteDir, title, lintDependency: lintDependency);

    // Generate wrapper components (header, footer, sidebar)
    await _generateComponents(websiteDir, title);

    // Generate config.dart
    await _generateConfig(
      websiteDir, title, description, template, pubDevUrl,
    );

    // Generate icons.dart
    await _generateIcons(websiteDir);

    // Generate labels.dart
    await _generateLabels(websiteDir);

    // Generate landing page
    await _generateLandingPage(websiteDir, title, description);

    // Generate documentation files (look for README.md in project root)
    await _generateDocs(websiteDir, directory, template);

    // Generate default favicon files
    await _generateFavicons(websiteDir);

    // Generate README.md
    await _generateReadme(websiteDir, title);

    // Update .gitignore at project root
    await _updateGitignore(directory);

    // Run dart pub get in website/
    print('Installing dependencies...');
    final result = await Process.run('dart', [
      'pub',
      'get',
    ], workingDirectory: websiteDir);
    if (result.exitCode != 0) {
      print('Warning: dart pub get failed: ${result.stderr}');
    }

    // Format generated Dart files
    await Process.run('dart', ['format', '.'], workingDirectory: websiteDir);

    print('Created project structure:');
    print('  website/');
    print('    pubspec.yaml');
    print('    config.dart');
    print('    icons.dart');
    print('    labels.dart');
    print('    README.md');
    print('    docs/');
    print('    pages/');
    print('    components/');
    print('      header.dart');
    print('      footer.dart');
    print('      sidebar.dart');
    print('    assets/');
    print('      favicon/');
    print('    themes/');
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
    } catch (_) {
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
    } catch (_) {
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
      client.connectionTimeout = const Duration(seconds: 5);
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

      // Add .gitkeep to empty directories (not docs, pages, or components)
      if (dir != 'docs' && dir != 'pages' && dir != 'components') {
        await File(p.join(path, '.gitkeep')).writeAsString('');
      }
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
        await entity.copy(targetPath);
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

  /// Generate wrapper components in website/components/.
  Future<void> _generateComponents(String websiteDir, String title) async {
    final componentsDir = p.join(websiteDir, 'components');

    // Header component
    await File(p.join(componentsDir, 'header.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [DefaultHeader] provides a standard header with title, nav links,
/// and optional leading/trailing component slots.
class Header extends StatelessComponent {
  const Header({required this.title, this.navLinks, this.trailing, super.key});

  final String title;
  final List<NavLink>? navLinks;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return DefaultHeader(
      title: title,
      navLinks: navLinks,
      trailing: trailing,
    );
  }
}
''');

    // Footer component
    await File(p.join(componentsDir, 'footer.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
/// The [DefaultFooter] provides a simple centered text footer
/// with optional leading/trailing slots.
class Footer extends StatelessComponent {
  const Footer({required this.text, this.leading, this.trailing, super.key});

  final String text;
  final Component? leading;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return DefaultFooter(text: text, leading: leading, trailing: trailing);
  }
}
''');

    // Sidebar component
    await File(p.join(componentsDir, 'sidebar.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// Site sidebar component.
///
/// Customize this component to change the sidebar layout.
/// The [DefaultSidebar] renders a navigation tree from the docs structure.
/// The [items] are auto-generated from your docs/ folder.
class Sidebar extends StatelessComponent {
  final List<GeneratedSidebarItem> items;

  const Sidebar({required this.items, super.key});

  @override
  Component build(BuildContext context) {
    return DefaultSidebar(items: items);
  }
}
''');
  }

  Future<void> _generateConfig(
    String websiteDir,
    String title,
    String description,
    InitTemplate template,
    String pubDevUrl,
  ) async {
    final configContent =
        "import 'package:docudart/docudart.dart';\n"
        "import 'components/header.dart';\n"
        "import 'components/footer.dart';\n"
        "import 'components/sidebar.dart';\n"
        "import 'icons.dart';\n"
        "import 'labels.dart';\n"
        "import 'pages/landing_page.dart';\n"
        '\n'
        'final init = setup(\n'
        '  (project) => Config(\n'
        '    title: project.pubspec.name,\n'
        '    description: project.pubspec.description,\n'
        '    themeMode: ThemeMode.system,\n'
        '    theme: DefaultTheme(),\n'
        "    // Home page component. Set to null to redirect '/' to '/docs'.\n"
        '    home: () => project.pubspec.let(\n'
        '      (pubspec) =>\n'
        '          LandingPage(title: pubspec.name, description: pubspec.description),\n'
        '    ),\n'
        '    // Header, footer, and sidebar are components.\n'
        '    // Set to null to hide any section.\n'
        '    header: () => Header(\n'
        '      title: project.pubspec.name,\n'
        '      navLinks: [\n'
        "        .path('/docs', label: Labels.docs, leading: Icons.docs),\n"
        "        ?project.pubspec.repository.let(\n"
        "          (repo) => .url(repo.link, label: repo.label, leading: repo.icon, trailing: Icons.openInNew),\n"
        "        ),\n"
        "        .url('$pubDevUrl', label: Labels.pubDev, leading: Icons.pubDev, trailing: Icons.openInNew),\n"
        '      ],\n'
        '      trailing: ThemeToggle(light: Icons.lightMode, dark: Icons.darkMode),\n'
        '    ),\n'
        '    footer: () => project.pubspec.let((pubspec) {\n'
        '      final year = DateTime.now().year;\n'
        '      return Footer(\n'
        r"        text: '© $year ${pubspec.name}',"
        '\n'
        '        leading: pubspec.topics.let(\n'
        '          (topics) => Topics(\n'
        '            title: Labels.topics,\n'
        '            links: [\n'
        "              for (final topic in topics)\n"
        r"                .url('https://pub.dev/packages?q=topic%3A$topic', label: '#$topic'),"
        '\n'
        '            ],\n'
        '          ),\n'
        '        ),\n'
        '        trailing: Socials(\n'
        '          links: [\n'
        "            .url('https://youtube.com', leading: Icons.youtube),\n"
        "            .url('https://discord.com', leading: Icons.discord),\n"
        "            .url('https://x.com', leading: Icons.xTwitter),\n"
        '          ],\n'
        '        ),\n'
        '      );\n'
        '    }),\n'
        '    sidebar: () => Sidebar(items: project.docs),\n'
        '  ),\n'
        ');\n';

    await File(p.join(websiteDir, 'config.dart')).writeAsString(configContent);
  }

  Future<void> _generateIcons(String websiteDir) async {
    await File(p.join(websiteDir, 'icons.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// Icon constants for use in navigation links and components.
///
/// Each icon is an inline SVG rendered via [RawText].
/// Add your own icons here or use any Jaspr [Component] as an icon.
abstract class Icons {
  Icons._();

  // --- Code Hosting ---

  static const bitbucket = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M86.2 96C84.1 96 82 96.4 80.1 97.1C78.2 97.8 76.4 99 74.9 100.5C73.4 102 72.2 103.7 71.4 105.6C70.6 107.5 70.1 109.6 70.1 111.7C70.1 112.6 70.2 113.6 70.3 114.5L138.1 526.7C138.9 531.8 141.5 536.4 145.4 539.7C149.3 543 154.2 544.9 159.4 544.9L485.1 544.9C488.9 545 492.6 543.6 495.6 541.2C498.6 538.8 500.5 535.3 501.1 531.5L569 114.7C569.7 110.5 568.7 106.3 566.2 102.8C563.7 99.3 560 97.1 555.8 96.4C554.9 96.3 553.9 96.2 553 96.2L86.2 96zM372.1 393.8L268.1 393.8L240 246.8L397.3 246.8L372.1 393.8z"/></svg>',
  );

  static const github = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M237.9 461.4C237.9 463.4 235.6 465 232.7 465C229.4 465.3 227.1 463.7 227.1 461.4C227.1 459.4 229.4 457.8 232.3 457.8C235.3 457.5 237.9 459.1 237.9 461.4zM206.8 456.9C206.1 458.9 208.1 461.2 211.1 461.8C213.7 462.8 216.7 461.8 217.3 459.8C217.9 457.8 216 455.5 213 454.6C210.4 453.9 207.5 454.9 206.8 456.9zM251 455.2C248.1 455.9 246.1 457.8 246.4 460.1C246.7 462.1 249.3 463.4 252.3 462.7C255.2 462 257.2 460.1 256.9 458.1C256.6 456.2 253.9 454.9 251 455.2zM316.8 72C178.1 72 72 177.3 72 316C72 426.9 141.8 521.8 241.5 555.2C254.3 557.5 258.8 549.6 258.8 543.1C258.8 536.9 258.5 502.7 258.5 481.7C258.5 481.7 188.5 496.7 173.8 451.9C173.8 451.9 162.4 422.8 146 415.3C146 415.3 123.1 399.6 147.6 399.9C147.6 399.9 172.5 401.9 186.2 425.7C208.1 464.3 244.8 453.2 259.1 446.6C261.4 430.6 267.9 419.5 275.1 412.9C219.2 406.7 162.8 398.6 162.8 302.4C162.8 274.9 170.4 261.1 186.4 243.5C183.8 237 175.3 210.2 189 175.6C209.9 169.1 258 202.6 258 202.6C278 197 299.5 194.1 320.8 194.1C342.1 194.1 363.6 197 383.6 202.6C383.6 202.6 431.7 169 452.6 175.6C466.3 210.3 457.8 237 455.2 243.5C471.2 261.2 481 275 481 302.4C481 398.9 422.1 406.6 366.2 412.9C375.4 420.8 383.2 435.8 383.2 459.3C383.2 493 382.9 534.7 382.9 542.9C382.9 549.4 387.5 557.3 400.2 555C500.2 521.8 568 426.9 568 316C568 177.3 455.5 72 316.8 72zM169.2 416.9C167.9 417.9 168.2 420.2 169.9 422.1C171.5 423.7 173.8 424.4 175.1 423.1C176.4 422.1 176.1 419.8 174.4 417.9C172.8 416.3 170.5 415.6 169.2 416.9zM158.4 408.8C157.7 410.1 158.7 411.7 160.7 412.7C162.3 413.7 164.3 413.4 165 412C165.7 410.7 164.7 409.1 162.7 408.1C160.7 407.5 159.1 407.8 158.4 408.8zM190.8 444.4C189.2 445.7 189.8 448.7 192.1 450.6C194.4 452.9 197.3 453.2 198.6 451.6C199.9 450.3 199.3 447.3 197.3 445.4C195.1 443.1 192.1 442.8 190.8 444.4zM179.4 429.7C177.8 430.7 177.8 433.3 179.4 435.6C181 437.9 183.7 438.9 185 437.9C186.6 436.6 186.6 434 185 431.7C183.6 429.4 181 428.4 179.4 429.7z"/></svg>',
  );

  static const gitlab = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M568 268.6L567.3 266.8L497.6 85C496.2 81.4 493.7 78.4 490.4 76.4C488 74.8 485.3 73.9 482.4 73.6C479.5 73.3 476.7 73.7 474 74.7C471.3 75.7 468.9 77.4 466.9 79.5C465 81.6 463.6 84.2 462.8 86.9L415.8 230.9L225.3 230.9L178.2 86.9C177.4 84.1 176 81.6 174.1 79.5C172.1 77.4 169.7 75.8 167 74.7C164.4 73.7 161.5 73.3 158.6 73.6C155.7 73.9 153 74.8 150.6 76.4C147.4 78.4 144.8 81.5 143.4 85L73.8 266.8L73 268.6C63 294.8 61.7 323.6 69.5 350.6C77.2 377.5 93.5 401.3 115.9 418.2L116.2 418.4L116.8 418.8L222.8 498.3C261.3 527.4 289.5 548.6 307.4 562.2C311.1 564.1 315.7 566.5 320.4 566.5C325.1 566.5 329.7 564.1 333.4 562.2C351.3 548.7 379.5 527.3 418 498.3L524.7 418.4L525 418.1C547.4 401.2 563.7 377.5 570.6 350.6C579.2 323.6 578 294.8 568 268.6z"/></svg>',
  );

  // --- Social Media ---

  static const discord = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M524.5 133.8C524.3 133.5 524.1 133.2 523.7 133.1C485.6 115.6 445.3 103.1 404 96C403.6 95.9 403.2 96 402.9 96.1C402.6 96.2 402.3 96.5 402.1 96.9C396.6 106.8 391.6 117.1 387.2 127.5C342.6 120.7 297.3 120.7 252.8 127.5C248.3 117 243.3 106.8 237.7 96.9C237.5 96.6 237.2 96.3 236.9 96.1C236.6 95.9 236.2 95.9 235.8 95.9C194.5 103 154.2 115.5 116.1 133C115.8 133.1 115.5 133.4 115.3 133.7C39.1 247.5 18.2 358.6 28.4 468.2C28.4 468.5 28.5 468.7 28.6 469C28.7 469.3 28.9 469.4 29.1 469.6C73.5 502.5 123.1 527.6 175.9 543.8C176.3 543.9 176.7 543.9 177 543.8C177.3 543.7 177.7 543.4 177.9 543.1C189.2 527.7 199.3 511.3 207.9 494.3C208 494.1 208.1 493.8 208.1 493.5C208.1 493.2 208.1 493 208 492.7C207.9 492.4 207.8 492.2 207.6 492.1C207.4 492 207.2 491.8 206.9 491.7C191.1 485.6 175.7 478.3 161 469.8C160.7 469.6 160.5 469.4 160.3 469.2C160.1 469 160 468.6 160 468.3C160 468 160 467.7 160.2 467.4C160.4 467.1 160.5 466.9 160.8 466.7C163.9 464.4 167 462 169.9 459.6C170.2 459.4 170.5 459.2 170.8 459.2C171.1 459.2 171.5 459.2 171.8 459.3C268 503.2 372.2 503.2 467.3 459.3C467.6 459.2 468 459.1 468.3 459.1C468.6 459.1 469 459.3 469.2 459.5C472.1 461.9 475.2 464.4 478.3 466.7C478.5 466.9 478.7 467.1 478.9 467.4C479.1 467.7 479.1 468 479.1 468.3C479.1 468.6 479 468.9 478.8 469.2C478.6 469.5 478.4 469.7 478.2 469.8C463.5 478.4 448.2 485.7 432.3 491.6C432.1 491.7 431.8 491.8 431.6 492C431.4 492.2 431.3 492.4 431.2 492.7C431.1 493 431.1 493.2 431.1 493.5C431.1 493.8 431.2 494 431.3 494.3C440.1 511.3 450.1 527.6 461.3 543.1C461.5 543.4 461.9 543.7 462.2 543.8C462.5 543.9 463 543.9 463.3 543.8C516.2 527.6 565.9 502.5 610.4 469.6C610.6 469.4 610.8 469.2 610.9 469C611 468.8 611.1 468.5 611.1 468.2C623.4 341.4 590.6 231.3 524.2 133.7zM222.5 401.5C193.5 401.5 169.7 374.9 169.7 342.3C169.7 309.7 193.1 283.1 222.5 283.1C252.2 283.1 275.8 309.9 275.3 342.3C275.3 375 251.9 401.5 222.5 401.5zM417.9 401.5C388.9 401.5 365.1 374.9 365.1 342.3C365.1 309.7 388.5 283.1 417.9 283.1C447.6 283.1 471.2 309.9 470.7 342.3C470.7 375 447.5 401.5 417.9 401.5z"/></svg>',
  );

  static const instagram = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M320.3 205C256.8 204.8 205.2 256.2 205 319.7C204.8 383.2 256.2 434.8 319.7 435C383.2 435.2 434.8 383.8 435 320.3C435.2 256.8 383.8 205.2 320.3 205zM319.7 245.4C360.9 245.2 394.4 278.5 394.6 319.7C394.8 360.9 361.5 394.4 320.3 394.6C279.1 394.8 245.6 361.5 245.4 320.3C245.2 279.1 278.5 245.6 319.7 245.4zM413.1 200.3C413.1 185.5 425.1 173.5 439.9 173.5C454.7 173.5 466.7 185.5 466.7 200.3C466.7 215.1 454.7 227.1 439.9 227.1C425.1 227.1 413.1 215.1 413.1 200.3zM542.8 227.5C541.1 191.6 532.9 159.8 506.6 133.6C480.4 107.4 448.6 99.2 412.7 97.4C375.7 95.3 264.8 95.3 227.8 97.4C192 99.1 160.2 107.3 133.9 133.5C107.6 159.7 99.5 191.5 97.7 227.4C95.6 264.4 95.6 375.3 97.7 412.3C99.4 448.2 107.6 480 133.9 506.2C160.2 532.4 191.9 540.6 227.8 542.4C264.8 544.5 375.7 544.5 412.7 542.4C448.6 540.7 480.4 532.5 506.6 506.2C532.8 480 541 448.2 542.8 412.3C544.9 375.3 544.9 264.5 542.8 227.5zM495 452C487.2 471.6 472.1 486.7 452.4 494.6C422.9 506.3 352.9 503.6 320.3 503.6C287.7 503.6 217.6 506.2 188.2 494.6C168.6 486.8 153.5 471.7 145.6 452C133.9 422.5 136.6 352.5 136.6 319.9C136.6 287.3 134 217.2 145.6 187.8C153.4 168.2 168.5 153.1 188.2 145.2C217.7 133.5 287.7 136.2 320.3 136.2C352.9 136.2 423 133.6 452.4 145.2C472 153 487.1 168.1 495 187.8C506.7 217.3 504 287.3 504 319.9C504 352.5 506.7 422.6 495 452z"/></svg>',
  );

  static const linkedin = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M512 96L127.9 96C110.3 96 96 110.5 96 128.3L96 511.7C96 529.5 110.3 544 127.9 544L512 544C529.6 544 544 529.5 544 511.7L544 128.3C544 110.5 529.6 96 512 96zM231.4 480L165 480L165 266.2L231.5 266.2L231.5 480L231.4 480zM198.2 160C219.5 160 236.7 177.2 236.7 198.5C236.7 219.8 219.5 237 198.2 237C176.9 237 159.7 219.8 159.7 198.5C159.7 177.2 176.9 160 198.2 160zM480.3 480L413.9 480L413.9 376C413.9 351.2 413.4 319.3 379.4 319.3C344.8 319.3 339.5 346.3 339.5 374.2L339.5 480L273.1 480L273.1 266.2L336.8 266.2L336.8 295.4L337.7 295.4C346.6 278.6 368.3 260.9 400.6 260.9C467.8 260.9 480.3 305.2 480.3 362.8L480.3 480z"/></svg>',
  );

  static const medium = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M180.5 74.3C280 74.3 360.7 155.6 360.7 256C360.7 356.4 280 437.7 180.5 437.7C81 437.7 0 356.4 0 256C0 155.6 81 74.3 180.5 74.3zM468.8 84.9C518.6 84.9 558.8 161.3 558.8 256L558.8 256C558.8 350.5 518.6 427 468.8 427C419 427 378.6 350.5 378.6 256C378.6 161.5 418.9 84.9 468.8 84.9zM608.3 102.7C625.8 102.7 640 171.3 640 256C640 340.5 625.8 409.3 608.3 409.3C590.8 409.3 576.6 340.7 576.6 256C576.6 171.3 590.8 102.7 608.3 102.7z"/></svg>',
  );

  static const reddit = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M64 320C64 178.6 178.6 64 320 64C461.4 64 576 178.6 576 320C576 461.4 461.4 576 320 576L101.1 576C87.4 576 80.6 559.5 90.2 549.8L139 501C92.7 454.7 64 390.7 64 320zM413.6 217.6C437.2 217.6 456.3 198.5 456.3 174.9C456.3 151.3 437.2 132.2 413.6 132.2C393 132.2 375.8 146.8 371.8 166.2C337.3 169.9 310.4 199.2 310.4 234.6L310.4 234.8C272.9 236.4 238.6 247.1 211.4 263.9C201.3 256.1 188.6 251.4 174.9 251.4C141.9 251.4 115.1 278.2 115.1 311.2C115.1 335.2 129.2 355.8 149.5 365.3C151.5 434.7 227.1 490.5 320.1 490.5C413.1 490.5 488.8 434.6 490.7 365.2C510.9 355.6 524.8 335 524.8 311.2C524.8 278.2 498 251.4 465 251.4C451.3 251.4 438.7 256 428.6 263.8C401.2 246.8 366.5 236.1 328.6 234.7L328.6 234.5C328.6 209.1 347.5 188 372 184.6C376.4 203.4 393.3 217.4 413.5 217.4L413.6 217.6zM241.1 310.9C257.8 310.9 270.6 328.5 269.6 350.2C268.6 371.9 256.1 379.8 239.3 379.8C222.5 379.8 207.9 371 208.9 349.3C209.9 327.6 224.3 311 241 311L241.1 310.9zM431.2 349.2C432.2 370.9 417.5 379.7 400.8 379.7C384.1 379.7 371.5 371.8 370.5 350.1C369.5 328.4 382.3 310.8 399 310.8C415.7 310.8 430.2 327.4 431.1 349.1L431.2 349.2zM383.1 405.9C372.8 430.5 348.5 447.8 320.1 447.8C291.7 447.8 267.4 430.5 257.1 405.9C255.9 403 257.9 399.7 261 399.4C279.4 397.5 299.3 396.5 320.1 396.5C340.9 396.5 360.8 397.5 379.2 399.4C382.3 399.7 384.3 403 383.1 405.9z"/></svg>',
  );

  static const slack = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M190.1 379.1C190.1 405 168.9 426.2 143 426.2C117.1 426.2 96 405 96 379.1C96 353.2 117.2 332 143.1 332L190.2 332L190.2 379.1zM213.8 379.1C213.8 353.2 235 332 260.9 332C286.8 332 308 353.2 308 379.1L308 496.9C308 522.8 286.8 544 260.9 544C235 544 213.8 522.8 213.8 496.9L213.8 379.1zM260.9 190.1C235 190.1 213.8 168.9 213.8 143C213.8 117.1 235 96 260.9 96C286.8 96 308 117.2 308 143.1L308 190.2L260.9 190.2zM260.9 213.8C286.8 213.8 308 235 308 260.9C308 286.8 286.8 308 260.9 308L143.1 308C117.2 308 96 286.8 96 260.9C96 235 117.2 213.8 143.1 213.8L260.9 213.8zM449.9 260.9C449.9 235 471.1 213.8 497 213.8C522.9 213.8 544 235 544 260.9C544 286.8 522.8 308 496.9 308L449.8 308L449.8 260.9zM426.2 260.9C426.2 286.8 405 308 379.1 308C353.2 308 332 286.8 332 260.9L332 143.1C332 117.2 353.2 96 379.1 96C405 96 426.2 117.2 426.2 143.1L426.2 260.9zM379.1 449.9C405 449.9 426.2 471.1 426.2 497C426.2 522.9 405 544 379.1 544C353.2 544 332 522.8 332 496.9L332 449.8L379.1 449.8zM379.1 426.2C353.2 426.2 332 405 332 379.1C332 353.2 353.2 332 379.1 332L496.9 332C522.8 332 544 353.2 544 379.1C544 405 522.8 426.2 496.9 426.2L379.1 426.2z"/></svg>',
  );

  static const tiktok = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M320.3 205C256.8 204.8 205.2 256.2 205 319.7C204.8 383.2 256.2 434.8 319.7 435C383.2 435.2 434.8 383.8 435 320.3C435.2 256.8 383.8 205.2 320.3 205zM319.7 245.4C360.9 245.2 394.4 278.5 394.6 319.7C394.8 360.9 361.5 394.4 320.3 394.6C279.1 394.8 245.6 361.5 245.4 320.3C245.2 279.1 278.5 245.6 319.7 245.4zM413.1 200.3C413.1 185.5 425.1 173.5 439.9 173.5C454.7 173.5 466.7 185.5 466.7 200.3C466.7 215.1 454.7 227.1 439.9 227.1C425.1 227.1 413.1 215.1 413.1 200.3zM542.8 227.5C541.1 191.6 532.9 159.8 506.6 133.6C480.4 107.4 448.6 99.2 412.7 97.4C375.7 95.3 264.8 95.3 227.8 97.4C192 99.1 160.2 107.3 133.9 133.5C107.6 159.7 99.5 191.5 97.7 227.4C95.6 264.4 95.6 375.3 97.7 412.3C99.4 448.2 107.6 480 133.9 506.2C160.2 532.4 191.9 540.6 227.8 542.4C264.8 544.5 375.7 544.5 412.7 542.4C448.6 540.7 480.4 532.5 506.6 506.2C532.8 480 541 448.2 542.8 412.3C544.9 375.3 544.9 264.5 542.8 227.5zM495 452C487.2 471.6 472.1 486.7 452.4 494.6C422.9 506.3 352.9 503.6 320.3 503.6C287.7 503.6 217.6 506.2 188.2 494.6C168.6 486.8 153.5 471.7 145.6 452C133.9 422.5 136.6 352.5 136.6 319.9C136.6 287.3 134 217.2 145.6 187.8C153.4 168.2 168.5 153.1 188.2 145.2C217.7 133.5 287.7 136.2 320.3 136.2C352.9 136.2 423 133.6 452.4 145.2C472 153 487.1 168.1 495 187.8C506.7 217.3 504 287.3 504 319.9C504 352.5 506.7 422.6 495 452z"/></svg>',
  );

  static const xTwitter = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M453.2 112L523.8 112L369.6 288.2L551 528L409 528L297.7 382.6L170.5 528L99.8 528L264.7 339.5L90.8 112L236.4 112L336.9 244.9L453.2 112zM428.4 485.8L467.5 485.8L215.1 152L173.1 152L428.4 485.8z"/></svg>',
  );

  static const youtube = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M581.7 188.1C575.5 164.4 556.9 145.8 533.4 139.5C490.9 128 320.1 128 320.1 128C320.1 128 149.3 128 106.7 139.5C83.2 145.8 64.7 164.4 58.4 188.1C47 231 47 320.4 47 320.4C47 320.4 47 409.8 58.4 452.7C64.7 476.3 83.2 494.2 106.7 500.5C149.3 512 320.1 512 320.1 512C320.1 512 490.9 512 533.5 500.5C557 494.2 575.5 476.3 581.8 452.7C593.2 409.8 593.2 320.4 593.2 320.4C593.2 320.4 593.2 231 581.8 188.1zM264.2 401.6L264.2 239.2L406.9 320.4L264.2 401.6z"/></svg>',
  );

  // --- Developer / Ecosystem ---

  static const pubDev = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-128 -128 896 896"><path d="M462.69 98.37c3.58 0 7.12 0.04 10.61 0.2c-32.31-32.31-77.52-77.52-77.52-77.52C386.23 11.44 366.31 0 349.48 0c-14.48 0-28.68 2.89-37.89 8.42L132.61 98.37H462.69zM462.69 120.58H134.17l406.64 406.64l99.17-0.91l0-261.06L506.94 132.21C494.5 122.36 482.64 120.58 462.69 120.58zM120.58 466.19c0 31.91 3.7 36.93 17.82 51.11l-0.01 0.01L261.06 640l265.27 0l-0.91-96.78L120.58 138.38V466.19zM98.37 466.19l0-334.62L8.42 320C4.81 327.65 0 340.97 0 349.48c0 18.38 8.09 37.2 21.06 50.52l77.53 77.54C98.44 474.04 98.37 470.28 98.37 466.19z"/></svg>',
  );

  static const flutter = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M157.3 410L66.7 320l293.3-293.3h180.7L157.3 410ZM360 613.3L202 455.3l158-158h180.7L382.7 455.3L540.7 613.3H360Z"/></svg>',
  );

  static const docs = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M213.3 346.7h213.3v-53.3H213.3v53.3Zm0 80h213.3v-53.3H213.3v53.3Zm0 80h133.3v-53.3H213.3v53.3ZM160 586.7q-22 0-37.7-15.7T106.7 533.3v-426.7q0-22 15.7-37.7T160 53.3h213.3l160 160v320q0 22-15.7 37.7T480 586.7H160Zm186.7-346.7v-133.3H160v426.7h320v-293.3H346.7ZM160 106.7v133.3-133.3 426.7-426.7Z"/></svg>',
  );

  static const link = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M451.5 160C434.9 160 418.8 164.5 404.7 172.7C388.9 156.7 370.5 143.3 350.2 133.2C378.4 109.2 414.3 96 451.5 96C537.9 96 608 166 608 252.5C608 294 591.5 333.8 562.2 363.1L491.1 434.2C461.8 463.5 422 480 380.5 480C294.1 480 224 410 224 323.5C224 322 224 320.5 224.1 319C224.6 301.3 239.3 287.4 257 287.9C274.7 288.4 288.6 303.1 288.1 320.8C288.1 321.7 288.1 322.6 288.1 323.4C288.1 374.5 329.5 415.9 380.6 415.9C405.1 415.9 428.6 406.2 446 388.8L517.1 317.7C534.4 300.4 544.2 276.8 544.2 252.3C544.2 201.2 502.8 159.8 451.7 159.8zM307.2 237.3C305.3 236.5 303.4 235.4 301.7 234.2C289.1 227.7 274.7 224 259.6 224C235.1 224 211.6 233.7 194.2 251.1L123.1 322.2C105.8 339.5 96 363.1 96 387.6C96 438.7 137.4 480.1 188.5 480.1C205 480.1 221.1 475.7 235.2 467.5C251 483.5 269.4 496.9 289.8 507C261.6 530.9 225.8 544.2 188.5 544.2C102.1 544.2 32 474.2 32 387.7C32 346.2 48.5 306.4 77.8 277.1L148.9 206C178.2 176.7 218 160.2 259.5 160.2C346.1 160.2 416 230.8 416 317.1C416 318.4 416 319.7 416 321C415.6 338.7 400.9 352.6 383.2 352.2C365.5 351.8 351.6 337.1 352 319.4C352 318.6 352 317.9 352 317.1C352 283.4 334 253.8 307.2 237.5z"/></svg>',
  );

  static const openInNew = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M133.3 560q-22 0-37.7-15.7T80 506.7V133.3q0-22 15.7-37.7T133.3 80h186.7v53.3H133.3v373.3h373.3V320H560v186.7q0 22-15.7 37.7T506.7 560zm125.3-141.3l-37.3-37.3L469.3 133.3H373.3V80h186.7v186.7H506.7V170.7z"/></svg>',
  );

  // --- Theme ---

  static const darkMode = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M320 560q-100 0-170-70T80 320q0-100 70-170t170-70q9.3 0 18.3.7t17.7 2q-27.3 19.3-43.7 50.3T296 200q0 60 42 102t102 42q36.7 0 67.3-16.3t50-43.7q1.3 8.7 2 17.7t.7 18.3q0 100-70 170T320 560zm0-53.3q58.7 0 105.3-32.3T492 390q-13.3 3.3-26.7 5.3t-26.7 2q-82 0-139.7-57.7T242.3 200q0-13.3 2-26.7t5.3-26.7q-52 21.3-84.3 68T133.3 320q0 77.3 54.7 132t132 54.7zM313.3 320z"/></svg>',
  );

  static const lightMode = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M376.7 376.7q23.3-23.3 23.3-56.7t-23.3-56.7q-23.3-23.3-56.7-23.3t-56.7 23.3q-23.3 23.3-23.3 56.7t23.3 56.7q23.3 23.3 56.7 23.3t56.7-23.3zM225.7 414.3Q186.7 375.3 186.7 320t39-94.3Q264.7 186.7 320 186.7t94.3 39q39 39 39 94.3t-39 94.3Q375.3 453.3 320 453.3t-94.3-39zM133.3 346.7H26.7v-53.3h106.7v53.3zm480 0H506.7v-53.3h106.7v53.3zM293.3 133.3V26.7h53.3v106.7h-53.3zm0 480V506.7h53.3v106.7h-53.3zM170.7 206.7l-67.3-64.7 38-39.3 64 66.7-34.7 37.3zm328 330.7l-64.7-67.3 35.3-36.7 67.3 64.7-38 39.3zm-65.3-366.7l64.7-67.3 39.3 38-66.7 64-37.3-34.7zM102.7 525.3l67.3-64.7 36.7 35.3-64.7 67.3-39.3-38zM320 320z"/></svg>',
  );
}
''');
  }

  Future<void> _generateLabels(String websiteDir) async {
    await File(p.join(websiteDir, 'labels.dart')).writeAsString('''
/// Label constants for use in navigation links and components.
///
/// Use these instead of hardcoded strings to keep labels consistent
/// and easy to update across your site.
abstract class Labels {
  Labels._();

  // --- Code Hosting ---

  static const bitbucket = 'Bitbucket';
  static const github = 'GitHub';
  static const gitlab = 'GitLab';

  // --- Social Media ---

  static const discord = 'Discord';
  static const instagram = 'Instagram';
  static const linkedin = 'LinkedIn';
  static const medium = 'Medium';
  static const reddit = 'Reddit';
  static const slack = 'Slack';
  static const tiktok = 'TikTok';
  static const xTwitter = 'X';
  static const youtube = 'YouTube';

  // --- Developer / Ecosystem ---

  static const pubDev = 'pub.dev';
  static const docs = 'Docs';
  static const topics = 'Topics';
}
''');
  }

  Future<void> _generateLandingPage(
    String websiteDir,
    String title,
    String description,
  ) async {
    final landingContent = '''
import 'package:docudart/docudart.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  final String? title;
  final String? description;

  const LandingPage({this.title, this.description, super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'landing-page', [
      div(classes: 'hero', [
        if (title != null) h1([.text(title!)]),
        if (description != null) p(classes: 'hero-description', [.text(description!)]),
        div(classes: 'hero-actions', [
          a(href: '/docs', classes: 'button button-primary', [.text('Get Started')]),
        ]),
      ]),
    ]);
  }
}
''';

    await File(
      p.join(websiteDir, 'pages', 'landing_page.dart'),
    ).writeAsString(landingContent);
  }

  Future<void> _generateDocs(
    String websiteDir,
    String projectDir,
    InitTemplate template,
  ) async {
    final docsDir = Directory(p.join(websiteDir, 'docs'));

    // Check if docs already has .md files
    final existingMdFiles = await docsDir
        .list()
        .where((e) => e is File && e.path.endsWith('.md'))
        .toList();

    if (existingMdFiles.isNotEmpty) {
      print('Using existing documentation files in docs/');
      return;
    }

    // Try to parse README.md from project root
    final readmeFile = File(p.join(projectDir, 'README.md'));
    if (readmeFile.existsSync()) {
      await _generateDocsFromReadme(websiteDir, readmeFile);
    } else {
      // Generate example docs
      await _generateExampleDocs(websiteDir, template);
    }

    // For full template, always add example subfolders to showcase sidebar features
    if (template == InitTemplate.full) {
      await _generateFullTemplateSubfolders(websiteDir);
    }
  }

  Future<void> _generateDocsFromReadme(
    String websiteDir,
    File readmeFile,
  ) async {
    final sections = await ReadmeParser.parseFile(readmeFile.path);

    if (sections.isEmpty) {
      // Just copy README as index
      final content = await readmeFile.readAsString();
      await File(p.join(websiteDir, 'docs', 'index.md')).writeAsString('''
---
title: Introduction
sidebar_position: 1
---

$content
''');
      return;
    }

    // Generate a file for each section
    for (final section in sections) {
      final mdContent =
          '''
---
title: ${section.title}
sidebar_position: ${section.position}
---

${section.content}
''';
      await File(
        p.join(websiteDir, 'docs', '${section.filename}.md'),
      ).writeAsString(mdContent);
    }

    print('Generated ${sections.length} documentation files from README.md');
  }

  Future<void> _generateExampleDocs(
    String websiteDir,
    InitTemplate template,
  ) async {
    // Index page
    await File(p.join(websiteDir, 'docs', 'index.md')).writeAsString('''
---
title: Introduction
sidebar_position: 1
---

# Welcome to Your Documentation

This is your documentation site powered by DocuDart.

## Getting Started

Edit the files in the `docs/` folder to add your content.

## Features

- **Markdown Support**: Write your docs in Markdown with YAML frontmatter
- **Component Embedding**: Embed custom Jaspr components in your docs
- **Theming**: Customize the look and feel with themes
- **Dark Mode**: Built-in dark mode support
''');

    // Getting started page
    await File(p.join(websiteDir, 'docs', 'getting-started.md')).writeAsString(
      '''
---
title: Getting Started
sidebar_position: 2
---

# Getting Started

Learn how to use this documentation site.

## Writing Documentation

Create `.md` files in the `docs/` folder. Each file becomes a page.

### Frontmatter

Add YAML frontmatter at the top of each file:

```yaml
---
title: Page Title
sidebar_position: 1
description: Page description for SEO
---
```

### Markdown Features

- **Bold** and *italic* text
- [Links](https://example.com)
- Code blocks with syntax highlighting
- Tables, lists, and more

## Building Your Site

Run `docudart build` to generate static files.

## Development Server

Run `docudart serve` to start a local development server with hot reload.
''',
    );
  }

  /// Generate example subfolders for the full template.
  /// Showcases the `_expanded` suffix and deeply nested categories.
  Future<void> _generateFullTemplateSubfolders(String websiteDir) async {
    // Guides folder — uses _expanded suffix so it starts open in the sidebar
    final guidesDir = p.join(websiteDir, 'docs', '01-guides_expanded');
    await Directory(guidesDir).create(recursive: true);

    await File(p.join(guidesDir, 'components.md')).writeAsString('''
---
title: Custom Components
sidebar_position: 1
---

# Custom Components

You can embed custom Jaspr components in your Markdown files.

## Creating a Component

Create a Dart file in the `components/` folder:

```dart
import 'package:docudart/docudart.dart';

class MyComponent extends StatelessComponent {
  final String title;

  const MyComponent({required this.title, super.key});

  @override
  Component build(BuildContext context) {
    return div([.text(title)]);
  }
}
```

## Using Components in Markdown

Reference your component in Markdown:

```markdown
<MyComponent title="Hello World" />
```

The component will be rendered in place.
''');

    await File(p.join(guidesDir, 'theming.md')).writeAsString('''
---
title: Theming
sidebar_position: 2
---

# Theming

Customize the look and feel of your documentation site.

## Default Theme

DocuDart comes with a default theme inspired by Flutter docs.

## Customizing Colors

Edit `config.dart` to change the primary color:

```dart
theme: DefaultTheme(
  primaryColor: 0xFF6366F1, // Indigo
),
```

## Theme Mode

Control dark mode behavior via the `themeMode` field in `config.dart`:

- `ThemeMode.system` - Follow system preference (default)
- `ThemeMode.light` - Always light mode
- `ThemeMode.dark` - Always dark mode

## Custom Themes

Create a custom theme by extending `BaseTheme` in the `themes/` folder.
''');

    // Advanced folder — collapsed by default, with a nested subfolder
    final advancedDir = p.join(websiteDir, 'docs', '02-advanced');
    await Directory(advancedDir).create(recursive: true);

    await File(p.join(advancedDir, 'configuration.md')).writeAsString('''
---
title: Configuration
sidebar_position: 1
---

# Configuration

All site settings live in `config.dart`.

## Config Fields

- `title` — Site title displayed in the header
- `description` — SEO description
- `themeMode` — `system`, `light`, or `dark`
- `header` / `footer` / `sidebar` — Layout component functions (set to `null` to hide)

## Disabling a Section

```dart
final init = setup((project) => Config(
  title: project.pubspec.name,
  header: () => Header(title: project.pubspec.name),
  footer: null,    // No footer
  sidebar: null,   // No sidebar
));
```
''');

    // Deeply nested: advanced/deployment/
    final deploymentDir = p.join(advancedDir, 'deployment');
    await Directory(deploymentDir).create(recursive: true);

    await File(p.join(deploymentDir, 'github-pages.md')).writeAsString('''
---
title: GitHub Pages
sidebar_position: 1
---

# Deploy to GitHub Pages

Run `docudart build` and deploy the `website/build/web/` directory.

## GitHub Actions

Add a workflow file at `.github/workflows/docs.yml` to automate deployment on every push.
''');

    await File(p.join(deploymentDir, 'netlify.md')).writeAsString('''
---
title: Netlify
sidebar_position: 2
---

# Deploy to Netlify

Connect your repository and set the build command to `docudart build` with the publish directory set to `website/build/web/`.
''');
  }

  Future<void> _generateReadme(String websiteDir, String title) async {
    final readme =
        '''
# $title - Documentation Site

This documentation site is powered by [DocuDart](https://github.com/docudart/docudart).

## Quick Start

```bash
# Build the static site
docudart build

# Start a development server with hot reload
docudart serve
```

## Project Structure

```
website/
  config.dart        # Site configuration (title, theme, layout components)
  docs/              # Markdown documentation files
  pages/             # Custom page components (Dart/Jaspr)
  components/        # Layout components (header, footer, sidebar)
    header.dart      # Header component wrapping DefaultHeader
    footer.dart      # Footer component wrapping DefaultFooter
    sidebar.dart     # Sidebar component wrapping DefaultSidebar
  assets/            # Static files (images, fonts, etc.)
  themes/            # Custom theme implementations
```

## Writing Documentation

Add Markdown files to the `docs/` directory. Each file becomes a page on your site.

Every doc file should start with YAML frontmatter:

```markdown
---
title: Page Title
sidebar_position: 1
description: Optional description for SEO
---

# Page Title

Your content here.
```

- **`title`** - Displayed in the sidebar and browser tab.
- **`sidebar_position`** - Controls ordering in the sidebar (lower numbers appear first).
- **`description`** - Used for SEO meta tags.

### Organizing Docs

Create subdirectories inside `docs/` to group related pages. The folder structure is reflected in the sidebar.

## Customizing Layout

The header, footer, and sidebar are components defined in `components/`. Edit them to customize your site's layout.

### Disabling a Section

Set any layout section to `null` in `config.dart` to hide it:

```dart
final init = setup((project) => Config(
  title: project.pubspec.name,
  header: () => Header(title: project.pubspec.name),
  footer: null,    // No footer
  sidebar: null,   // No sidebar
));
```

## Configuration

All site settings live in `config.dart`:

```dart
import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';

final init = setup((project) => Config(
  title: project.pubspec.name,
  description: project.pubspec.description,

  // Theme
  themeMode: ThemeMode.system,  // system | light | dark
  theme: DefaultTheme(
    primaryColor: 0xFF0175C2,   // custom primary color
  ),

  // Layout components (set to null to hide)
  header: () => Header(title: project.pubspec.name),
  footer: () => Footer(text: project.pubspec.name),
  sidebar: () => Sidebar(items: project.docs),
));
```

## Build Output

Running `docudart build` generates static files in `website/build/web/`. You can deploy this directory to any static hosting provider (GitHub Pages, Netlify, Vercel, Firebase Hosting, etc.).
''';

    await File(p.join(websiteDir, 'README.md')).writeAsString(readme);
  }

  Future<void> _updateGitignore(String projectDir) async {
    final gitignoreFile = File(p.join(projectDir, '.gitignore'));
    final content = gitignoreFile.existsSync()
        ? await gitignoreFile.readAsString()
        : '';

    final additions = <String>[];

    // Add DocuDart-specific entries
    if (!content.contains('website/.dart_tool/')) {
      additions.add('website/.dart_tool/');
    }
    if (!content.contains('website/build/')) {
      additions.add('website/build/');
    }

    if (additions.isNotEmpty) {
      final newContent =
          '${content.trimRight()}\n\n# DocuDart\n${additions.join('\n')}\n';
      await gitignoreFile.writeAsString(newContent);
    }
  }
}
