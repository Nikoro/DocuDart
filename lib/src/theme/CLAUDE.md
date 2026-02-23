# Theme System

The theme subsystem defines the visual identity of generated DocuDart sites. A `Theme` bundles 5 sub-themes into a single immutable object.

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
| `code_theme.dart` | `CodeTheme` | Syntax highlighting (13 token colors for highlight.js) |
| `component_theme.dart` | `ComponentTheme` | Component dimensions (sidebar, header, footer, cards, buttons) |
| `theme_loader.dart` | `ThemeLoader` | YAML theme loading (legacy) |

## Presets

Each preset has its own default ColorScheme, TextTheme, MarkdownTheme, and ComponentTheme:

| Preset | Primary (light) | Font | Sidebar Active | Button | Dark Code Theme |
|--------|----------------|------|---------------|--------|----------------|
| `classic` | Blue (#0175C2) | Inter | Left border + primary tint | Rounded | GitHub Dark |
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
  ├─ markdownTheme.lightCodeTheme.toCss() → .hljs { ... }
  ├─ markdownTheme.darkCodeTheme.toCss() → :root[data-theme="dark"] .hljs { ... }
  ├─ componentTheme → sidebar width, padding, border-radius, etc.
  └─ theme.name → theme-specific CSS (sidebar style, button style, card hover)
```

`StylesGenerator` reads `theme.name` to emit structurally different CSS per preset (e.g., Material3 sidebar has no right border, shadcn buttons use `opacity` hover).

## Key Patterns

- **Immutable + copyWith**: All theme classes are `@immutable` with `copyWith()`, `toJson()`, `fromJson()`
- **Seed-based generation**: `ColorScheme.fromSeed()` extracts hue via HSL, generates harmonious palette
- **CSS variables**: Colors are exposed as `--color-*` variables, enabling dark mode via `data-theme` attribute
- **Theme toggle**: `theme.js` toggles `data-theme` on `<html>`, CSS handles the rest
