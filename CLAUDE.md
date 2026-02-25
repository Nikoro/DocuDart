# CLAUDE.md - DocuDart Project Guide

## Project Overview

**DocuDart** is a static documentation generator for Dart, similar to Docusaurus but using Jaspr as the rendering engine. Users write documentation in Markdown files with YAML frontmatter, and DocuDart generates a static website.

**Design philosophy**: DocuDart provides a Flutter-identical API — components like `Row`, `Column`, `IconButton`, and `SlideTransition` look and feel like Flutter widgets, but underneath they produce optimized HTML, CSS, and JavaScript via Jaspr.

## Quick Start Commands

```bash
dart pub get                              # Install dependencies
dart run bin/docudart.dart create --full  # Create project
dart run bin/docudart.dart build          # Build site
dart run bin/docudart.dart serve          # Dev server with hot reload
dart analyze lib bin test                  # Analyze code
dart test                                 # Run tests
```

## Architecture

```
User Project                    DocuDart CLI                    Output
============                    ============                    ======
docudart/
  config.dart    --------->
  docs/*.md      --------->    SiteGenerator    --------->    docudart/.dart_tool/docudart/
  pages/*.dart   --------->    (Jaspr project)  --------->    docudart/build/web/
  components/    --------->
  themes/        --------->
```

`docudart create` creates a `docudart/` subdirectory (configurable name) with its own `pubspec.yaml` (path dependency to docudart). DocuDart re-exports `package:jaspr/jaspr.dart`, so users only import `package:docudart/docudart.dart`. The `build`/`serve` commands auto-detect the `docudart/` directory via `WorkspaceResolver`.

## Local Documentation

Detailed docs for each subsystem live alongside the code:

| File | Covers |
|------|--------|
| `lib/src/cli/CLAUDE.md` | CLI commands, services, live reload, log filtering |
| `lib/src/config/CLAUDE.md` | Config class, configure() pattern, ConfigLoader, ConfigEvaluator |
| `lib/src/models/CLAUDE.md` | Doc hierarchy, Pubspec, Repository, Page, ordering conventions |
| `lib/src/components/CLAUDE.md` | Link, Layout, Sidebar, Logo, ThemeToggle, all components |
| `lib/src/generators/CLAUDE.md` | SiteGenerator, ProjectGenerator, templates, asset paths |
| `lib/src/theme/CLAUDE.md` | Theme presets, ColorScheme, CSS generation, seed-based palettes |
| `lib/src/icons/CLAUDE.md` | Icon system (7 families, ~52k icons), generator tool, data format |

## Project Structure

```
docudart/
├── bin/docudart.dart                    # CLI entry point
├── lib/
│   ├── docudart.dart                    # Library exports (re-exports jaspr)
│   └── src/
│       ├── assets/                      # Bundled assets copied during init
│       ├── cli/                         # CLI commands + services
│       ├── config/                      # Config class + loading
│       ├── models/                      # Data models + enums
│       ├── generators/                  # Code generation (site + project)
│       ├── processing/                  # Content processing pipeline
│       ├── services/                    # File watcher, resolvers
│       ├── markdown/                    # Markdown processing + frontmatter
│       ├── theme/                       # Theming (Theme presets, ColorScheme, color resolver)
│       ├── components/                  # Component system (layout, nav, branding)
│       ├── icons/                       # Icon system (7 families, ~52k icons)
│       └── extensions/                  # .let(), .apply(), and .screen extensions
├── tool/generate_icons.dart             # Icon generator tool
├── example/                             # Example DocuDart project
└── pubspec.yaml
```

## Common Tasks

### Adding a New Config Option
1. Add field to `Config` in `lib/src/config/docudart_config.dart`
2. Add to constructor, `copyWith`, `toJson()`, `fromJson()`
3. Update `ProjectGenerator` to use it in generated config.dart template
4. Update `SiteGenerator` to handle it when generating site

### Adding a New CLI Command
1. Create `lib/src/cli/commands/my_command.dart`
2. Extend `Command<int>` from `package:args`
3. Register in `DocuDartCliRunner` constructor

