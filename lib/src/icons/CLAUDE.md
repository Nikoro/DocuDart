# Icons Directory — Agent Instructions

This directory contains a local fork of the `jaspr_icons` package, maintained in-tree because the published `jaspr_icons` on pub.dev is **incompatible with Jaspr 0.22**. The hand-written files (`icon.dart`, `helpers.dart`) have been updated for compatibility; the icon data files are generated.

## File Overview

| File | Type | Description |
|------|------|-------------|
| `helpers.dart` | Hand-written | `IconData` class + `StrokeLineJoin` / `StrokeLineCap` enums |
| `icon.dart` | Hand-written | `Icon` component (`StatelessComponent` → renders SVG) |
| `icons.dart` | Hand-written | Barrel file re-exporting everything |
| `lucide_icons.dart` | Generated | Lucide icons (stroke-based) |
| `material_icons.dart` | Generated | Google Material Design Icons (classic, frozen) |
| `material_symbols.dart` | Generated | **NEW** — Google Material Symbols (active successor to Material Icons) |
| `tabler_icons.dart` | Generated | Tabler icons (outline + filled) |
| `fluent_icons.dart` | Generated | Microsoft Fluent UI System icons (24px) |
| `font_awesome_icons.dart` | Generated | Font Awesome free icons |
| `remix_icons.dart` | Generated | Remix icons (line + filled) |

Exported via `lib/docudart.dart` → `export 'src/icons/icons.dart'`.

**IMPORTANT**: Do NOT modify `helpers.dart`, `icon.dart`, or `icons.dart` as part of icon data generation. These are hand-written. Only the `*_icons.dart` / `*_symbols.dart` files are generated.

---

## Unified Naming Convention

**All icon datasets MUST follow a unified naming pattern**, similar to Flutter's `Icons` class where you access icons as `Icons.home`, `Icons.arrow_back`, etc.

### Rules

1. **All icon identifiers use `snake_case`** — no prefixes, no style prefixes
2. **Style variants use suffixes**: `_outlined`, `_rounded`, `_sharp`, `_filled`, `_regular`, etc.
3. **Base/default style has NO suffix** — the most common variant is the bare name
4. **Numeric-leading names get `icon_` prefix** — Dart identifiers can't start with digits: `10k.svg` → `icon_10k`
5. **Hyphens → underscores**: `arrow-right.svg` → `arrow_right`

### Per-Family Naming

| Family | Base style (no suffix) | Variant suffixes | Examples |
|--------|----------------------|-----------------|----------|
| **Lucide** | stroke (only style) | None | `home`, `arrow_down`, `a_arrow_down` |
| **Material Icons** | baseline | `_outlined`, `_rounded`, `_sharp`, `_twotone` | `home`, `home_outlined`, `home_rounded`, `home_sharp`, `home_twotone` |
| **Material Symbols** | outlined (default) | `_filled`, `_rounded`, `_sharp`, `_rounded_filled`, `_sharp_filled` | `home`, `home_filled`, `home_rounded`, `home_sharp` |
| **Tabler** | outline | `_filled` | `home`, `home_filled`, `abacus`, `abacus_filled` |
| **Fluent** | regular | `_filled`, `_color` | `access_time`, `access_time_filled`, `add_circle_color` |
| **Font Awesome** | solid (default) | `_regular`, `_brand` | `house`, `house_regular`, `github_brand`, `apple_brand` |
| **Remix** | line (default) | `_fill` | `home`, `home_fill`, `account_box`, `account_box_fill` |

### Examples

