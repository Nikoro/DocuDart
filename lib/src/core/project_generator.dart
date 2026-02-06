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

    // Generate config.dart
    await _generateConfig(websiteDir, title, description, template);

    // Generate landing page
    await _generateLandingPage(websiteDir, title, description);

    // Generate documentation files (look for README.md in project root)
    await _generateDocs(websiteDir, directory, template);

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
    print('    README.md');
    print('    docs/');
    print('    pages/');
    print('    components/');
    print('    assets/');
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

      // Add .gitkeep to empty directories
      if (dir != 'docs' && dir != 'pages') {
        await File(p.join(path, '.gitkeep')).writeAsString('');
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

  Future<void> _generateConfig(
    String websiteDir,
    String title,
    String description,
    InitTemplate template,
  ) async {
    final configContent =
        '''
import 'package:docudart/docudart.dart';

final config = DocuDartConfig(
  title: '$title',
  description: '$description',

  // Theme configuration
  theme: DefaultTheme(
    // primaryColor: 0xFF0175C2, // Uncomment to customize primary color
    darkMode: DarkModeConfig.system,
  ),

  // Sidebar configuration
  sidebar: SidebarConfig(
    autoGenerate: true,
    // Add manual sidebar items here if needed
    items: [],
  ),

  // Header configuration
  header: HeaderConfig(
    showThemeToggle: true,
    navLinks: [
      NavLink.internal(title: 'Docs', path: '/docs'),
      // NavLink.external(title: 'GitHub', url: 'https://github.com/...'),
    ],
  ),

  // Footer configuration
  footer: FooterConfig(
    copyright: '© ${DateTime.now().year} $title',
  ),
);
''';

    await File(p.join(websiteDir, 'config.dart')).writeAsString(configContent);
  }

  Future<void> _generateLandingPage(
    String websiteDir,
    String title,
    String description,
  ) async {
    final landingContent =
        '''
import 'package:docudart/docudart.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'landing-page',
      [
        div(
          classes: 'hero',
          [
            h1([.text('$title')]),
            p(
              classes: 'hero-description',
              [.text('$description')],
            ),
            div(
              classes: 'hero-actions',
              [
                a(
                  href: '/docs',
                  classes: 'button button-primary',
                  [.text('Get Started')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
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
      return;
    }

    // Generate example docs
    await _generateExampleDocs(websiteDir, template);
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

    if (template == InitTemplate.full) {
      // Add more example files for full template
      await File(p.join(websiteDir, 'docs', 'components.md')).writeAsString('''
---
title: Custom Components
sidebar_position: 3
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

      await File(p.join(websiteDir, 'docs', 'theming.md')).writeAsString('''
---
title: Theming
sidebar_position: 4
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
  darkMode: DarkModeConfig.system,
),
```

## Dark Mode

The default theme supports dark mode. Configure it in `config.dart`:

- `DarkModeConfig.system` - Follow system preference
- `DarkModeConfig.light` - Always light mode
- `DarkModeConfig.dark` - Always dark mode
- `DarkModeConfig.toggle` - Show toggle button

## Custom Themes

Create a custom theme by extending `BaseTheme` in the `themes/` folder.
''');
    }
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
  config.dart        # Site configuration (title, theme, sidebar, header, footer)
  docs/              # Markdown documentation files
  pages/             # Custom page components (Dart/Jaspr)
  components/        # Reusable components for embedding in docs
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

Create subdirectories inside `docs/` to group related pages. The folder structure is reflected in the sidebar when `autoGenerate` is enabled.

## Adding Custom Pages

Create Dart files in the `pages/` directory using Jaspr components (via the `docudart` package):

```dart
import 'package:docudart/docudart.dart';

class MyPage extends StatelessComponent {
  const MyPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'my-page', [
      h1([.text('My Custom Page')]),
      p([.text('This is a custom page built with Jaspr.')]),
    ]);
  }
}
```

Pages are registered in `config.dart` via the `customPages` option and wired to routes automatically.

## Configuration

All site settings live in `config.dart`. Here is an overview of the main options:

```dart
import 'package:docudart/docudart.dart';

final config = DocuDartConfig(
  // Site metadata
  title: 'My Project',
  description: 'Project documentation',

  // Theme
  theme: DefaultTheme(
    primaryColor: 0xFF0175C2,          // custom primary color
    darkMode: DarkModeConfig.system,   // system | light | dark | toggle
  ),

  // Sidebar
  sidebar: SidebarConfig(
    autoGenerate: true,  // auto-generate from docs/ folder structure
    items: [],           // additional manual sidebar entries
  ),

  // Header navigation
  header: HeaderConfig(
    showThemeToggle: true,
    navLinks: [
      NavLink.internal(title: 'Docs', path: '/docs'),
      NavLink.external(title: 'GitHub', url: 'https://github.com/...'),
    ],
  ),

  // Footer
  footer: FooterConfig(
    copyright: '© 2024 My Project',
  ),
);
```

### Key Configuration Options

| Option | Description |
|--------|-------------|
| `title` | Site title shown in the header and browser tab |
| `description` | Site description for SEO |
| `theme` | Theme instance (`DefaultTheme` or custom `BaseTheme` subclass) |
| `sidebar.autoGenerate` | Automatically build sidebar from `docs/` folder structure |
| `sidebar.items` | Manually defined sidebar sections and links |
| `header.navLinks` | Top navigation links (internal or external) |
| `header.showThemeToggle` | Show the light/dark mode toggle button |
| `footer.copyright` | Copyright text in the footer |

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
