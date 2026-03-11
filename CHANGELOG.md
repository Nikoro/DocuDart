# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## Unreleased

## 0.1.0 — 2026-03-11

### Added
- Theme system redesign with 3 presets (`classic`, `material3`, `shadcn`), seed colors, and full customization
- Preset-specific color schemes and CSS variations
- `Color` objects accepted as `seedColor` in Theme constructors
- Build-time syntax highlighting with Opal (replaced highlight.js)
- dart.dev code theme colors for `classic` preset
- Mobile sidebar drawer with toggle button
- `docsBuilder` config field for custom doc page layouts
- Table of contents for the changelog page
- Horizontal scrolling for mobile nav links
- Theme-aware asset system with light/dark logo variants
- LICENSE file parsing to extract copyright holder for footer
- Layout primitives (`Padding`, `Container`, `Center`, `Wrap`) with per-component theme classes
- Documentation site at docudart.dev with GitHub Pages deployment
- Improved responsive layout for header and footer
- Configurable project folder name (`docudart create [name]`, default: `docudart/`)
- Remix Icon family (~3,228 icons) — 7 icon families total (~52k icons)
- Skip-to-content accessibility link in generated sites
- `aria-expanded` attribute on sidebar ExpansionTile for screen readers
- Dynamic ARIA labels on theme toggle (reflects current mode)
- Unicode support in heading anchor IDs (internationalization)

### Changed
- Wrapper `<div>` elements eliminated in layout primitives via `.apply()` style merging
- `Changelog` model introduced for structured changelog data
- Footer layout spacing improved
- Generated templates simplified to read from `context` instead of constructor params
- `seedColor` type narrowed from `Object` to `Color`
- Modern Dart 3 idioms applied across codebase
- Mobile menu button replaced with composable components
- IconButton gains padding customization
- Audit findings resolved across codebase
- Reduced public API surface — internal utilities no longer exported from `docudart.dart`
- Replaced bare `print()` with `CliPrinter` across generators and processing code
- Renamed `CustomTheme` to `LoadedTheme` for clarity
- Moved `DocPage`/`DocFolder` models from `processing/` to `models/`
- Silent catch blocks now log warnings via `CliPrinter`

### Fixed
- Code theme colors corrected for accurate syntax highlighting
- Icon button size and padding adjusted for visual consistency
- Max-width constraints removed from header and footer
- Code block indentation normalized with improved spacing
- CSS `fill` override no longer breaks stroke-based icons (Lucide, Tabler)
- Distinct light/dark default logos with user assets preserved on regenerate
- Content max width increased to 1200px
- Unnecessary padding reset removed when sidebar is absent
- XSS and path traversal vulnerabilities patched
- `_escapeForDart()` now handles `\r` and `\t` characters
- CRLF line endings in frontmatter parser (Windows compatibility)
- `dart format` exit code was silently ignored in project generator

## 0.0.1 — 2026-02-05

### Added
- CLI commands: `create`, `build`, `serve`, `version`, `update`
- Markdown documentation with YAML frontmatter
- Collapsible sidebar with `_expanded` suffix convention
- Light/dark theme with system preference detection
- Icon system with 6 families (~49k icons)
- Live reload during `docudart serve`
- Type-safe asset paths (`Assets.logo.logo_webp`)
- Auto-discovered custom pages
- `ProjectProvider` + `context.project` for accessing pubspec data
- Component library: Layout, Row, Column, Link, Logo, Copyright, etc.
- `configure()` pattern with `BuildContext` for type-safe config
