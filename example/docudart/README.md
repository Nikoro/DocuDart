# example_project - Documentation Site

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
    primaryColor: 0xFF0175C2,   // custom primary color
  ),

  // Layout components (set to null to hide)
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: () => Footer(center: Copyright(text: context.project.pubspec.name)),
  sidebar: () => Sidebar(),
);
```

## Build Output

Running `docudart build` generates static files in `build/web/`. You can deploy this directory to any static hosting provider (GitHub Pages, Netlify, Vercel, Firebase Hosting, etc.).
