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

    // Create directory structure inside website/
    await _createDirectories(websiteDir);

    // Generate website/pubspec.yaml with path dependency to docudart
    await _generateWebsitePubspec(websiteDir, title);

    // Generate wrapper components (header, footer, sidebar)
    await _generateComponents(websiteDir, title);

    // Generate config.dart
    await _generateConfig(websiteDir, title, description, template);

    // Generate icons.dart
    await _generateIcons(websiteDir);

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

    print('Created project structure:');
    print('  website/');
    print('    pubspec.yaml');
    print('    config.dart');
    print('    icons.dart');
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
      };
    } catch (_) {
      return {};
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

  Future<void> _generateWebsitePubspec(String websiteDir, String title) async {
    final docudartPath = await PackageResolver.relativePathTo(websiteDir);
    final packageName = _sanitizePackageName(title);

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
''';

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
/// and optional theme toggle.
class Header extends StatelessComponent {
  const Header(this.navLinks, {required this.title, super.key});

  final String title;
  final List<NavLink> navLinks;

  @override
  Component build(BuildContext context) {
    return DefaultHeader(
      title: title,
      navLinks: navLinks,
    );
  }
}
''');

    // Footer component
    await File(p.join(componentsDir, 'footer.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

import '../config.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
/// The [DefaultFooter] provides a simple centered text footer.
class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    final year = DateTime.now().year;
    return DefaultFooter(text: '© \$year \${config.title}');
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
  ) async {
    final configContent =
        '''
import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';
import 'icons.dart';
import 'pages/landing_page.dart';

Config get config => Config(
  title: '$title',
  description: '$description',

  // Theme configuration
  themeMode: ThemeMode.system,
  theme: DefaultTheme(
    // primaryColor: 0xFF0175C2, // Uncomment to customize primary color
  ),

  // Home page component. Set to null to redirect '/' to '/docs'.
  home: (context) => LandingPage(),

  // Header, footer, and sidebar are components.
  // Set to null to hide any section.
  header: (context) => Header(title: '$title', [
    .path('/docs', label: 'Docs', icon: Icons.docs),
    .url('https://github.com', label: 'GitHub', icon: Icons.github),
    .url('https://pub.dev', label: 'pub.dev', icon: Icons.dart),
  ]),
  footer: (context) => Footer(),
  sidebar: (context) => Sidebar(items: context.docs),
);
''';

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

  static const github = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M237.9 461.4C237.9 463.4 235.6 465 232.7 465C229.4 465.3 227.1 463.7 227.1 461.4C227.1 459.4 229.4 457.8 232.3 457.8C235.3 457.5 237.9 459.1 237.9 461.4zM206.8 456.9C206.1 458.9 208.1 461.2 211.1 461.8C213.7 462.8 216.7 461.8 217.3 459.8C217.9 457.8 216 455.5 213 454.6C210.4 453.9 207.5 454.9 206.8 456.9zM251 455.2C248.1 455.9 246.1 457.8 246.4 460.1C246.7 462.1 249.3 463.4 252.3 462.7C255.2 462 257.2 460.1 256.9 458.1C256.6 456.2 253.9 454.9 251 455.2zM316.8 72C178.1 72 72 177.3 72 316C72 426.9 141.8 521.8 241.5 555.2C254.3 557.5 258.8 549.6 258.8 543.1C258.8 536.9 258.5 502.7 258.5 481.7C258.5 481.7 188.5 496.7 173.8 451.9C173.8 451.9 162.4 422.8 146 415.3C146 415.3 123.1 399.6 147.6 399.9C147.6 399.9 172.5 401.9 186.2 425.7C208.1 464.3 244.8 453.2 259.1 446.6C261.4 430.6 267.9 419.5 275.1 412.9C219.2 406.7 162.8 398.6 162.8 302.4C162.8 274.9 170.4 261.1 186.4 243.5C183.8 237 175.3 210.2 189 175.6C209.9 169.1 258 202.6 258 202.6C278 197 299.5 194.1 320.8 194.1C342.1 194.1 363.6 197 383.6 202.6C383.6 202.6 431.7 169 452.6 175.6C466.3 210.3 457.8 237 455.2 243.5C471.2 261.2 481 275 481 302.4C481 398.9 422.1 406.6 366.2 412.9C375.4 420.8 383.2 435.8 383.2 459.3C383.2 493 382.9 534.7 382.9 542.9C382.9 549.4 387.5 557.3 400.2 555C500.2 521.8 568 426.9 568 316C568 177.3 455.5 72 316.8 72zM169.2 416.9C167.9 417.9 168.2 420.2 169.9 422.1C171.5 423.7 173.8 424.4 175.1 423.1C176.4 422.1 176.1 419.8 174.4 417.9C172.8 416.3 170.5 415.6 169.2 416.9zM158.4 408.8C157.7 410.1 158.7 411.7 160.7 412.7C162.3 413.7 164.3 413.4 165 412C165.7 410.7 164.7 409.1 162.7 408.1C160.7 407.5 159.1 407.8 158.4 408.8zM190.8 444.4C189.2 445.7 189.8 448.7 192.1 450.6C194.4 452.9 197.3 453.2 198.6 451.6C199.9 450.3 199.3 447.3 197.3 445.4C195.1 443.1 192.1 442.8 190.8 444.4zM179.4 429.7C177.8 430.7 177.8 433.3 179.4 435.6C181 437.9 183.7 438.9 185 437.9C186.6 436.6 186.6 434 185 431.7C183.6 429.4 181 428.4 179.4 429.7z"/></svg>',
  );

  static const dart = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M442.6 142.9C439.8 142.8 437 142.7 434.1 142.7L170 142.7L313.2 70.7C320.6 66.3 332 64 343.6 64C357.1 64 373 73.2 380.6 80.8L442.6 142.8L442.6 142.9zM171.3 160.5L434.1 160.5C450.1 160.5 459.5 161.9 469.5 169.8L576 276.2L576 485L496.7 485.7L171.3 160.5zM160.5 437L160.5 174.8L484.3 498.6L485 576L272.8 576L174.7 477.8C163.4 466.5 160.5 462.5 160.5 437zM142.7 169.3L142.7 437C142.7 440.3 142.8 443.3 142.9 446.1L80.9 384.1C70.5 373.3 64 358.3 64 343.6C64 336.8 67.9 326.1 70.7 320L142.7 169.3z"/></svg>',
  );

  static const docs = RawText(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><path d="M304 112L192 112C183.2 112 176 119.2 176 128L176 512C176 520.8 183.2 528 192 528L448 528C456.8 528 464 520.8 464 512L464 272L376 272C336.2 272 304 239.8 304 200L304 112zM444.1 224L352 131.9L352 200C352 213.3 362.7 224 376 224L444.1 224zM128 128C128 92.7 156.7 64 192 64L325.5 64C342.5 64 358.8 70.7 370.8 82.7L493.3 205.3C505.3 217.3 512 233.6 512 250.6L512 512C512 547.3 483.3 576 448 576L192 576C156.7 576 128 547.3 128 512L128 128z"/></svg>',
  );
}
''');
  }

  Future<void> _generateLandingPage(
    String websiteDir,
    String title,
    String description,
  ) async {
    final landingContent =
        '''
import 'package:docudart/docudart.dart';

import '../config.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    final title = config.title;
    final description = config.description;
    return div(classes: 'landing-page', [
      div(classes: 'hero', [
        if (title != null) h1([.text(title)]),
        if (description != null) p(classes: 'hero-description', [.text(description)]),
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
Config get config => Config(
  title: 'My Project',
  header: (context) => Header(),
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
Config get config => Config(
  title: 'My Project',
  header: (context) => Header(),
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

Config get config => Config(
  title: 'My Project',
  description: 'Project documentation',

  // Theme
  themeMode: ThemeMode.system,  // system | light | dark
  theme: DefaultTheme(
    primaryColor: 0xFF0175C2,   // custom primary color
  ),

  // Layout components (set to null to hide)
  header: (context) => Header(),
  footer: (context) => Footer(),
  sidebar: (context) => Sidebar(items: context.docs),
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
