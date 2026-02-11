# Icons Directory — Agent Instructions

This directory contains a local fork of the `jaspr_icons` package, maintained in-tree because the published `jaspr_icons` on pub.dev is **incompatible with Jaspr 0.22**. The hand-written files (`icon.dart`, `helpers.dart`) have been updated for compatibility; the icon data files are generated.

## File Overview

| File | Type | Description |
|------|------|-------------|
| `helpers.dart` | Hand-written | `IconData` class + `StrokeLineJoin` / `StrokeLineCap` enums |
| `icon.dart` | Hand-written | `Icon` component (`StatelessComponent` → renders SVG) |
| `icons.dart` | Hand-written | Barrel file re-exporting everything |
| `lucid_icons.dart` | Generated | Lucide icons (stroke-based) |
| `material_icons.dart` | Generated | Google Material Design Icons (classic, frozen) |
| `material_symbols.dart` | Generated | **NEW** — Google Material Symbols (active successor to Material Icons) |
| `tabler_icons.dart` | Generated | Tabler icons (outline + filled) |
| `fluent_icons.dart` | Generated | Microsoft Fluent UI System icons (24px) |
| `font_awesome_icons.dart` | Generated | **NEW** — Font Awesome free icons |

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

### Migration from Current Names

The current files use inconsistent naming that must be unified:

