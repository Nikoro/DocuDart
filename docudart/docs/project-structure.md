---
title: Project Structure
sidebar_position: 2
---

# Project Structure

When you run `docudart create --full`, the following directory structure is created:

```
your-project/
├── docudart/
│   ├── config.dart          # Type-safe configuration
│   ├── labels.dart          # String constants (reusable labels)
│   ├── pubspec.yaml         # Dependencies (path dep to parent)
│   ├── docs/                # Markdown documentation
│   │   ├── index.md
│   │   ├── getting-started.md
│   │   └── 01-guides_expanded/
│   │       └── components.md
│   ├── pages/               # Custom Dart pages
│   │   ├── landing_page.dart
│   │   └── changelog_page.dart
│   ├── components/          # Reusable components
│   │   ├── header.dart
│   │   ├── footer.dart
│   │   ├── sidebar.dart
│   │   └── button.dart
│   ├── assets/              # Static assets
│   │   ├── light/logo/      # Light mode logo
│   │   ├── dark/logo/       # Dark mode logo
│   │   └── favicon/         # Favicon files
│   └── themes/              # Custom themes (optional)
├── pubspec.yaml             # Your project's pubspec
├── CHANGELOG.md             # Auto-detected for changelog page
└── lib/                     # Your project's code
```

## Key directories

### `docs/`

Markdown files with YAML frontmatter. Each `.md` file becomes a page. Subdirectories become sidebar categories.

### `pages/`

Custom Dart pages using Jaspr components. Files are auto-discovered — add a `.dart` file and link to it from your header. The filename determines the route: `pages/changelog_page.dart` maps to `/changelog`.

### `components/`

Reusable Dart components for your header, footer, sidebar, and any custom UI. These are referenced from `config.dart`.

### `assets/`

Static files copied to the build output. Place logos in `assets/light/` and `assets/dark/` for automatic theme-aware switching. Favicons go in `assets/favicon/`.

### `themes/`

Reserved for custom theme definitions (optional).

## Build output

After running `docudart build`, the output goes to `docudart/build/web/`:

```
docudart/build/web/
├── index.html           # Home page
├── docs/                # Documentation pages (clean URLs)
│   ├── index.html
│   └── getting-started/
│       └── index.html
├── changelog/
│   └── index.html
├── styles.css           # Theme styles
├── theme.js             # Theme toggle + sidebar + utilities
├── sitemap.xml          # Generated when siteUrl is set
├── robots.txt           # Generated when siteUrl is set
└── assets/              # Static assets
```

## Generated internals

DocuDart creates a managed Jaspr project at `docudart/.dart_tool/docudart/`. This is auto-generated on every build — don't edit files there. The `.gitignore` should exclude both `.dart_tool/` and `build/`.
