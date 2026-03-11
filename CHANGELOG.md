# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## Unreleased

### Added
- Configurable project folder name (`docudart create [name]`, default: `docudart/`)
- Remix Icon family (~3,228 icons) — 7 icon families total (~52k icons)
- Skip-to-content accessibility link in generated sites
- `aria-expanded` attribute on sidebar ExpansionTile for screen readers
- Dynamic ARIA labels on theme toggle (reflects current mode)
- `topics` field in pubspec.yaml for pub.dev discoverability
- CONTRIBUTING.md, CODE_OF_CONDUCT.md, and GitHub issue/PR templates
- CI integration smoke test (`create --full` + `build`)
- Pub cache in CI for faster builds
- Barrel files for `models/` and `config/` directories
- Unicode support in heading anchor IDs (internationalization)

### Changed
- Reduced public API surface — internal utilities no longer exported from `docudart.dart`
- Replaced bare `print()` with `CliPrinter` across generators and processing code
- Renamed `CustomTheme` to `LoadedTheme` for clarity
- Moved `DocPage`/`DocFolder` models from `processing/` to `models/`
- Silent catch blocks now log warnings via `CliPrinter`

### Fixed
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
