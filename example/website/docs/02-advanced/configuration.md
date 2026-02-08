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
final init = setup((project) => Config(
  title: project.pubspec.name,
  header: () => Header(title: project.pubspec.name),
  footer: null,    // No footer
  sidebar: null,   // No sidebar
));
```
