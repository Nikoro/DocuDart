---
title: Configuration
sidebar_position: 4
---

# Configuration

DocuDart uses a `config.dart` file for type-safe configuration — not YAML. Your config exports a `configure()` function that receives a `BuildContext` with access to project data.

## Basic config

```dart
import 'package:docudart/docudart.dart';

Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  description: context.project.pubspec.description,
  siteUrl: 'https://my-docs.dev',
  themeMode: .system,
  theme: .classic(),
  home: () => LandingPage(),
  header: () => Header(
    leading: Logo(title: context.project.pubspec.name),
    links: [.path('/docs', label: 'Docs')],
  ),
  footer: () => Footer(
    center: Copyright(text: context.project.pubspec.name),
  ),
  sidebar: () => context.url.contains('/docs') ? Sidebar() : null,
);
```

## Config fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `title` | `String?` | from pubspec | Site title |
| `description` | `String?` | from pubspec | SEO description |
| `siteUrl` | `String?` | `null` | Base URL — enables sitemap, robots.txt, canonical URLs, Open Graph |
| `theme` | `Theme` | `.classic()` | Visual theme preset |
| `themeMode` | `ThemeMode` | `.system` | `system`, `light`, or `dark` |
| `docsDir` | `String` | `'docs'` | Markdown docs directory |
| `assetsDir` | `String` | `'assets'` | Static assets directory |
| `outputDir` | `String` | `'build/web'` | Build output directory |
| `home` | `Component? Function()?` | `null` | Home page component |
| `header` | `Component? Function()?` | `null` | Header component |
| `footer` | `Component? Function()?` | `null` | Footer component |
| `sidebar` | `Component? Function()?` | `null` | Sidebar component |

## Context data

The `BuildContext` gives you access to project metadata through `context.project`:

```dart
context.project.pubspec.name          // Package name
context.project.pubspec.version       // Package version
context.project.pubspec.description   // Package description
context.project.pubspec.repository    // Repository with auto-detected label + icon
context.project.pubspec.topics        // List<String> topics
context.project.docs                  // List<Doc> sidebar tree
context.project.pages                 // List<Page> custom pages
context.project.changelog             // Changelog? (raw HTML + TOC)
context.project.assets                // Type-safe asset tree
context.project.license               // License? (type, holder, year)
context.url                           // Current URL path
```

## Conditional rendering

Both the function itself and its return value can be `null`. If either is null, the section isn't rendered:

```dart
// Show sidebar only on docs pages
sidebar: () => context.url.contains('/docs') ? Sidebar() : null,

// No footer at all
footer: null,
```

## Hiding sections

Set any layout function to `null` to hide that section entirely:

```dart
Config configure(BuildContext context) => Config(
  title: 'My Docs',
  header: () => Header(leading: Logo(title: 'My Docs')),
  footer: null,     // No footer
  sidebar: null,    // No sidebar
  home: null,       // Redirect '/' to '/docs'
);
```

When `home` is `null`, visiting `/` redirects to `/docs`.