| Family | Usage |
|--------|-------|
| `LucideIcons.home` | Lucide stroke icon |
| `MaterialIcons.home` | Material baseline |
| `MaterialIcons.home_outlined` | Material outlined variant |
| `MaterialSymbols.home` | Material Symbols outlined (default) |
| `MaterialSymbols.home_filled` | Material Symbols filled |
| `TablerIcons.home` | Tabler outline (default) |
| `TablerIcons.home_filled` | Tabler filled variant |
| `FluentIcons.home` | Fluent regular (default) |
| `FluentIcons.home_filled` | Fluent filled variant |
| `FontAwesomeIcons.house` | Font Awesome solid (default) |
| `FontAwesomeIcons.github_brand` | Font Awesome brand |
| `RemixIcons.home` | Remix line (default) |
| `RemixIcons.home_fill` | Remix filled variant |

---

## Icon Datasets — Current Status & Upstream Info

### 1. Lucide Icons (`lucide_icons.dart`)

- **Current count**: 1,669
- **Upstream count**: ~1,669
- **Gap**: None (up to date)
- **Repo**: https://github.com/lucide-icons/lucide
- **SVG path**: `icons/*.svg`
- **SVG naming**: kebab-case (`a-arrow-down.svg`, `home.svg`)
- **License**: ISC
- **Styles**: Single (stroke-based) — no variants
- **Class**: `LucideIcons`
- **Root attrs**: `viewBox: '0 0 24 24'`, `fill: 'none'`, `stroke: 'currentColor'`, `stroke-width: '2'`, `stroke-linecap: 'round'`, `stroke-linejoin: 'round'`
- **Family tag**: `'lucide'`

### 2. Material Design Icons (`material_icons.dart`) — FROZEN

- **Current count**: 10,955 (2,191 unique × 5 styles)
- **Upstream count**: ~10,955 (frozen, no longer updated by Google)
- **Gap**: None
- **Repo**: https://github.com/google/material-design-icons
- **License**: Apache 2.0
- **Styles**: 5 — baseline, outlined, rounded, sharp, twotone
- **Class**: `MaterialIcons`
- **Root element**: NONE — no `'tag': 'root'`; paths go directly
- **Status**: Classic set is **frozen**. Succeeded by Material Symbols. Still update naming to unified convention.

### 3. Material Symbols (`material_symbols.dart`)

- **Current count**: 22,884 (~3,814 unique × up to 6 variants)
- **Repo**: https://github.com/google/material-design-icons (`symbols/` directory)
- **Community mirror** (cleaner structure): https://github.com/marella/material-symbols
  - SVGs at: `svg/400/outlined/*.svg`, `svg/400/rounded/*.svg`, `svg/400/sharp/*.svg`
  - Filled variants: `*-fill.svg` suffix
- **NPM** (alternative source): `@material-symbols/svg-400`
- **SVG naming**: snake_case (`home.svg`, `home-fill.svg`, `account_circle.svg`)
- **License**: Apache 2.0
- **Styles**: 3 base styles × 2 fill states = 6 variants per icon:
  - `outlined` (default — no suffix in our naming)
  - `outlined` + filled → `_filled`
  - `rounded` → `_rounded`
  - `rounded` + filled → `_rounded_filled`
  - `sharp` → `_sharp`
  - `sharp` + filled → `_sharp_filled`
- **Class**: `MaterialSymbols`
- **Family tag**: `'material_symbols'`
- **Root attrs**: `viewBox: '0 -960 960 960'` (no fill/stroke — paths have implicit fill)
- **IMPORTANT**: Use weight 400 only (default). Skip weight/grade/optical-size variations to keep file size manageable. Use 24px optical size.
- **Key difference from Material Icons**: Variable font axes (fill, weight, grade, optical size). We only care about fill (0/1) and the 3 base styles at default weight 400.

### 4. Tabler Icons (`tabler_icons.dart`)

