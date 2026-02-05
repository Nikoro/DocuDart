import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'readme_parser.dart';

/// Template options for project initialization.
enum InitTemplate {
  /// Basic setup with config, landing page, and docs.
  defaultTemplate,

  /// Full template with all feature examples.
  full,
}

/// Generates a new DocuDart project structure.
class ProjectGenerator {
  /// Generate project files in the target directory.
  Future<void> generate({
    required String directory,
    required InitTemplate template,
  }) async {
    final dir = Directory(directory);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    // Load info from pubspec.yaml if it exists
    final pubspecInfo = await _loadPubspecInfo(directory);
    final title = pubspecInfo['name'] ?? 'My Documentation';
    final description = pubspecInfo['description'] ?? 'Documentation site';

    // Create directory structure
    await _createDirectories(directory);

    // Generate config.dart
    await _generateConfig(directory, title, description, template);

    // Generate landing page
    await _generateLandingPage(directory, title, description);

    // Generate documentation files
    await _generateDocs(directory, template);

    // Update .gitignore
    await _updateGitignore(directory);

    print('Created project structure:');
    print('  config.dart');
    print('  docs/');
    print('  pages/');
    print('  components/');
    print('  assets/');
    print('  themes/');
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

  Future<void> _createDirectories(String directory) async {
    final dirs = ['docs', 'pages', 'components', 'assets', 'themes'];
    for (final dir in dirs) {
      final path = p.join(directory, dir);
      await Directory(path).create(recursive: true);

      // Add .gitkeep to empty directories
      if (dir != 'docs' && dir != 'pages') {
        await File(p.join(path, '.gitkeep')).writeAsString('');
      }
    }
  }

  Future<void> _generateConfig(
    String directory,
    String title,
    String description,
    InitTemplate template,
  ) async {
    final configContent = '''
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

    await File(p.join(directory, 'config.dart')).writeAsString(configContent);
  }

  Future<void> _generateLandingPage(
    String directory,
    String title,
    String description,
  ) async {
    final landingContent = '''
import 'package:jaspr/jaspr.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      classes: ['landing-page'],
      [
        div(
          classes: ['hero'],
          [
            h1([text('$title')]),
            p(
              classes: ['hero-description'],
              [text('$description')],
            ),
            div(
              classes: ['hero-actions'],
              [
                a(
                  href: '/docs',
                  classes: ['button', 'button-primary'],
                  [text('Get Started')],
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

    await File(p.join(directory, 'pages', 'landing.dart'))
        .writeAsString(landingContent);
  }

  Future<void> _generateDocs(String directory, InitTemplate template) async {
    final docsDir = Directory(p.join(directory, 'docs'));

    // Check if docs already has .md files
    final existingMdFiles = await docsDir
        .list()
        .where((e) => e is File && e.path.endsWith('.md'))
        .toList();

    if (existingMdFiles.isNotEmpty) {
      print('Using existing documentation files in docs/');
      return;
    }

    // Try to parse README.md
    final readmeFile = File(p.join(directory, 'README.md'));
    if (readmeFile.existsSync()) {
      await _generateDocsFromReadme(directory, readmeFile);
      return;
    }

    // Generate example docs
    await _generateExampleDocs(directory, template);
  }

  Future<void> _generateDocsFromReadme(
      String directory, File readmeFile) async {
    final sections = await ReadmeParser.parseFile(readmeFile.path);

    if (sections.isEmpty) {
      // Just copy README as index
      final content = await readmeFile.readAsString();
      await File(p.join(directory, 'docs', 'index.md')).writeAsString('''
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
      final mdContent = '''
---
title: ${section.title}
sidebar_position: ${section.position}
---

${section.content}
''';
      await File(p.join(directory, 'docs', '${section.filename}.md'))
          .writeAsString(mdContent);
    }

    print('Generated ${sections.length} documentation files from README.md');
  }

  Future<void> _generateExampleDocs(
      String directory, InitTemplate template) async {
    // Index page
    await File(p.join(directory, 'docs', 'index.md')).writeAsString('''
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
    await File(p.join(directory, 'docs', 'getting-started.md')).writeAsString('''
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
''');

    if (template == InitTemplate.full) {
      // Add more example files for full template
      await File(p.join(directory, 'docs', 'components.md')).writeAsString('''
---
title: Custom Components
sidebar_position: 3
---

# Custom Components

You can embed custom Jaspr components in your Markdown files.

## Creating a Component

Create a Dart file in the `components/` folder:

```dart
import 'package:jaspr/jaspr.dart';

class MyComponent extends StatelessComponent {
  final String title;

  const MyComponent({required this.title, super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([text(title)]);
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

      await File(p.join(directory, 'docs', 'theming.md')).writeAsString('''
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

  Future<void> _updateGitignore(String directory) async {
    final gitignoreFile = File(p.join(directory, '.gitignore'));
    final content = gitignoreFile.existsSync()
        ? await gitignoreFile.readAsString()
        : '';

    final additions = <String>[];

    // Add DocuDart-specific entries
    if (!content.contains('.dart_tool/docudart/')) {
      additions.add('.dart_tool/docudart/');
    }
    if (!content.contains('build/')) {
      additions.add('build/');
    }

    if (additions.isNotEmpty) {
      final newContent = content.trimRight() +
          '\n\n# DocuDart\n' +
          additions.join('\n') +
          '\n';
      await gitignoreFile.writeAsString(newContent);
    }
  }
}
