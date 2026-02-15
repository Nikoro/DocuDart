import 'dart:io';

import 'package:path/path.dart' as p;

import '../cli/errors.dart';
import '../processing/readme_parser.dart';

/// Generates template files (components, config, labels, pages, docs)
/// for new DocuDart projects.
class ProjectTemplates {
  /// Generate wrapper components in [websiteDir]/components/.
  Future<void> generateComponents(String websiteDir, String title) async {
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
  const Sidebar({super.key});

  @override
  Component build(BuildContext context) {
    return DefaultSidebar(items: context.project.docs);
  }
}
''');
  }

  /// Generate config.dart in [websiteDir].
  Future<void> generateConfig(
    String websiteDir,
    String title,
    String description,
    String pubDevUrl, {
    bool hasChangelog = false,
  }) async {
    final changelogLink = hasChangelog
        ? "      .path('/changelog', label: Labels.changelog),\n"
        : '';

    final configContent =
        "import 'package:docudart/docudart.dart';\n"
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
        '  theme: Theme.classic(),\n'
        "  // Home page component. Set to null to redirect '/' to '/docs'.\n"
        '  home: () => LandingPage(),\n'
        '  // Header, footer, and sidebar are components.\n'
        '  // Set to null to hide any section.\n'
        '  header: () => Header(\n'
        "    leading: Logo(\n"
        r"      image: context.project.assets.logo.logo_webp(alt: '${context.project.pubspec.name} logo'),"
        "\n"
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
        '          Copyright(text: context.project.license?.holder ?? pubspec.name),\n'
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
        "  sidebar: () => context.url.contains('/docs') ? Sidebar() : null,\n"
        ');\n';

    await File(p.join(websiteDir, 'config.dart')).writeAsString(configContent);
  }

  /// Generate labels.dart in [websiteDir].
  Future<void> generateLabels(String websiteDir) async {
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

  /// Generate landing page in [websiteDir]/pages/.
  Future<void> generateLandingPage(
    String websiteDir,
    String title,
    String description,
  ) async {
    final landingContent = '''
import 'package:docudart/docudart.dart';

import '../components/button.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    final title = context.project.pubspec.name;
    final description = context.project.pubspec.description;
    return Column(
      mainAxisAlignment: .center,
      spacing: 1.5.rem,
      children: [
        Logo(image: context.project.assets.logo.logo_webp()),
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

  /// Generate changelog page in [websiteDir]/pages/.
  Future<void> generateChangelogPage(String websiteDir) async {
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

  /// Generate documentation files from README.md or example templates.
  Future<void> generateDocs(
    String websiteDir,
    String projectDir,
    bool isFull,
  ) async {
    final docsDir = Directory(p.join(websiteDir, 'docs'));

    // Check if docs already has .md files
    final existingMdFiles = await docsDir
        .list()
        .where((e) => e is File && e.path.endsWith('.md'))
        .toList();

    if (existingMdFiles.isNotEmpty) {
      CliPrinter.info('Using existing documentation files in docs/');
      return;
    }

    // Try to parse README.md from project root
    final readmeFile = File(p.join(projectDir, 'README.md'));
    if (readmeFile.existsSync()) {
      await _generateDocsFromReadme(websiteDir, readmeFile);
    } else {
      await _generateExampleDocs(websiteDir);
    }

    // For full template, always add example subfolders to showcase sidebar features
    if (isFull) {
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

    CliPrinter.info(
      'Generated ${sections.length} documentation files from README.md',
    );
  }

  Future<void> _generateExampleDocs(String websiteDir) async {
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
theme: Theme.classic(seedColor: Colors.indigo),
```

## Theme Mode

Control dark mode behavior via the `themeMode` field in `config.dart`:

- `ThemeMode.system` - Follow system preference (default)
- `ThemeMode.light` - Always light mode
- `ThemeMode.dark` - Always dark mode

## Custom Themes

Create a custom theme using `Theme()` or customize a preset with `copyWith`.
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

Run `docudart build` and deploy the `build/web/` directory.

## GitHub Actions

Add a workflow file at `.github/workflows/docs.yml` to automate deployment on every push.
''');

    await File(p.join(deploymentDir, 'netlify.md')).writeAsString('''
---
title: Netlify
sidebar_position: 2
---

# Deploy to Netlify

Connect your repository and set the build command to `docudart build` with the publish directory set to `build/web/`.
''');
  }

  /// Generate README.md in [websiteDir].
  Future<void> generateReadme(String websiteDir, String title) async {
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
docudart/
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
  theme: Theme.classic(
    seedColor: Colors.blue,     // accepts Colors.xxx or 0xAARRGGBB
  ),

  // Layout components (set to null to hide)
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: () => Footer(center: Copyright(text: context.project.pubspec.name)),
  sidebar: () => Sidebar(),
);
```

## Build Output

Running `docudart build` generates static files in `build/web/`. You can deploy this directory to any static hosting provider (GitHub Pages, Netlify, Vercel, Firebase Hosting, etc.).
''';

    await File(p.join(websiteDir, 'README.md')).writeAsString(readme);
  }
}
