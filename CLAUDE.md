# CLAUDE.md - DocuDart Project Guide

## Project Overview

**DocuDart** is a static documentation generator for Dart, similar to Docusaurus but using Jaspr as the rendering engine. Users write documentation in Markdown files with YAML frontmatter, and DocuDart generates a static website.

## Quick Start Commands

```bash
dart pub get                              # Install dependencies
dart run bin/docudart.dart create --full  # Create project
dart run bin/docudart.dart build          # Build site
dart run bin/docudart.dart serve          # Dev server with hot reload
dart analyze lib bin                      # Analyze code
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
│       ├── theme/                       # Theming (BaseTheme, DefaultTheme)
│       ├── components/                  # Component system (layout, nav, branding)
│       ├── icons/                       # Icon system (7 families, ~52k icons)
│       └── extensions/                  # .let() and .apply() extensions
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
- `_generateStyles()` — delegates to StylesGenerator
- `_copyUserFiles()` — copies config.dart, components/, pages/, etc.

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
2. Use Playwright skill for screenshots (light + dark mode)
3. `pkill -f "docudart.dart serve"; pkill -f "jaspr"`

Key things to verify: header, sidebar (active link, collapsible categories), landing page, footer, dark mode, doc content rendering.

## Important Notes

- User's config is `config.dart` (Dart, not YAML) — must export `Config configure(BuildContext context)`
- `docudart` re-exports `package:jaspr/jaspr.dart` and extensions (`.let()`, `.apply()`)
- Jaspr `build()` returns `Component` (single), NOT `Iterable<Component>`
- Jaspr `classes` takes `String` (space-separated), NOT `List<String>`
- Jaspr `main(...)` from dom.dart shadows Dart's `main()` function
- Clean URLs by default (`/docs/intro/` not `/docs/intro.html`)
- Generated Jaspr project lives in `<projectDir>/.dart_tool/docudart/`
- Lint rules: `sort_constructors_first`, `use_null_aware_elements`

## Dependencies

| Package | Purpose |
|---------|---------|
| `args` | CLI argument parsing |
| `path` | Path manipulation |
| `glob` | File pattern matching |
| `watcher` | File watching (hot reload) |
| `yaml` | YAML/frontmatter parsing |
| `markdown` | Markdown to HTML |
| `jaspr` | Web framework for SSG (re-exported to users) |
| `meta` | @immutable annotation |
| `xml` (dev) | SVG parsing for icon generator tool |

## References

- [Jaspr Documentation](https://docs.jaspr.site/)
- [Jaspr LLMs.txt](https://jaspr.site/llms.txt) — Machine-readable Jaspr docs for AI-assisted development
- [Docusaurus](https://docusaurus.io/) — Feature inspiration
