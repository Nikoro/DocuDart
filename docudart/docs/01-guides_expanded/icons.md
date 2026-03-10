---
title: Icons
sidebar_position: 3
---

# Icons

DocuDart includes 52,000+ icons from 7 icon families, rendered as inline SVGs.

## Usage

```dart
Icon(MaterialSymbols.home)
Icon(LucideIcons.arrow_right)
Icon(FontAwesomeIcons.github_brand)
```

Icons inherit `currentColor` from their parent, so they adapt to theme colors automatically.

## Icon families

| Family | Class | Count | Style |
|--------|-------|-------|-------|
| Material Symbols | `MaterialSymbols` | ~22,884 | Google's latest icon set |
| Material Icons | `MaterialIcons` | ~10,955 | Classic Material Design (frozen) |
| Tabler | `TablerIcons` | ~5,986 | Clean outline + filled |
| Fluent | `FluentIcons` | ~5,074 | Microsoft Fluent UI |
| Remix | `RemixIcons` | ~3,228 | Line + filled |
| Font Awesome | `FontAwesomeIcons` | ~2,860 | Solid, regular, brands |
| Lucide | `LucideIcons` | ~1,669 | Stroke-based |

## Style variants

Most families have multiple styles. The default style has no suffix:

```dart
// Material Symbols
MaterialSymbols.home           // outlined (default)
MaterialSymbols.home_filled    // filled
MaterialSymbols.home_rounded   // rounded
MaterialSymbols.home_sharp     // sharp

// Tabler
TablerIcons.home               // outline (default)
TablerIcons.home_filled        // filled

// Font Awesome
FontAwesomeIcons.house         // solid (default)
FontAwesomeIcons.house_regular // regular (lighter)
FontAwesomeIcons.github_brand  // brand icon

// Remix
RemixIcons.home                // line (default)
RemixIcons.home_fill           // filled
```

## Naming convention

All icon identifiers use `snake_case`:

- Hyphens become underscores: `arrow-right` → `arrow_right`
- Numeric-leading names get `icon_` prefix: `10k` → `icon_10k`
- Brand icons use `_brand` suffix: `github` → `github_brand`

## IDE support

Every icon has a base64-encoded SVG preview in its doc comment, so you can see icon previews in your IDE's tooltip/hover documentation.
