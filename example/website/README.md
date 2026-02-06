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
