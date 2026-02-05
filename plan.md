# DocuDart Implementation Plan

A static documentation generator for Dart, powered by Jaspr.

## Overview

DocuDart is a CLI tool that generates static documentation websites from Markdown files, similar to Docusaurus but written in Dart. It uses Jaspr as the rendering engine for static site generation.

---

## User Requirements Summary

| Feature | Decision |
|---------|----------|
| CLI Commands | `init`, `build`, `serve` |
| Content Types | Docs (markdown) + Custom pages (Dart) |
| Configuration | `config.dart` (Dart-based for IntelliSense) |
| Markdown | Full MDX-like component embedding, YAML frontmatter |
| Sidebar | Auto-generated with manual overrides |
| Versioning | Basic support with version switcher |
| Theming | Full system - users can create custom themes |
| Default Theme | Flutter docs style (blue accents, cards) |
| Dark Mode | System preference + manual toggle |
| URLs | Clean URLs (`/docs/intro/` not `.html`) |
| Assets | Relative paths in docs/ + central assets/ folder |
| Build Output | Configurable, default `build/web/` |
| Hot Reload | Full hot reload on any file change |
| Dart SDK | 3.0+ |
| Search | Not in MVP |
| i18n | Not in MVP |

---

## Architecture

### How DocuDart Works

```
[User Project]              [docudart CLI]              [Jaspr]
     |                            |                        |
     +-- config.dart ------------>|                        |
     +-- docs/*.md -------------->| Process & Generate --->| Build SSG
     +-- pages/*.dart ----------->|                        |
     +-- components/*.dart ------>|                        |
     +-- themes/*.dart ---------->|                        |
                                  |                        |
                                  v                        v
                          .dart_tool/docudart/      build/web/
                          (managed Jaspr site)      (static output)
```

Key insight: DocuDart manages a hidden Jaspr project in `.dart_tool/docudart/`. This keeps the user's project clean while leveraging Jaspr's full capabilities.

---

## Current Project Structure (Implemented)

```
docudart/
├── bin/
│   └── docudart.dart                    # CLI entry point
├── lib/
│   ├── docudart.dart                    # Main library exports
│   └── src/
│       ├── cli/
│       │   ├── cli_runner.dart          # CommandRunner setup
│       │   └── commands/
│       │       ├── init_command.dart    # docudart init
│       │       ├── build_command.dart   # docudart build
│       │       └── serve_command.dart   # docudart serve
│       ├── config/
│       │   ├── docudart_config.dart     # Main config class
│       │   ├── config_loader.dart       # Dynamic config loading
│       │   ├── sidebar_config.dart      # Sidebar configuration
│       │   ├── theme_config.dart        # DarkModeConfig enum
│       │   ├── header_config.dart       # Header/NavLink config
│       │   ├── footer_config.dart       # Footer config
│       │   ├── component_config.dart    # Component registration
│       │   ├── versioning_config.dart   # Versioning config
│       │   └── custom_page.dart         # Custom page config
│       ├── core/
│       │   ├── project_generator.dart   # Generate user project files
│       │   └── site_generator.dart      # Generate .dart_tool site
│       └── theme/
│           ├── base_theme.dart          # Abstract theme interface
│           ├── default_theme.dart       # Flutter-docs style theme
│           ├── theme_colors.dart        # Color configuration
│           └── theme_typography.dart    # Typography configuration
└── pubspec.yaml
```

---

## Files (All Implemented)

```
lib/src/
├── cli/
│   ├── cli_runner.dart              # ✅ CommandRunner setup
│   ├── errors.dart                  # ✅ Error handling utilities
│   └── commands/
│       ├── init_command.dart        # ✅ docudart init
│       ├── build_command.dart       # ✅ docudart build
│       └── serve_command.dart       # ✅ docudart serve
├── core/
│   ├── content_processor.dart       # ✅ Process docs/ folder
│   ├── readme_parser.dart           # ✅ Parse README.md sections
│   ├── file_watcher.dart            # ✅ Hot reload support
│   ├── site_generator.dart          # ✅ Generate Jaspr site
│   ├── project_generator.dart       # ✅ Generate user project
│   └── version_manager.dart         # ✅ Handle versioning
├── components/
│   ├── component_registry.dart      # ✅ Component registration
│   ├── component_discovery.dart     # ✅ Auto-discover components
│   └── built_in/
│       ├── callout.dart             # ✅ Info/Warning/Tip boxes
│       ├── tabs.dart                # ✅ Tabbed content
│       ├── code_block.dart          # ✅ Syntax-highlighted code
│       └── version_switcher.dart    # ✅ Version dropdown
├── markdown/
│   ├── markdown_processor.dart      # ✅ Main markdown pipeline
│   ├── component_parser.dart        # ✅ Parse <Component /> in md
│   └── frontmatter_handler.dart     # ✅ YAML frontmatter
├── theme/
│   ├── base_theme.dart              # ✅ Abstract theme interface
│   ├── default_theme.dart           # ✅ Flutter docs style theme
│   ├── theme_colors.dart            # ✅ Color configuration
│   ├── theme_typography.dart        # ✅ Typography configuration
│   └── theme_loader.dart            # ✅ Load custom YAML themes
└── routing/
    └── sidebar_generator.dart       # ✅ Generate sidebar
```