### Modifying Generated Site
See `lib/src/generators/CLAUDE.md` for the full generation pipeline. Key methods in `SiteGenerator`:
- `_generateApp()` — Router with ProjectProvider
- `_generateLayout()` — LayoutDelegate
- `_generateStyles()` — delegates to `StylesGenerator` (reads per-component theme properties directly, no theme-name conditionals)
- `_copyUserFiles()` — copies config.dart, components/, pages/, root-level .dart files (e.g. labels.dart)

## Committing

**Always use the `/commit` skill when committing.** Never use the default system commit instructions — the `/commit` skill has project-specific rules (e.g. no Co-Authored-By, no AI references).

## Testing

**After changes to code generation, always regenerate the example project.** Use `/regenerate` which deletes `example/docudart/` and re-runs `docudart create --full`.

```bash
# Quick test workflow:
# 1. /regenerate
# 2. Build:
cd example && dart run ../bin/docudart.dart build
```

### Visual Testing with Playwright

After style/layout/template changes, verify with Playwright:

1. `cd example && dart run ../bin/docudart.dart serve &`
2. Wait for cold start (~2 min for first `jaspr serve` — compiles builders/JIT)
3. Use Playwright skill for screenshots (light + dark mode)
4. `pkill -f "docudart.dart serve"; pkill -f "jaspr"`

**Important**: Use `http://127.0.0.1:8080/` (not `localhost`) — `jaspr serve` binds IPv4 only, and `localhost` resolves to IPv6 (`::1`) on macOS.

Key things to verify: header, sidebar (active link, collapsible categories), mobile sidebar drawer (hamburger menu at <= 1024px), landing page, footer, dark mode, doc content rendering.

## Important Notes

- User's config is `config.dart` (Dart, not YAML) — must export `Config configure(BuildContext context)`
- `docudart` re-exports `package:jaspr/jaspr.dart` and extensions (`.let()`, `.apply()`, `.screen`), hiding conflicting types: `Padding`, `Text`, `Border`, `BorderSide`, `BorderRadius`, `BoxShadow`, `ColorScheme` (DocuDart provides Flutter-like replacements)
- Jaspr `build()` returns `Component` (single), NOT `Iterable<Component>`
- Jaspr `classes` takes `String` (space-separated), NOT `List<String>`
- Jaspr `main(...)` from dom.dart shadows Dart's `main()` function
- Clean URLs by default (`/docs/intro/` not `/docs/intro.html`)
- Generated Jaspr project lives in `<projectDir>/.dart_tool/docudart/`
- Lint rules: `sort_constructors_first`, `use_null_aware_elements`
- Assets use `context.project.assets` (not static `Assets` class) — callable `Asset` returns Component, `.path` for String
- Theme-aware assets: `assets/light/` and `assets/dark/` subdirs auto-switch via CSS visibility
- 3 theme presets with distinct palettes: `classic` (blue), `material3` (purple), `shadcn` (zinc/black)
- Theme `seedColor` accepts Jaspr `Color` (e.g. `Colors.indigo`, `Color.value(0xFF006D40)`) — overrides preset defaults
- `@client` components require `build_web_compilers` in the generated pubspec's `dev_dependencies` — without it, `dart2js` never runs and client JS is never produced (see `lib/src/generators/CLAUDE.md` for full hydration pipeline)
- Don't manually add `<script src="main.client.dart.js">` — Jaspr's `ClientScriptAdapter` handles it automatically when `@client` components exist

## Dependencies

| Package | Purpose |
|---------|---------|
| `args` | CLI argument parsing |
| `path` | Path manipulation |
| `glob` | File pattern matching |
| `watcher` | File watching (hot reload) |
| `yaml` | YAML/frontmatter parsing |
| `markdown` | Markdown to HTML |
| `opal` | Build-time syntax highlighting (same engine as dart.dev) |
| `jaspr` | Web framework for SSG (re-exported to users) |
| `universal_web` | DOM access in `@client` components (web API on browser, stubs on server) |
| `meta` | @immutable annotation |
| `xml` (dev) | SVG parsing for icon generator tool |

## References

- [Jaspr Documentation](https://docs.jaspr.site/)
- [Jaspr LLMs.txt](https://jaspr.site/llms.txt) — Machine-readable Jaspr docs for AI-assisted development
- [Docusaurus](https://docusaurus.io/) — Feature inspiration
