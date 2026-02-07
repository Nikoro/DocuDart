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
