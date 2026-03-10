# CLAUDE.md - DocuDart Project Guide

## Project Overview

**DocuDart** is a static documentation generator for Dart, similar to Docusaurus but using Jaspr as the rendering engine. Users write documentation in Markdown files with YAML frontmatter, and DocuDart generates a static website.

**Design philosophy**: DocuDart provides a Flutter-identical API — components like `Row`, `Column`, `Padding`, `Expanded`, and `IconButton` look and feel like Flutter widgets, but underneath they produce lean, optimized HTML trees via Jaspr. Primitive layout components (`Padding`, `Flexible`, `Expanded`, `SizedBox`) use `.apply()` internally to merge styles directly onto child elements instead of wrapping them in extra `<div>` elements. Container components (`Row`, `Column`, `Container`, `Center`) use pure inline styles — no CSS class hooks. Users write familiar Flutter-like Dart with no custom CSS or JS; DocuDart generates minimal HTML/CSS/JS.

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
| `lib/src/extensions/CLAUDE.md` | `.let()`, `.apply()`, `Screen` class (responsive breakpoints) |
| `lib/src/markdown/CLAUDE.md` | MarkdownProcessor, OpalHighlighter, FrontmatterHandler, ComponentParser |
| `lib/src/services/CLAUDE.md` | WorkspaceResolver, PackageResolver, DocuDartFileWatcher |
| `lib/src/processing/CLAUDE.md` | ContentProcessor, ReadmeParser, VersionManager |

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
├── docudart/                            # Self-documentation (docudart.dev)
└── pubspec.yaml
```

## Common Tasks

### Adding a New Config Option
1. Add field to `Config` in `lib/src/config/docudart_config.dart`
2. Add to constructor, `copyWith`, `toJson()`, `fromJson()` (function fields skip serialization — only add to constructor and `copyWith`)
3. Update `ProjectGenerator` to use it in generated config.dart template
4. Update `SiteGenerator` to handle it when generating site

### Adding a New CLI Command
1. Create `lib/src/cli/commands/my_command.dart`
2. Extend `Command<int>` from `package:args`
3. Register in `DocuDartCliRunner` constructor

### Modifying Generated Site
See `lib/src/generators/CLAUDE.md` for the full generation pipeline (`SiteGenerator` methods, `StylesGenerator`, `ThemeScriptGenerator`).

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

After style/layout/template changes: start `cd example && dart run ../bin/docudart.dart serve &` (cold start ~2 min), use Playwright skill for screenshots (light + dark), then `pkill -f "docudart.dart serve"; pkill -f "jaspr"`.

**Important**: Use `http://127.0.0.1:8080/` (not `localhost`) — `jaspr serve` binds IPv4 only, `localhost` resolves to IPv6 on macOS. Verify: header, sidebar, mobile drawer (≤1024px), landing page, footer, dark mode, doc content.

## Important Notes

- User's config is `config.dart` (Dart, not YAML) — must export `Config configure(BuildContext context)`
- `docudart` re-exports Jaspr and extensions (`.let()`, `.apply()`, `.screen`), hiding conflicting types (`Text`, `Padding`, `Border`, `BorderSide`, `BorderRadius`, `BoxShadow`, `ColorScheme`) — DocuDart provides Flutter-like replacements
- Jaspr gotchas: `build()` returns `Component` (single, not `Iterable`); `classes` takes `String` (space-separated, not `List`); `main(...)` from dom.dart shadows Dart's `main()`
- Clean URLs by default (`/docs/intro/` not `/docs/intro.html`); generated Jaspr project lives in `<projectDir>/.dart_tool/docudart/`
- Linting: `many_lints` plugin (in `analysis_options.yaml`) + `sort_constructors_first`, `use_null_aware_elements`
- Assets use `context.project.assets` (not static `Assets` class) — callable `Asset` returns Component, `.path` for String
- Theme-aware assets: `assets/light/` and `assets/dark/` subdirs auto-switch via CSS visibility
- 3 theme presets with distinct palettes: `classic` (blue), `material3` (purple), `shadcn` (zinc/black)
- Theme `seedColor` accepts Jaspr `Color` (e.g. `Colors.indigo`, `Color.value(0xFF006D40)`) — overrides preset defaults
- `@client` components require `build_web_compilers` in the generated pubspec's `dev_dependencies`; Jaspr's `ClientScriptAdapter` auto-inserts the script tag (see `lib/src/generators/CLAUDE.md` for full hydration pipeline)
- `docsBuilder` callback customizes doc page body layout; default (null) renders TOC sidebar + scroll spy automatically. Override with `docsBuilder: (page) => ...` receiving a `DocPageInfo` (content, toc, title, urlPath, description, tags)
- `context.screen.when(desktop:, tablet:, mobile:)` / `maybeWhen(...)` — CSS-based responsive layout; breakpoints: mobile ≤768, tablet 769–1024, desktop 1025+. Use `?` prefix with `maybeWhen` in children lists.
- `ConfigEvaluator` (text-based parsing) doesn't extract `siteUrl` — so `sitemap.xml` isn't generated during build. SEO tags in HTML (canonical, OG, JSON-LD) still work because the managed Jaspr project imports `config.dart` directly.

## Component Design & `.apply()` Shadowing

Primitives (`Padding`, `Flexible`, `Expanded`, `SizedBox` with child) use `.apply()` internally to merge styles onto children — no wrapper `<div>`. Container components (`Row`, `Column`, `Container`, `Center`, `Wrap`) keep their `<div>` with inline styles, no CSS class hooks.

**Critical rule**: Nested `.apply()` calls shadow each other (keyed by `runtimeType`). Never chain `.apply()` on a component that uses it internally. Instead, combine all styles in one `.apply()` on the innermost child. See `lib/src/components/CLAUDE.md` for full details.

## Key Dependencies

See `pubspec.yaml` for the full list. Notable non-obvious ones:
- `jaspr` — SSG web framework (re-exported to users via `docudart.dart`)
- `opal` — build-time syntax highlighting (same engine as dart.dev)
- `universal_web` — DOM access in `@client` components (web API on browser, stubs on server)
- `many_lints` — lint plugin (configured in `analysis_options.yaml`, not pubspec)

## Documentation Site

DocuDart documents itself at [docudart.dev](https://docudart.dev). The `docudart/` directory in the project root is a standard DocuDart project with `siteUrl: 'https://docudart.dev'`. Deployed to GitHub Pages via `.github/workflows/docs.yaml` (builds on push to `main`, writes CNAME, deploys with `actions/deploy-pages`).

## References

- [Jaspr Documentation](https://docs.jaspr.site/)
- [Jaspr LLMs.txt](https://jaspr.site/llms.txt) — Machine-readable Jaspr docs for AI-assisted development
- [Docusaurus](https://docusaurus.io/) — Feature inspiration