---

## Generated User Project Structure

When user runs `docudart init`:

```
user_project/
├── config.dart                    # Main configuration
├── docs/
│   ├── index.md                   # Landing doc
│   └── getting-started.md         # Additional docs
├── pages/
│   └── landing.dart               # Custom Dart landing page
├── components/
│   └── .gitkeep                   # For custom Jaspr components
├── assets/
│   └── .gitkeep                   # Images, files
├── themes/
│   └── .gitkeep                   # Custom themes
└── pubspec.yaml                   # Project dependencies
```

---

## config.dart API

```dart
import 'package:docudart/docudart.dart';

final config = DocuDartConfig(
  title: 'My Project Docs',
  description: 'Documentation for My Project',
  logo: 'assets/logo.svg',

  // Directories
  docsDir: 'docs',
  pagesDir: 'pages',
  assetsDir: 'assets',
  outputDir: 'build/web',

  // URLs
  baseUrl: '/',
  cleanUrls: true,

  // Theme
  theme: DefaultTheme(
    primaryColor: 0xFF0175C2,
    darkMode: DarkModeConfig.system,
  ),

  // Sidebar
  sidebar: SidebarConfig(
    autoGenerate: true,
    items: [
      SidebarSection(
        title: 'Getting Started',
        items: [
          SidebarLink(title: 'Introduction', path: '/docs/intro'),
        ],
      ),
    ],
  ),

  // Components
  components: ComponentConfig(
    autoDiscover: true,
    register: [],
  ),

  // Versioning
  versioning: VersioningConfig(
    enabled: true,
    versions: ['v1', 'v2'],
    defaultVersion: 'v2',
  ),

  // Custom pages
  customPages: [
    CustomPage(path: '/', filePath: 'pages/landing.dart'),
  ],

  // Header/Footer
  header: HeaderConfig(
    navLinks: [
      NavLink.internal(title: 'Docs', path: '/docs'),
      NavLink.external(title: 'GitHub', url: 'https://github.com/...'),
    ],
    showThemeToggle: true,
    showVersionSwitcher: true,
  ),

  footer: FooterConfig(
    copyright: '© 2024 My Project',
  ),
);
```

---

## Markdown Features

### YAML Frontmatter

```markdown
---
title: Getting Started
description: Learn how to use DocuDart
sidebar_position: 1
sidebar_title: Start Here
tags: [tutorial, beginner]
---

# Getting Started

Content here...
```

### Component Embedding (MDX-like)

```markdown
# My Page

<Callout type="info">
This is an informational note.
</Callout>

<Tabs>
  <Tab label="Dart">
    ```dart
    void main() => print('Hello');
    ```
  </Tab>
</Tabs>

<MyCustomComponent title="Feature" icon="star" />
```

### Built-in Components

| Component | Description |
|-----------|-------------|
| `<Callout>` | Info/warning/tip/danger boxes |
| `<Tabs>` | Tabbed content sections |
| `<Tab>` | Individual tab |
| `<CodeBlock>` | Enhanced code with copy button |

---

## Implementation Phases

### Phase 1: CLI Foundation ✅ COMPLETED
- [x] Set up `args` package with `CommandRunner`
- [x] Implement `init` command (default + full template)
- [x] Implement `build` command (basic)
- [x] Implement `serve` command (basic)
- [x] Define `DocuDartConfig` and all related classes
- [x] Create `ProjectGenerator` for init templates
- [x] Create basic `SiteGenerator` for managed Jaspr site

### Phase 2: Markdown Processing ✅ COMPLETED
- [x] Implement `FrontmatterHandler` - parse YAML frontmatter
- [x] Implement `MarkdownProcessor` - convert MD to HTML/components
- [x] Implement `ComponentParser` - parse `<Component />` syntax in MD
- [x] Integrate `markdown` package for parsing