- **Current count**: 5,986
- **Upstream count**: ~5,986
- **Gap**: None (up to date)
- **Repo**: https://github.com/tabler/tabler-icons
- **SVG paths**: `icons/outline/*.svg` and `icons/filled/*.svg`
- **SVG naming**: kebab-case (`accessible.svg`, `ad-circle.svg`)
- **License**: MIT
- **Styles**: 2 — outline (base, no suffix) + filled (`_filled`)
- **Class**: `TablerIcons`
- **Family tag**: `'tabler'`
- **Root attrs (outline)**: `viewBox: '0 0 24 24'`, `fill: 'none'`, `stroke: 'currentColor'`, `stroke-width: '2'`, `stroke-linecap: 'round'`, `stroke-linejoin: 'round'`
- **Root attrs (filled)**: `viewBox: '0 0 24 24'`, `fill: 'currentColor'`

### 5. Fluent UI System Icons (`fluent_icons.dart`)

- **Current count**: 5,074 (24px subset)
- **Upstream count**: ~5,100+ at 24px (continuously updated)
- **Gap**: Small
- **Repo**: https://github.com/microsoft/fluentui-system-icons
- **SVG path**: `assets/<IconName>/SVG/<icon_name>_24_<style>.svg`
- **SVG naming**: snake_case with size and style (`access_time_24_filled.svg`)
- **License**: MIT
- **Styles**: regular (base, no suffix), filled (`_filled`), color (`_color`)
- **Size filter**: **24px only** — filter filenames containing `_24_`; skip 16/20/28/32/48
- **Class**: `FluentIcons`
- **Family tag**: `'fluent'`
- **Root attrs**: `viewBox: '0 0 24 24'`, `fill: 'none'` (each child path has `fill: 'currentColor'`)
- **Fill handling**: Upstream SVGs use hardcoded `fill="#212121"` on paths. Generator replaces these with `currentColor` via `_replaceHardcodedFills()` for theming support.

### 6. Font Awesome Free (`font_awesome_icons.dart`)

- **Current count**: 2,860 free icons (solid: ~2,000 + regular: ~273 + brands: ~587)
- **Repo**: https://github.com/FortAwesome/Font-Awesome (branch: `7.x`)
- **SVG paths**:
  - `svgs/solid/*.svg` — filled icons (base, no suffix)
  - `svgs/regular/*.svg` — outline/lighter weight (`_regular` suffix)
  - `svgs/brands/*.svg` — company/service logos (`_brand` suffix)
- **SVG naming**: kebab-case (`arrow-right.svg`, `house.svg`, `github.svg`)
- **License**: Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT
- **Styles**: solid (base, no suffix), regular (`_regular`), brands (`_brand`)
- **Class**: `FontAwesomeIcons`
- **Family tag**: `'font_awesome'`
- **Root attrs**: `viewBox: '0 0 {width} 512'` (varies per icon — e.g. `0 0 384 512`, `0 0 448 512`, `0 0 640 512`); paths have `fill: 'currentColor'`
- **IMPORTANT**: Only free icons. Do NOT include Pro, Sharp, Duotone, or any paid variants. The `svgs/` directory in the repo contains only free icons. The `svgs-full/` directory may contain Pro icons — avoid it.
- **Brand icons**: These are company logos (github, apple, twitter, etc.). Use `_brand` suffix to distinguish from similarly-named non-brand icons.

### 7. Remix Icons (`remix_icons.dart`)

- **Current count**: 3,228
- **Upstream count**: ~3,228
- **Gap**: None (up to date)
- **Repo**: https://github.com/nicedoc/remixicon (or https://github.com/nicedoc/remixicon-npm)
- **SVG paths**: `icons/<Category>/*.svg`
- **SVG naming**: kebab-case (`arrow-right-line.svg`, `home-fill.svg`)
- **License**: Apache 2.0
- **Styles**: 2 — line (base, no suffix) + fill (`_fill`)
- **Class**: `RemixIcons`
- **Family tag**: `'remix'`
- **Root attrs**: `viewBox: '0 0 24 24'`, `fill: 'currentColor'`

---

## Icon Data Format Specification

### Structure

Each icon is a `static const IconData` containing a `List<Map<String, dynamic>>`:

```dart
static const IconData icon_name = IconData([
  // Optional root element (metadata + default SVG attributes)
  {
    'tag': 'root',
    'family': '<family>',       // 'lucide', 'tabler', 'fluent', 'material_symbols', 'font_awesome', 'remix'
    'attrs': { ... },           // default SVG attributes from <svg> element
  },
  // One or more SVG child elements
  {
    'tag': 'path',              // or 'circle', 'rect', 'line', 'polyline', 'polygon', 'ellipse', 'g', 'defs'
    'attrs': {
      'd': r'''M10 10.5h1.5...''',
      // ... other SVG attributes
    },
  },
]);
```

### Root Element Rules

| Family | Has root? | Family tag | viewBox | Notes |
|--------|----------|-----------|---------|-------|
| Lucide | Yes | `'lucide'` | `0 0 24 24` | Stroke-based defaults |
| Material Icons | **No** | N/A | default `0 0 24 24` | Bare path elements only |
| Material Symbols | Yes | `'material_symbols'` | `0 -960 960 960` | Fill-based, no stroke attrs |
| Tabler | Yes | `'tabler'` | `0 0 24 24` | Different attrs for outline vs filled |
| Fluent | Yes | `'fluent'` | `0 0 24 24` | `fill: 'none'` on root; `fill: 'currentColor'` on paths (hardcoded fills replaced by generator) |
| Font Awesome | Yes | `'font_awesome'` | varies (e.g. `0 0 384 512`) | Per-icon viewBox; paths have `fill: 'currentColor'` |
| Remix | Yes | `'remix'` | `0 0 24 24` | Fill-based; `fill: 'currentColor'` |

### SVG Element Tags Used

Besides `path` (most common), these SVG tags may appear:
`circle`, `rect`, `ellipse`, `line`, `polyline`, `polygon`, `g` (group), `defs`

### String Encoding

All attribute values MUST use raw string literals: `r'''value'''`

This avoids escaping issues with SVG path data.

### Doc Comment Format

Every icon has a base64-encoded SVG preview in its doc comment:
```dart
/// <img src="data:image/svg+xml;base64,<BASE64_SVG>" width="64" alt="<name> icon" style="background-color: #f0f0f0; border-radius: 4px; padding: 2px;">
static const IconData icon_name = IconData([...]);
```

The preview SVG renders all strokes/fills in `#808080` (gray) for consistent IDE tooltip display.

### File Template

All generated files follow this template:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'helpers.dart';

/// A collection of <Library Name> icons.
class <ClassName> {
  const <ClassName>._();

  /// <img src="data:image/svg+xml;base64,..." width="64" alt="<name> icon" style="background-color: #f0f0f0; border-radius: 4px; padding: 2px;">
  static const IconData <name> = IconData([...]);