| Current | New (unified) | Change |
|---------|--------------|--------|
| `LucidIcons.icon_home` | `LucidIcons.home` | Drop `icon_` prefix |
| `MaterialIcons.icon_home` | `MaterialIcons.home` | Drop `icon_` prefix (baseline) |
| `MaterialIcons.outline_home` | `MaterialIcons.home_outlined` | Prefix → suffix, `outline` → `outlined` |
| `MaterialIcons.round_home` | `MaterialIcons.home_rounded` | Prefix → suffix |
| `MaterialIcons.sharp_home` | `MaterialIcons.home_sharp` | Prefix → suffix |
| `MaterialIcons.twotone_home` | `MaterialIcons.home_twotone` | Prefix → suffix |
| `TablerIcons.home_outline` | `TablerIcons.home` | Drop `_outline` (it's the base) |
| `TablerIcons.home_filled` | `TablerIcons.home_filled` | No change |
| `FluentIcons.home_regular` | `FluentIcons.home` | Drop `_regular` (it's the base) |
| `FluentIcons.home_filled` | `FluentIcons.home_filled` | No change |

---

## Icon Datasets — Current Status & Upstream Info

### 1. Lucide Icons (`lucid_icons.dart`)

- **Current count**: 1,636
- **Upstream count**: ~1,660+
- **Gap**: ~20-30 missing recent additions
- **Repo**: https://github.com/lucide-icons/lucide
- **SVG path**: `icons/*.svg`
- **SVG naming**: kebab-case (`a-arrow-down.svg`, `home.svg`)
- **License**: ISC
- **Styles**: Single (stroke-based) — no variants
- **Class**: `LucidIcons`
- **Root attrs**: `fill: 'none'`, `stroke: 'currentColor'`, `stroke-width: '2'`, `stroke-linecap: 'round'`, `stroke-linejoin: 'round'`
- **Family tag**: `'lucid'` (NOTE: not `'lucide'` — keep this convention)

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

### 3. Material Symbols (`material_symbols.dart`) — NEW

- **Target count**: ~2,500+ unique icons × up to 6 variants
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
- **Root attrs**: TBD — examine upstream SVGs during generation
- **IMPORTANT**: Use weight 400 only (default). Skip weight/grade/optical-size variations to keep file size manageable. Use 24px optical size.
- **Key difference from Material Icons**: Variable font axes (fill, weight, grade, optical size). We only care about fill (0/1) and the 3 base styles at default weight 400.

### 4. Tabler Icons (`tabler_icons.dart`)

- **Current count**: 5,963 (4,964 outline + 999 filled)
- **Upstream count**: ~9,970 (4,985 unique × 2 styles)
- **Gap**: **~4,000 filled variants missing** (biggest gap)
- **Repo**: https://github.com/tabler/tabler-icons
- **SVG paths**: `icons/outline/*.svg` and `icons/filled/*.svg`
- **SVG naming**: kebab-case (`accessible.svg`, `ad-circle.svg`)
- **License**: MIT
- **Styles**: 2 — outline (base, no suffix) + filled (`_filled`)
- **Class**: `TablerIcons`
- **Family tag**: `'tabler'`
- **Root attrs (outline)**: `fill: 'none'`, `stroke: 'currentColor'`, `stroke-width: '2'`, `stroke-linecap: 'round'`, `stroke-linejoin: 'round'`
- **Root attrs (filled)**: `fill: 'currentColor'`

### 5. Fluent UI System Icons (`fluent_icons.dart`)

- **Current count**: 4,744 (24px subset: 2,245 regular + 2,281 filled + 196 color + 22 other)
- **Upstream count**: ~4,500+ at 24px (continuously updated)
- **Gap**: Small
- **Repo**: https://github.com/microsoft/fluentui-system-icons
- **SVG path**: `assets/<IconName>/SVG/<icon_name>_24_<style>.svg`
- **SVG naming**: snake_case with size and style (`access_time_24_filled.svg`)
- **License**: MIT
- **Styles**: regular (base, no suffix), filled (`_filled`), color (`_color`)
- **Size filter**: **24px only** — filter filenames containing `_24_`; skip 16/20/28/32/48
- **Class**: `FluentIcons`
- **Family tag**: `'fluent'`
- **Root attrs**: `fill: 'none'` (each child path has its own `fill: 'currentColor'`)

### 6. Font Awesome Free (`font_awesome_icons.dart`) — NEW

- **Target count**: ~2,860 free icons (solid: ~2,000 + regular: ~273 + brands: ~587)
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
- **Root attrs**: TBD — examine upstream SVGs during generation
- **IMPORTANT**: Only free icons. Do NOT include Pro, Sharp, Duotone, or any paid variants. The `svgs/` directory in the repo contains only free icons. The `svgs-full/` directory may contain Pro icons — avoid it.
- **Brand icons**: These are company logos (github, apple, twitter, etc.). Use `_brand` suffix to distinguish from similarly-named non-brand icons.

---

## Icon Data Format Specification

### Structure

Each icon is a `static const IconData` containing a `List<Map<String, dynamic>>`:

```dart
static const IconData icon_name = IconData([
  // Optional root element (metadata + default SVG attributes)
  {
    'tag': 'root',
    'family': '<family>',       // 'lucid', 'tabler', 'fluent', 'material_symbols', 'font_awesome'
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

| Family | Has root? | Family tag | Notes |
|--------|----------|-----------|-------|
| Lucide | Yes | `'lucid'` | Stroke-based defaults |
| Material Icons | **No** | N/A | Bare path elements only |
| Material Symbols | Yes | `'material_symbols'` | TBD — match upstream SVG attrs |
| Tabler | Yes | `'tabler'` | Different attrs for outline vs filled |
| Fluent | Yes | `'fluent'` | `fill: 'none'` on root; `fill: 'currentColor'` on paths |
| Font Awesome | Yes | `'font_awesome'` | TBD — match upstream SVG attrs |

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
| `lucid_icons.dart` | `LucidIcons` |
| `material_icons.dart` | `MaterialIcons` |
| `material_symbols.dart` | `MaterialSymbols` |
| `tabler_icons.dart` | `TablerIcons` |
| `fluent_icons.dart` | `FluentIcons` |
| `font_awesome_icons.dart` | `FontAwesomeIcons` |

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

#### Step 3: Parse each SVG

For each SVG file:

1. **Read and parse XML** using `package:xml`
2. **Extract root `<svg>` attributes** — keep: `fill`, `stroke`, `stroke-width`, `stroke-linecap`, `stroke-linejoin`. Skip: `xmlns`, `width`, `height`, `viewBox`, `class`, `style`.
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
export 'lucid_icons.dart';
export 'fluent_icons.dart';
export 'tabler_icons.dart';
export 'font_awesome_icons.dart';
```

---

## Key Gotchas

1. **Lucide family tag is `'lucid'`** (not `'lucide'`) — historical convention, keep it
2. **Material Icons has NO root element** — paths go directly in the list, no `{'tag': 'root', ...}`
3. **Fluent: 24px only** — filter `_24_` in filename; skip all other sizes (16/20/28/32/48)
4. **Fluent: fill on paths, not root** — root has `fill: 'none'`, each child path has `fill: 'currentColor'`
5. **Tabler outline vs filled** — different root attrs (stroke-based vs fill-based)
6. **Font Awesome: free only** — use `svgs/` directory from `7.x` branch; NEVER use `svgs-full/` or Pro icons
7. **Font Awesome: brands are special** — company logos; use `_brand` suffix
8. **Material Symbols: weight 400 only** — skip weight/grade variations; only use default weight at 24px optical size
9. **Material Symbols: community mirror recommended** — https://github.com/marella/material-symbols has cleaner structure than official repo
10. **Raw strings** — all attribute values: `r'''value'''`
11. **`// ignore_for_file: constant_identifier_names`** — required in all generated files
12. **`// GENERATED CODE - DO NOT MODIFY BY HAND`** — required header in all generated files
13. **Alphabetical sort** — icons sorted alphabetically within each class
14. **Dart keyword collision** — prefix with `icon_` if name is a reserved word or starts with digit
15. **File sizes are large** — Material Icons is 13MB, Fluent is 17MB. This is expected for ~5,000-10,000 const definitions with base64 previews. Tree-shaking handles unused icons.

---

## Priority Order for Updates

1. **Tabler** — ~4,000 missing filled variants (biggest gap) + rename to unified convention
2. **Material Symbols** — NEW dataset, ~2,500+ icons, actively maintained successor to Material Icons
3. **Font Awesome** — NEW dataset, ~2,860 free icons, very popular
4. **Lucide** — ~20-30 missing recent additions + rename to unified convention
5. **Fluent** — small gap + rename to unified convention
6. **Material Icons** — frozen, only needs naming convention update (no new icons)

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