### Phase 3: Content Processing ✅ COMPLETED
- [x] Implement `ContentProcessor` - process all docs/ files
- [x] Implement route generation from docs (in SiteGenerator)
- [x] Implement `SidebarGenerator` - auto-generate sidebar from structure
- [x] Handle nested folders and ordering

### Phase 4: Theme System Enhancement ✅ COMPLETED (Basic)
- [x] `BaseTheme` interface defined
- [x] `DefaultTheme` with Flutter docs style colors
- [x] Dark mode via CSS media query (system preference)
- [x] Complete CSS generation from theme configuration

### Phase 5: Managed Site Generation Enhancement ✅ COMPLETED
- [x] Complete `SiteGenerator` to render actual markdown content
- [x] Generate proper Jaspr components from processed content
- [x] Implement hot reload file watching
- [x] Handle asset copying and path resolution

### Phase 6: Component System ✅ COMPLETED
- [x] Implement `ComponentRegistry` with factory pattern
- [x] Implement `ComponentDiscovery` for auto-discovery
- [x] Create built-in components (Callout, Tabs, CodeBlock, Card, CardGrid)
- [x] Component embedding in markdown rendering
- [x] Component CSS styles in generated output

### Phase 7: Versioning ✅ COMPLETED
- [x] Implement `VersionManager`
- [x] Version switcher component
- [x] Versioned routes (`/v1/docs/...`)
- [x] Version folder structure

### Phase 8: Polish ✅ COMPLETED
- [x] Error handling with helpful messages
- [x] README.md parsing for init (ReadmeParser with smart section extraction)
- [x] Custom theme loading (ThemeLoader from YAML files)
- [x] Basic test suite (config, theme, markdown, README parser tests)
- [ ] Performance optimization (deferred to future)

---

## Critical Files Reference

### CLI Entry Point
**File:** `bin/docudart.dart`
```dart
import 'dart:io';
import 'package:docudart/src/cli/cli_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = DocuDartCliRunner();
  final exitCode = await runner.run(arguments);
  exit(exitCode);
}
```

### Main Config Class
**File:** `lib/src/config/docudart_config.dart`
- Main configuration class with all options
- Uses `@immutable` pattern
- Has `copyWith` method for modifications

### Project Generator
**File:** `lib/src/core/project_generator.dart`
- `InitTemplate` enum (defaultTemplate, full)
- `generate()` method creates all project files
- Parses README.md into sections for docs
- Creates config.dart, landing page, example docs

### Site Generator
**File:** `lib/src/core/site_generator.dart`
- Creates managed Jaspr project in `.dart_tool/docudart/`
- Generates: pubspec.yaml, main.dart, app.dart, styles.css
- Generates: home_page.dart, docs_page.dart, layout.dart
- Copies docs and assets

### Theme Classes
**File:** `lib/src/theme/default_theme.dart`
- Extends `BaseTheme`
- Flutter docs style colors
- Dark mode support via `ThemeColors`

---

## Dependencies

```yaml
dependencies:
  args: ^2.4.0           # CLI argument parsing
  path: ^1.8.0           # Path manipulation
  glob: ^2.1.0           # File pattern matching
  watcher: ^1.1.0        # File watching for hot reload
  yaml: ^3.1.0           # YAML/frontmatter parsing
  markdown: ^7.2.0       # Markdown parsing
  jaspr: ^0.22.0         # Web framework
  collection: ^1.18.0    # Collection utilities
  meta: ^1.11.0          # Annotations
```

---

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Dart config (not YAML) | IntelliSense, type safety, familiar to Dart devs |
| Managed site in .dart_tool/ | Keep user project clean, isolate generated code |
| Build on Jaspr | Proven SSG engine, Dart ecosystem, component system |
| Component auto-discovery | Convention over configuration, less boilerplate |
| Theme as Dart class | Full customization power, IDE support |
| Flutter docs style default | Familiar to Dart/Flutter developers |

---

## Testing Commands

```bash
# Run CLI help
dart run bin/docudart.dart --help

# Test init in temp directory
mkdir /tmp/test-project
cd /tmp/test-project
dart run /path/to/docudart/bin/docudart.dart init --full

# Test build
dart run bin/docudart.dart build

# Test serve
dart run bin/docudart.dart serve
```

---

## Next Implementation Priority

1. **Markdown Processing** - Get actual markdown rendering working
2. **Content Processing** - Process all docs and generate proper pages
3. **Sidebar Generation** - Auto-generate sidebar from folder structure
4. **Hot Reload** - File watching for development

These are the core features needed for a functional documentation generator.
