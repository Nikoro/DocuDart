# Theme System

The theme subsystem defines the visual identity of generated DocuDart sites. A `Theme` aggregates 11 sub-themes into a single immutable object, mirroring Flutter's `ThemeData` pattern.

## Files

| File | Class | Purpose |
|------|-------|---------|
| `theme.dart` | `Theme` | Top-level theme with 3 preset factories (classic, material3, shadcn) |
| `color_scheme.dart` | `ColorScheme` | 13 colors (light + dark) with preset and seed-based constructors |
| `color_resolver.dart` | `resolveColor()` | Converts `Color` → `int` (0xAARRGGBB) via CSS value parsing |
| `color_utils.dart` | `HSL` | HSL ↔ ARGB conversion for seed-based palette generation |
| `text_theme.dart` | `TextTheme` | Typography: fonts, heading sizes, weights, line-heights |
| `text_style.dart` | `TextStyle` | Individual text style → CSS properties |
| `markdown_theme.dart` | `MarkdownTheme` | Content spacing, borders, code theme selection |
| `code_theme.dart` | `CodeTheme` | Syntax highlighting (14 token colors for opal build-time highlighting) |
| `sidebar_theme.dart` | `SidebarTheme` | Sidebar dimensions, active link style, hover colors |
| `header_theme.dart` | `HeaderTheme` | Header padding, box shadow |
| `footer_theme.dart` | `FooterTheme` | Footer padding |
| `logo_theme.dart` | `LogoTheme` | Logo font size, weight, image height |
| `button_theme.dart` | `ButtonTheme` | Button padding, radius, hover effect (brightness/opacity) |
| `card_theme.dart` | `CardTheme` | Card padding, radius, shadow, hover effect (shadow/borderHighlight) |
| `callout_theme.dart` | `CalloutTheme` | Callout padding, radius, border width |
| `icon_button_theme.dart` | `IconButtonTheme` | Icon button padding, radius, icon size |
| `landing_theme.dart` | `LandingTheme` | Landing page padding, title/description font sizes |
| `theme_loader.dart` | `ThemeLoader` | YAML theme loading (legacy) |

## Presets

Each preset has its own default ColorScheme, TextTheme, MarkdownTheme, and per-component themes:

| Preset | Primary (light) | Font | Sidebar Active | Button | Dark Code Theme |
|--------|----------------|------|---------------|--------|----------------|
| `classic` | Blue (#0175C2) | Inter | Left border + primary tint | Rounded | dart.dev Dark |
| `material3` | Purple (#6750A4) | Roboto | Pill-shaped filled bg | Pill + shadow | Nord |
| `shadcn` | Near-black (#18181B) | Inter | Left border + neutral fill | Sharp corners | Night Owl |

When a `seedColor` is provided, all presets use `ColorScheme.fromSeed()` instead of their handcrafted defaults.

## CSS Generation Flow

```
Config.theme (Theme object)
  ├─ lightColorScheme.cssVariables → :root { --color-*: ... }
  ├─ darkColorScheme.cssVariables → :root[data-theme="dark"] { --color-*: ... }
  ├─ textTheme.cssVariables → :root { --font-family, --font-size-base, etc. }
  ├─ textTheme.h1–h4 → .docs-content h1–h4 { font-size, font-weight, ... }
  ├─ markdownTheme → inline code, blockquote, table, list spacing
  ├─ markdownTheme.lightCodeTheme → pre.opal { background, color } (via StylesGenerator)
  ├─ markdownTheme.darkCodeTheme → :root[data-theme="dark"] pre.opal span { color: var(--dd-dark-color) }
  ├─ sidebarTheme → sidebar width, padding, active link style, hover colors
  ├─ headerTheme → header padding, box shadow
  ├─ footerTheme → footer padding
  ├─ logoTheme → logo font size, weight, image height
  ├─ buttonTheme → button padding, radius, hover effect
  ├─ cardTheme → card padding, radius, shadow, hover effect
  ├─ calloutTheme → callout padding, radius, border width
  ├─ iconButtonTheme → icon button padding, radius
  └─ landingTheme → landing page padding, title/description sizes
```

`StylesGenerator` reads per-component theme properties directly — no `theme.name` conditionals. Each preset encodes its visual differences as data in the theme objects (e.g., `ButtonTheme.material3()` uses brightness hover, `CardTheme.shadcn()` uses border-highlight hover).

## Key Patterns

- **Immutable + copyWith**: All theme classes are `@immutable` with `copyWith()`, `toJson()`, `fromJson()`
- **Seed-based generation**: `ColorScheme.fromSeed()` extracts hue via HSL, generates harmonious palette
- **CSS variables**: Colors are exposed as `--color-*` variables, enabling dark mode via `data-theme` attribute
- **Theme toggle**: `theme.js` toggles `data-theme` on `<html>`, CSS handles the rest