  // ... more icons, sorted alphabetically
}
```

### Class Names

| File | Class Name |
|------|-----------|
| `lucide_icons.dart` | `LucideIcons` |
| `material_icons.dart` | `MaterialIcons` |
| `material_symbols.dart` | `MaterialSymbols` |
| `tabler_icons.dart` | `TablerIcons` |
| `fluent_icons.dart` | `FluentIcons` |
| `font_awesome_icons.dart` | `FontAwesomeIcons` |
| `remix_icons.dart` | `RemixIcons` |

All classes: `const ClassName._()` private constructor (non-instantiable).

---

## Generator Tool

### Location

```
tool/generate_icons.dart
```

This should be a standalone Dart CLI script that regenerates all icon data files.

### Dependencies

Add to `pubspec.yaml` under `dev_dependencies` (or use a separate `tool/pubspec.yaml`):
- `package:xml` — for parsing SVG files
- `dart:convert` — for base64 encoding previews
- `dart:io` — for file operations and process execution (git clone)

### Workflow

```bash
dart run tool/generate_icons.dart           # regenerate all
dart run tool/generate_icons.dart lucide     # regenerate only Lucide
dart run tool/generate_icons.dart tabler     # regenerate only Tabler
dart run tool/generate_icons.dart fluent     # regenerate only Fluent
dart run tool/generate_icons.dart material-symbols  # regenerate only Material Symbols
dart run tool/generate_icons.dart font-awesome      # regenerate only Font Awesome
dart run tool/generate_icons.dart remix             # regenerate only Remix
```

### Algorithm

For each icon family:

#### Step 1: Clone upstream repo

```bash
git clone --depth 1 <repo_url> /tmp/<family>
```

Use `/tmp/` for disposable clones. If already cloned, `git pull` to update.

#### Step 2: Discover SVG files

| Family | Glob pattern | Filter |
|--------|-------------|--------|
| Lucide | `/tmp/lucide/icons/*.svg` | All files |
| Material Symbols | `/tmp/material-symbols/svg/400/outlined/*.svg` | Also scan `rounded/`, `sharp/`; `-fill.svg` suffix = filled |
| Tabler | `/tmp/tabler/icons/outline/*.svg`, `filled/*.svg` | Style from directory name |
| Fluent | `/tmp/fluent/assets/*/SVG/*_24_*.svg` | Only `_24_` (24px); style from suffix before `.svg` |
| Font Awesome | `/tmp/Font-Awesome/svgs/solid/*.svg`, `regular/*.svg`, `brands/*.svg` | Style from directory name |
| Remix | `/tmp/remixicon/icons/*/*.svg` | `-line.svg` = base (no suffix), `-fill.svg` = `_fill` suffix |

#### Step 3: Parse each SVG

For each SVG file:

1. **Read and parse XML** using `package:xml`
2. **Extract root `<svg>` attributes** — keep: `viewBox`, `fill`, `stroke`, `stroke-width`, `stroke-linecap`, `stroke-linejoin`. Skip: `xmlns`, `width`, `height`, `class`, `style`.
3. **Extract child elements recursively** — for each child of `<svg>`:
   - Record `tag` name and all attributes as `Map<String, String>`
   - Handle nested elements (e.g., `<g>` containing `<path>`)
   - Skip XML comments, processing instructions, text nodes
4. **Build `IconData` content list**:
   - First entry: `{'tag': 'root', 'family': '<family>', 'attrs': {<root_attrs>}}` (skip for Material Icons)
   - Remaining entries: `{'tag': '<element>', 'attrs': {<element_attrs>}}`

#### Step 4: Derive identifier name

```
SVG filename → strip .svg → kebab-to-snake → apply style suffix → handle numeric prefix
```

Detailed rules:
1. `arrow-right.svg` → `arrow_right`
2. Append style suffix: `arrow_right_filled`, `arrow_right_rounded`, etc.
3. If starts with digit: prepend `icon_` → `icon_10k`
4. If name conflicts with Dart keyword: prepend `icon_` (check: `class`, `switch`, `default`, `return`, `if`, `else`, `for`, `while`, `do`, `new`, `true`, `false`, `null`, `this`, `super`, `is`, `in`, `as`)

#### Step 5: Generate base64 preview

1. Take the original SVG string
2. Replace `currentColor` with `#808080` in all attributes
3. Add `stroke="#808080"` to path/shape elements if stroke-based family
4. Base64-encode the modified SVG
5. Format as: `/// <img src="data:image/svg+xml;base64,<B64>" width="64" alt="<name> icon" style="background-color: #f0f0f0; border-radius: 4px; padding: 2px;">`

#### Step 6: Write Dart file

1. Sort all icons alphabetically by identifier name
2. Write file header (see template above)
3. Write each icon constant with doc comment + `IconData([...])`
4. Use `r'''...'''` raw strings for all attribute values
5. Ensure proper formatting (2-space indent, trailing commas)

#### Step 7: Validate

