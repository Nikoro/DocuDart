---
title: Theming
sidebar_position: 1
---

# Theming

DocuDart comes with three built-in theme presets. Each defines colors, typography, component styles, and syntax highlighting.

## Presets

| Preset | Primary Color | Font | Style |
|--------|--------------|------|-------|
| `.classic()` | Blue (#0175C2) | Inter | Clean, documentation-focused |
| `.material3()` | Purple (#6750A4) | Roboto | Material Design 3 |
| `.shadcn()` | Near-black (#18181B) | Inter | Minimal, shadcn/ui-inspired |

Set the theme in `config.dart`:

```dart
theme: .classic(),    // Blue documentation theme (default)
theme: .material3(),  // Material Design 3
theme: .shadcn(),     // Minimal dark-accented
```

## Seed colors

Override the default primary color with a seed color. DocuDart generates a harmonious palette from the seed:

```dart
theme: .classic(seedColor: Colors.indigo),
theme: .material3(seedColor: Colors.teal),
theme: .shadcn(seedColor: Color.value(0xFF006D40)),
```

When a seed color is provided, the entire color scheme is derived from it using HSL-based palette generation.

## Theme mode

Control dark mode behavior:

```dart
themeMode: .system,  // Follow system preference (default)
themeMode: .light,   // Always light
themeMode: .dark,    // Always dark
```

Users can still toggle the theme manually via the `ThemeToggle` component.

## How it works

Each theme preset configures:

- **ColorScheme** — 13 color variables for light and dark modes, exposed as CSS custom properties (`--color-primary`, `--color-surface`, etc.)
- **TextTheme** — Font family, heading sizes, weights, and line heights
- **MarkdownTheme** — Content spacing, code block backgrounds, and syntax highlighting colors
- **Component themes** — Per-component styling for sidebar, header, footer, buttons, cards, and more

Dark mode works via the `data-theme="dark"` attribute on `<html>`. All colors switch through CSS variables — no JavaScript repainting.

## Syntax highlighting

Code blocks use build-time highlighting via Opal. Each preset selects its own code theme:

| Preset | Light Theme | Dark Theme |
|--------|------------|------------|
| `.classic()` | dart.dev Light | dart.dev Dark |
| `.material3()` | Material Light | Nord |
| `.shadcn()` | GitHub Light | Night Owl |
