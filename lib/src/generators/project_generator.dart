import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'asset_path_generator.dart';
import '../services/package_resolver.dart';
import '../processing/readme_parser.dart';

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
    // Check if CHANGELOG.md exists in the project root
    final hasChangelog = File(p.join(directory, 'CHANGELOG.md')).existsSync();
    // Check if the package exists on pub.dev
    print('Checking pub.dev for package...');
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
    await _generateComponents(websiteDir, title);

    // Generate changelog page if CHANGELOG.md exists in the parent project
    if (hasChangelog) {
      await _generateChangelogPage(websiteDir);
    }

    // Generate config.dart
    await _generateConfig(
      websiteDir,
      title,
      description,
      template,
      pubDevUrl,
      hasChangelog: hasChangelog,
    );

    // Generate labels.dart
    await _generateLabels(websiteDir);

    // Generate landing page
    await _generateLandingPage(websiteDir, title, description);

    // Generate documentation files (look for README.md in project root)
    await _generateDocs(websiteDir, directory, template);

    // Generate default favicon files
    await _generateFavicons(websiteDir);

    // Generate default logo
    await _generateLogo(websiteDir);

    // Generate type-safe asset paths (assets/assets.dart)
    await _generateAssetPaths(websiteDir);

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
    print('    labels.dart');
    print('    README.md');
    print('    docs/');
    print('    pages/');
    print('      landing_page.dart');
    print('    components/');
    print('      header.dart');
    print('      footer.dart');
    print('      button.dart');
    print('      sidebar.dart');
    print('    assets/');
    print('      assets.dart');
    print('      logo/');
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

  Future<void> _generateLogo(String websiteDir) async {
    final docudartRoot = await PackageResolver.resolveDocudartPath();
    final sourceDir = Directory(
      p.join(docudartRoot, 'lib', 'src', 'assets', 'logo'),
    );
    if (!sourceDir.existsSync()) return;

    final targetDir = Directory(p.join(websiteDir, 'assets', 'logo'));
    await targetDir.create(recursive: true);

    await for (final entity in sourceDir.list()) {
      if (entity is File) {
        final targetPath = p.join(targetDir.path, p.basename(entity.path));
        await entity.copy(targetPath);
      }
    }
  }

  Future<void> _generateAssetPaths(String websiteDir) async {
    final assetsDir = p.join(websiteDir, 'assets');
    final content = AssetPathGenerator.generate(assetsDir);
    final targetFile = File(p.join(assetsDir, 'assets.dart'));
    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsString(content);
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
/// The [leading] slot is typically a [Logo].
class Header extends StatelessComponent {
  const Header({this.leading, this.links, this.trailing, super.key});

  final Component? leading;
  final List<Link>? links;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return header([
      Row(
        crossAxisAlignment: .center,
        spacing: 1.5.rem,
        children: [?leading, Spacer(), ...?links, ?trailing],
      ),
    ]);
  }
}
''');

    // Footer component
    await File(p.join(componentsDir, 'footer.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
class Footer extends StatelessComponent {
  const Footer({this.leading, this.center, this.trailing, super.key});

  final Component? leading;
  final Component? center;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return footer([
      Row(
        mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .center,
        children: [?leading, ?center, ?trailing],
      ),
    ]);
  }
}
''');

    // Button component
    await File(p.join(componentsDir, 'button.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// A clickable button component.
class Button extends StatelessComponent {
  final String text;
  final String href;
  final String classes;

  const Button({required this.text, required this.href, this.classes = 'button', super.key});

  const Button.primary({required this.text, required this.href, super.key})
      : classes = 'button button-primary';

  @override
  Component build(BuildContext context) {
    return a(href: href, classes: classes, [.text(text)]);
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
  final List<Doc> items;

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
    String pubDevUrl, {
    bool hasChangelog = false,
  }) async {
    final changelogLink = hasChangelog
        ? "      .path('/changelog', label: Labels.changelog),\n"
        : '';

    final configContent =
        "import 'package:docudart/docudart.dart';\n"
        "import 'assets/assets.dart';\n"
        "import 'components/header.dart';\n"
        "import 'components/footer.dart';\n"
        "import 'components/sidebar.dart';\n"
        "import 'labels.dart';\n"
        "import 'pages/landing_page.dart';\n"
        '\n'
        'Config configure(BuildContext context) => Config(\n'
        '  title: context.project.pubspec.name,\n'
        '  description: context.project.pubspec.description,\n'
        '  themeMode: .system,\n'
        '  theme: DefaultTheme(),\n'
        "  // Home page component. Set to null to redirect '/' to '/docs'.\n"
        '  home: () => context.project.pubspec.let(\n'
        '    (pubspec) =>\n'
        '        LandingPage(title: pubspec.name, description: pubspec.description),\n'
        '  ),\n'
        '  // Header, footer, and sidebar are components.\n'
        '  // Set to null to hide any section.\n'
        '  header: () => Header(\n'
        "    leading: Logo(\n"
        "      image: img(\n"
        "        src: Assets.logo.logo_webp,\n"
        r"        alt: '${context.project.pubspec.name} logo',"
        "\n"
        "      ),\n"
        '      title: context.project.pubspec.name,\n'
        '    ),\n'
        '    links: [\n'
        "      .path('/docs', label: Labels.docs, leading: Icon(MaterialSymbols.docs)),\n"
        '$changelogLink'
        "      ?context.project.pubspec.repository.let(\n"
        "        (repository) => .url(\n"
        "          repository.link,\n"
        "          label: repository.label,\n"
        "          leading: repository.icon,\n"
        "          trailing: Icon(MaterialIcons.open_in_new),\n"
        "        ),\n"
        "      ),\n"
        "      .url(\n"
        "        '$pubDevUrl',\n"
        "        label: Labels.pubDev,\n"
        "        leading: Icon(FontAwesomeIcons.dart_lang_brand),\n"
        "        trailing: Icon(MaterialIcons.open_in_new),\n"
        "      ),\n"
        '    ],\n'
        '    trailing: ThemeToggle(\n'
        '      light: Icon(MaterialIcons.light_mode),\n'
        '      dark: Icon(MaterialIcons.dark_mode),\n'
        '    ),\n'
        '  ),\n'
        '  footer: () => context.project.pubspec.let(\n'
        '    (pubspec) => Footer(\n'
        '      leading: pubspec.topics.let(\n'
        '        (topics) => Topics(\n'
        '          title: Labels.topics,\n'
        '          links: [\n'
        "            for (final topic in topics)\n"
        r"              .url('https://pub.dev/packages?q=topic%3A$topic', label: '#$topic'),"
        '\n'
        '          ],\n'
        '        ),\n'
        '      ),\n'
        '      center: Column(\n'
        '        children: [\n'
        '          Copyright(text: pubspec.name),\n'
        '          BuiltWithDocuDart(),\n'
        '        ],\n'
        '      ),\n'
        '      trailing: Socials(\n'
        '        links: [\n'
        "          .url('https://youtube.com', leading: Icon(FontAwesomeIcons.youtube_brand)),\n"
        "          .url('https://discord.com', leading: Icon(FontAwesomeIcons.discord_brand)),\n"
        "          .url('https://x.com', leading: Icon(FontAwesomeIcons.x_twitter_brand)),\n"
        '        ],\n'
        '      ),\n'
        '    ),\n'
        '  ),\n'
        "  sidebar: () => context.url.contains('/docs')\n"
        '      ? Sidebar(items: context.project.docs)\n'
        '      : null,\n'
        ');\n';

    await File(p.join(websiteDir, 'config.dart')).writeAsString(configContent);
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
  static const changelog = 'Changelog';
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

import '../components/button.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  final String? title;
  final String? description;

  const LandingPage({this.title, this.description, super.key});

  @override
  Component build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 1.5.rem,
      children: [
        ?title.let((t) => h1([.text(t)])),
        ?description.let((d) => p(classes: 'description', [.text(d)])),
        Button.primary(text: 'Get Started', href: '/docs'),
      ],
    ).apply(classes: 'landing-page');
  }
}
''';

    await File(
      p.join(websiteDir, 'pages', 'landing_page.dart'),
    ).writeAsString(landingContent);
  }

  Future<void> _generateChangelogPage(String websiteDir) async {
    await File(
      p.join(websiteDir, 'pages', 'changelog_page.dart'),
    ).writeAsString('''
import 'package:docudart/docudart.dart';

class ChangelogPage extends StatelessComponent {
  const ChangelogPage({super.key});

  @override
  Component build(BuildContext context) {
    return Markdown(content: context.project.changelog ?? '');
  }
}
''');
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
Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: null,    // No footer
  sidebar: null,   // No sidebar
);
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
    header.dart      # Header component
    footer.dart      # Footer component
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
Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: null,    // No footer
  sidebar: null,   // No sidebar
);
```

## Configuration

All site settings live in `config.dart`:

```dart
import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';

Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  description: context.project.pubspec.description,

  // Theme
  themeMode: ThemeMode.system,  // system | light | dark
  theme: DefaultTheme(
    primaryColor: 0xFF0175C2,   // custom primary color
  ),

  // Layout components (set to null to hide)
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: () => Footer(center: Copyright(text: context.project.pubspec.name)),
  sidebar: () => Sidebar(items: context.project.docs),
);
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