```bash
dart analyze lib/src/icons/
```

Must pass with **zero issues**.

### Update `icons.dart` barrel file

After adding new families, update `icons.dart`:

```dart
export 'icon.dart';
export 'helpers.dart';
export 'material_icons.dart';
export 'material_symbols.dart';
export 'lucide_icons.dart';
export 'fluent_icons.dart';
export 'tabler_icons.dart';
export 'font_awesome_icons.dart';
export 'remix_icons.dart';
```

---

## Key Gotchas

1. **viewBox stored in root attrs** — all families (except Material Icons) store `viewBox` in root attrs; Icon component reads it automatically, falling back to `0 0 24 24`
2. **Material Icons has NO root element** — paths go directly in the list, no `{'tag': 'root', ...}`; uses default viewBox `0 0 24 24`
3. **Fluent: 24px only** — filter `_24_` in filename; skip all other sizes (16/20/28/32/48)
4. **Fluent: hardcoded fills replaced** — upstream SVGs use `fill="#212121"` on paths; generator's `_replaceHardcodedFills()` converts to `currentColor` for theming
5. **Tabler outline vs filled** — different root attrs (stroke-based vs fill-based)
6. **Font Awesome: variable viewBox** — each icon has its own viewBox (e.g. `0 0 384 512`, `0 0 640 512`); stored in root attrs, Icon component uses it automatically
7. **Material Symbols: non-standard viewBox** — uses `0 -960 960 960` (not 24x24); stored in root attrs
8. **Font Awesome: free only** — use `svgs/` directory from `7.x` branch; NEVER use `svgs-full/` or Pro icons
9. **Font Awesome: brands are special** — company logos; use `_brand` suffix
10. **Material Symbols: weight 400 only** — skip weight/grade variations; only use default weight at 24px optical size
11. **Material Symbols: community mirror recommended** — https://github.com/marella/material-symbols has cleaner structure than official repo
12. **Raw strings** — all attribute values: `r'''value'''`
13. **`// ignore_for_file: constant_identifier_names`** — required in all generated files
14. **`// GENERATED CODE - DO NOT MODIFY BY HAND`** — required header in all generated files
15. **Alphabetical sort** — icons sorted alphabetically within each class
16. **Dart keyword collision** — prefix with `icon_` if name is a reserved word or starts with digit
17. **File sizes are large** — Material Icons is 13MB, Fluent is 17MB. This is expected for ~5,000-10,000 const definitions with base64 previews. Tree-shaking handles unused icons.

---

## Maintenance Notes

All 7 families are generated and up to date. To refresh from upstream:
```bash
dart run tool/generate_icons.dart              # all families
dart run tool/generate_icons.dart lucide tabler # specific families
```
- Material Icons is **frozen** (no new icons from Google)
- Other families receive periodic upstream updates — re-run generator to pull latest

---

## Upstream Source Reference

| Family | Repo | SVG Path | Branch | License |
|--------|------|----------|--------|---------|
| Lucide | https://github.com/lucide-icons/lucide | `icons/*.svg` | `main` | ISC |
| Material Icons | https://github.com/google/material-design-icons | `src/` | `master` | Apache 2.0 |
| Material Symbols | https://github.com/marella/material-symbols | `svg/400/{outlined,rounded,sharp}/*.svg` | `main` | Apache 2.0 |
| Tabler | https://github.com/tabler/tabler-icons | `icons/{outline,filled}/*.svg` | `main` | MIT |
| Fluent | https://github.com/microsoft/fluentui-system-icons | `assets/*/SVG/*_24_*.svg` | `main` | MIT |
| Font Awesome | https://github.com/FortAwesome/Font-Awesome | `svgs/{solid,regular,brands}/*.svg` | `7.x` | CC BY 4.0 / MIT |
| Remix | https://github.com/nicedoc/remixicon | `icons/*/*.svg` | `main` | Apache 2.0 |
