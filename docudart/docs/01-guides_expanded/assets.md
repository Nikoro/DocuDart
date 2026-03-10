---
title: Assets
sidebar_position: 5
---

# Assets

DocuDart generates a type-safe asset tree from your `assets/` directory.

## Usage

Access assets through `context.project.assets`:

```dart
// As a Component (renders <img>)
context.project.assets.logo.logo_webp(alt: 'My logo')

// As a String path
context.project.assets.logo.logo_webp.path
```

`Asset` objects are callable — calling them returns an `<img>` Component. Use `.path` when you need the raw URL string.

## Theme-aware assets

Place assets in `assets/light/` and `assets/dark/` subdirectories for automatic theme switching:

```
assets/
  light/
    logo/
      logo.webp       # Shown in light mode
  dark/
    logo/
      logo.webp       # Shown in dark mode
  favicon/
    favicon.ico       # Same in both modes
```

Theme-aware assets render both `<img>` elements wrapped in a `<span class="theme-asset">`. CSS toggles visibility based on the active theme — no JavaScript involved.

Assets outside `light/` and `dark/` directories are simple assets, displayed in both modes.

## Favicons

Place favicon files in `assets/favicon/`. DocuDart supports:

- `favicon.ico`
- `favicon-16x16.png`
- `favicon-32x32.png`
- `apple-touch-icon.png`
- `android-chrome-192x192.png`
- `android-chrome-512x512.png`

These are copied to the build output root.

## Generated asset tree

The asset tree is auto-generated during build. Each file becomes a typed accessor:

```
assets/
  light/logo/logo.webp  →  context.project.assets.logo.logo_webp
  images/hero.png        →  context.project.assets.images.hero_png
```

File extensions are included in the accessor name (dots become underscores), so `logo.webp` becomes `logo_webp`.
