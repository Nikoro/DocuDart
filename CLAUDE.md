# CLAUDE.md - DocuDart Project Guide

This file provides guidance for AI agents working on the DocuDart project.

## Project Overview

**DocuDart** is a static documentation generator for Dart, similar to Docusaurus but using Jaspr as the rendering engine. Users write documentation in Markdown files with YAML frontmatter, and DocuDart generates a static website.

## Quick Start Commands

```bash
# Install dependencies
dart pub get

# Run CLI
dart run bin/docudart.dart --help
dart run bin/docudart.dart init --full
dart run bin/docudart.dart build
dart run bin/docudart.dart serve

# Analyze code
dart analyze lib bin

# Run tests
dart test
```

## Architecture Overview

```
User Project                    DocuDart CLI                    Output
============                    ============                    ======
website/
  config.dart    ─────────>
  docs/*.md      ─────────>    SiteGenerator    ─────────>    website/.dart_tool/docudart/
  pages/*.dart   ─────────>    (Jaspr project)  ─────────>    website/build/web/
  components/    ─────────>
  themes/        ─────────>
```

**Key Insight**: `docudart init` creates a `website/` subdirectory inside the user's project. This directory is a self-contained Dart package with its own `pubspec.yaml` that depends on `docudart` (path dependency). DocuDart re-exports `package:jaspr/jaspr.dart`, so user code only needs `import 'package:docudart/docudart.dart'`.

The `build`/`serve` commands auto-detect the `website/` directory from the project root using `WorkspaceResolver`.

## Project Structure

```
docudart/
├── bin/docudart.dart                    # CLI entry point
├── lib/
│   ├── docudart.dart                    # Library exports (re-exports jaspr)
│   └── src/
│       ├── cli/                         # CLI commands
│       │   ├── cli_runner.dart          # CommandRunner
│       │   ├── errors.dart              # DocuDartException, CliPrinter
│       │   └── commands/
│       │       ├── init_command.dart    # docudart init
│       │       ├── build_command.dart   # docudart build
│       │       └── serve_command.dart   # docudart serve
│       ├── config/                      # Configuration classes
│       │   ├── docudart_config.dart     # Config class (has toJson/fromJson)
│       │   ├── config_loader.dart       # Load config (evaluates config.dart, falls back to YAML)
│       │   ├── config_evaluator.dart    # Text-based parsing of config.dart
│       │   ├── nav_link.dart            # NavLink (internal/external navigation)
│       │   ├── site_context.dart        # SiteContext (docs + pages passed to layout functions)
│       │   ├── component_config.dart    # ComponentConfig
│       │   ├── versioning_config.dart   # VersioningConfig
│       │   ├── theme_config.dart        # ThemeMode enum (system, light, dark)
│       │   └── custom_page.dart         # CustomPage
│       ├── core/                        # Core functionality
│       │   ├── project_generator.dart   # Generate website/ project (init)
│       │   ├── site_generator.dart      # Generate .dart_tool/docudart
│       │   ├── content_processor.dart   # Process markdown files
│       │   ├── version_manager.dart     # Handle versioned docs
│       │   ├── file_watcher.dart        # Watch files for hot reload
│       │   ├── readme_parser.dart       # Parse README.md into doc sections
│       │   ├── package_resolver.dart    # Resolve docudart package path
│       │   └── workspace_resolver.dart  # Auto-detect website/ directory
│       ├── markdown/                    # Markdown processing
│       │   ├── markdown_processor.dart  # Convert MD to HTML
│       │   ├── frontmatter_handler.dart # Extract YAML frontmatter
│       │   └── component_parser.dart    # Parse component tags in MD
│       ├── theme/                       # Theming
│       │   ├── base_theme.dart          # Abstract BaseTheme
│       │   ├── default_theme.dart       # DefaultTheme (Flutter docs style)
│       │   ├── theme_colors.dart        # ThemeColors
│       │   ├── theme_typography.dart    # ThemeTypography
│       │   └── theme_loader.dart        # Load custom themes
│       ├── components/                  # Component system
│       │   ├── component_registry.dart  # Component registry
│       │   ├── component_discovery.dart # Auto-discover components
│       │   ├── defaults/               # Default layout components
│       │   │   ├── default_header.dart  # DefaultHeader component
│       │   │   ├── default_footer.dart  # DefaultFooter component
│       │   │   └── default_sidebar.dart # DefaultSidebar component
│       │   └── built_in/               # Built-in components
│       │       ├── callout.dart
│       │       ├── tabs.dart
│       │       ├── code_block.dart
│       │       └── version_switcher.dart
│       └── routing/
│           └── sidebar_generator.dart   # Generate sidebar from folder structure
├── example/                             # Example DocuDart project
│   ├── pubspec.yaml                     # Example Dart project
│   ├── lib/                             # Example project code
│   ├── README.md
│   └── website/                         # DocuDart documentation site
│       ├── pubspec.yaml                 # Depends on docudart via path: ../../
│       ├── config.dart
│       ├── docs/
│       ├── pages/landing_page.dart
│       ├── components/
│       │   ├── header.dart              # Header wrapping DefaultHeader
│       │   ├── footer.dart              # Footer wrapping DefaultFooter
│       │   └── sidebar.dart             # Sidebar wrapping DefaultSidebar
│       ├── assets/
│       └── themes/
├── CLAUDE.md                            # This file
└── pubspec.yaml
```

## Generated User Project Structure (after `docudart init --full`)

```
user-project/
  pubspec.yaml           # User's own project
  lib/                   # User's own code
  website/               # Created by docudart init
    pubspec.yaml         # Depends on docudart (path dependency)
    config.dart          # Config getter with header/footer/sidebar functions
    docs/                # Markdown documentation files
      index.md
      getting-started.md
      01-guides_expanded/  # _expanded suffix → starts open in sidebar
        components.md
        theming.md
      02-advanced/         # No suffix → starts collapsed
        configuration.md
        deployment/        # Nested subfolder → also collapsed
          github-pages.md
          netlify.md
    pages/               # Custom Jaspr page components
      landing_page.dart  # Landing page (imports package:docudart/docudart.dart)
    components/          # Layout wrapper components
      header.dart        # Header component wrapping DefaultHeader
      footer.dart        # Footer component wrapping DefaultFooter
      sidebar.dart       # Sidebar component wrapping DefaultSidebar
    assets/              # Static assets
    themes/              # Custom theme implementations
```

## Key Classes

### Config (lib/src/config/docudart_config.dart)
Main configuration class. All user settings flow through this.
```dart
Config(
  title: String?,
  description: String?,
  docsDir: String,          // default: 'docs' (absolutized by ConfigLoader)
  outputDir: String,        // default: 'build/web' (absolutized by ConfigLoader)
  theme: BaseTheme,         // default: DefaultTheme()
  themeMode: ThemeMode,     // default: ThemeMode.system (system | light | dark)
  home: Component Function(SiteContext)?,      // null = redirect '/' to '/docs'
  header: Component Function(SiteContext)?,   // null = no header
  footer: Component Function(SiteContext)?,   // null = no footer
  sidebar: Component Function(SiteContext)?,  // null = no sidebar
  // ...
)
```
- Home, header, footer, sidebar are nullable function fields returning Components
- When `home` is set, `/` renders the home component (no sidebar); when null, `/` redirects to `/docs`
- Functions receive a `SiteContext` with `docs` (sidebar items) and `pages` (custom pages)
- `toJson()` skips function fields; `fromJson()` sets them to null
- Not `const` (functions prevent const constructors)

### SiteContext (lib/src/config/site_context.dart)
Context object passed to home/header/footer/sidebar builder functions.
```dart
class SiteContext {
  final List<GeneratedSidebarItem> docs;  // auto-generated from docs/ folder
  final List<CustomPage> pages;           // custom pages from config
}
```

### DefaultHeader / DefaultFooter / DefaultSidebar (lib/src/components/defaults/)
Library-provided default layout components.
- `DefaultHeader(title, navLinks, showThemeToggle)` - sticky header with nav
- `DefaultFooter(text)` - simple centered text footer
- `DefaultSidebar(items)` - collapsible navigation tree from docs structure
  - Renders `data-category`, `data-collapsed` attributes on categories for JS interactivity
  - Renders `data-path` attributes on links for active page highlighting
  - Categories have `role="button"` + `tabindex="0"` for keyboard accessibility
  - Uses `_slugify()` helper to generate stable category IDs for localStorage persistence

### ProjectGenerator (lib/src/core/project_generator.dart)
Creates `website/` subdirectory with its own `pubspec.yaml` during `docudart init`.
- `InitTemplate.defaultTemplate` - Basic setup
- `InitTemplate.full` - All features with examples, including sidebar subfolder showcase
- Uses `PackageResolver` to compute path dependency to docudart
- Generates wrapper components in `components/` (header.dart, footer.dart, sidebar.dart)
- Runs `dart pub get` in website/ after generation
- Looks for `README.md` in project root to auto-generate docs
- `_generateFullTemplateSubfolders()` - creates example subfolders for full template (always runs, even when README.md exists): `01-guides_expanded/` (expanded sidebar) and `02-advanced/` with nested `deployment/` (collapsed)

### SiteGenerator (lib/src/core/site_generator.dart)
Generates the managed Jaspr project in `website/.dart_tool/docudart/`.
- Accepts optional `websiteDir` parameter (defaults to cwd)
- `generate({bool fullClean = true})` — `fullClean: false` skips directory deletion and `dart pub get` (used during serve hot reload)
- Adds `docudart` as path dependency in managed project's pubspec
- Copies `config.dart`, `components/`, and `pages/` into managed project's `lib/`
- Home route uses `config.home` at runtime: if set, renders the home component; if null, redirects `/` to `/docs`
- Generates `site_context_data.dart` with auto-generated sidebar items
- Generates `layout.dart` that calls `config.header/footer/sidebar` functions
- Injects `config.themeMode` into generated `theme.js` as `forcedMode` (overrides localStorage when set to light/dark)
- If a layout function is null, that section is simply not rendered

### PackageResolver (lib/src/core/package_resolver.dart)
Resolves the docudart package installation path using `Isolate.resolvePackageUri`.
Used to generate the path dependency in `website/pubspec.yaml` and managed project pubspec.

### WorkspaceResolver (lib/src/core/workspace_resolver.dart)
Auto-detects the website directory for build/serve commands.
- Checks if cwd IS the website dir (has config.dart + pubspec.yaml)
- Checks for `website/` subdirectory
- Legacy: supports old-style config.dart directly in cwd

### ConfigLoader (lib/src/config/config_loader.dart)
Loads configuration with a two-step strategy:
1. **First**: Tries to parse `config.dart` via `ConfigEvaluator` (text-based regex parsing)
2. **Fallback**: If that fails, reads `pubspec.yaml` + `docudart.yaml` (YAML-based)
- **Important**: Absolutizes directory paths (docsDir, outputDir, assetsDir) relative to the loaded directory
- Function fields (home/header/footer/sidebar) are not extractable from text parsing — they're always null from ConfigEvaluator
- The managed Jaspr project imports config.dart directly to access function fields

### ConfigEvaluator (lib/src/config/config_evaluator.dart)
Parses serializable fields from `config.dart` by reading it as text (no subprocess).
- Reads `config.dart` as a string and extracts fields with regex
- Extracts: title, description, logo, docsDir, pagesDir, assetsDir, outputDir, baseUrl, cleanUrls, themeMode, primaryColor
- Skips commented lines for primaryColor extraction
- Returns `null` if config.dart doesn't exist or parsing fails (ConfigLoader falls back to YAML)
- **Why text-based?** Running config.dart as a subprocess fails because it imports `package:docudart` and user components that aren't resolvable in the CLI context

### DefaultTheme (lib/src/theme/default_theme.dart)
Flutter docs style theme with:
- Blue primary color (#0175C2)
- Light/dark mode colors
- Inter font family

## CLI Command Flow

### `docudart init`
1. `InitCommand` resolves target directory
2. Checks for existing `website/config.dart`
3. `ProjectGenerator.generate()` creates `website/` with all files including components/
4. Runs `dart pub get` in `website/`

### `docudart build`
1. `WorkspaceResolver.resolve()` finds `website/` directory
2. `ConfigLoader.load(websiteDir)` loads config with absolute paths
3. `SiteGenerator(config, websiteDir: websiteDir).generate()`:
   - Copies config.dart + components/ + pages/ into managed project
   - Generates site_context_data.dart with sidebar items
   - Generates layout.dart that delegates to config functions
4. Runs `dart run jaspr build` in `website/.dart_tool/docudart/`
5. Copies output to `website/build/web/` (or `--output` flag)

### `docudart serve`
1. Same as build steps 1-3 (uses `generate()` with `fullClean: true` for initial build)
2. Starts `DocuDartFileWatcher` (watches docs, assets, config.dart, components/, pages/)
3. Runs `dart run jaspr serve` in `website/.dart_tool/docudart/`
4. On file change: regenerates with `fullClean: false` (in-place update, no pub get) — Jaspr's native hot reload detects the changed files and re-renders

**Hot reload architecture**: `config.dart` uses a getter (`Config get config => Config(...)`) instead of a `final` variable. This is critical because Dart VM hot reload does NOT re-evaluate top-level `final` variables, but DOES re-evaluate getters on each access. When a file changes, `DocuDartFileWatcher` copies the updated files into the managed Jaspr project's `lib/`, and Jaspr's built-in `HotReloader` detects the changes, patches the VM, and re-evaluates the getter on the next request.

## Common Tasks

### Adding a New Config Option
1. Add field to `Config` in `lib/src/config/docudart_config.dart`
2. Add to constructor, `copyWith`, `toJson()`, and `fromJson()` methods
3. Update `ProjectGenerator` to use it in generated config.dart template
4. Update `SiteGenerator` to handle it when generating site

### Adding a New CLI Command
1. Create `lib/src/cli/commands/my_command.dart`
2. Extend `Command<int>` from `package:args`
3. Register in `DocuDartCliRunner` constructor

### Modifying Generated Site
The managed Jaspr site is generated in `SiteGenerator`:
- `_generatePubspec()` - pubspec.yaml (includes docudart path dep)
- `_generateMain()` - lib/main.server.dart, lib/main.client.dart
- `_copyUserFiles()` - copies config.dart + components/ + pages/ into lib/
- `_generateSiteContextData()` - lib/site_context_data.dart
- `_generateLayout()` - lib/layout.dart (calls config.header/footer/sidebar)
- `_generateApp()` - lib/app.dart with Router (home route uses config.home at runtime)
- `_generatePages()` - lib/pages/ directory (user pages copied by _copyUserFiles)
- `_generateDocsPageContent()` - lib/docs_page_content.dart
- `_generateStyles()` - web/styles.css (includes collapsible sidebar CSS with chevron + transitions)
- `_generateThemeScript()` - web/theme.js (theme toggle + sidebar collapse/expand + active link highlighting)

### Adding a Built-in Component
1. Create `lib/src/components/built_in/my_component.dart`
2. Register in ComponentRegistry (when implemented)
3. Add to component parser to recognize `<MyComponent>` in MD

## Code Patterns

### Config with Serialization Boundary
Config classes have `toJson()` and `fromJson()` for serialization.
Function fields (home/header/footer/sidebar) cannot be serialized — they're skipped in `toJson()` and set to null in `fromJson()`. The managed project imports config.dart directly to access them.

### Command Pattern (with WorkspaceResolver)
```dart
class MyCommand extends Command<int> {
  @override
  Future<int> run() async {
    final websiteDir = WorkspaceResolver.resolve();
    if (websiteDir == null) {
      CliPrinter.exception(DocuDartErrors.configNotFound());
      return 1;
    }
    final config = await ConfigLoader.load(websiteDir);
    final generator = SiteGenerator(config, websiteDir: websiteDir);
    // ...
    return 0;
  }
}
```

### File Generation Pattern
```dart
final content = '''
// Generated content
class Foo {
  // ...
}
''';
await File(path).writeAsString(content);
```

## Testing

**After making changes to code generation (SiteGenerator, ProjectGenerator, etc.), always test by regenerating the example project.** Use the `/regenerate` skill (or `/regenerate example`) which will:
1. Delete the `example/website/` directory
2. Re-run `docudart init --full` in the `example/` directory

This ensures the generated output reflects your changes. Then verify with `docudart build` and/or `docudart serve`.

```bash
# Quick test workflow (preferred):
# 1. Use /regenerate skill to regenerate example/website/
# 2. Then build:
cd example
dart run ../bin/docudart.dart build

# Manual test with a fresh project:
mkdir /tmp/test-docudart
cd /tmp/test-docudart
dart run /path/to/docudart/bin/docudart.dart init --full
dart run /path/to/docudart/bin/docudart.dart build
```

### Visual Testing with Playwright

**After changes that affect the generated website's appearance (styles, layout, templates, theme, landing page, etc.), you SHOULD visually verify the result using the Playwright skill.** This catches visual regressions that `dart analyze` and `dart test` cannot detect.

Workflow:
1. Build and serve the example site:
   ```bash
   cd example && dart run ../bin/docudart.dart serve &
   ```
2. Use the Playwright skill to take full-page screenshots (light + dark mode) and review them:
   - Write a Playwright script to `/tmp/playwright-test-*.js`
   - Capture screenshots at `http://localhost:8080`
   - Toggle the theme (click `.theme-toggle` button) and capture dark mode
   - Read the screenshot files to visually inspect the result
3. Stop the server when done:
   ```bash
   pkill -f "docudart.dart serve"; pkill -f "jaspr"
   ```

Use `headless: true` for automated checks. Key things to verify:
- Header renders correctly (title, nav links, theme toggle)
- Sidebar links are present with active item highlighted (blue bg)
- Sidebar categories have collapsible chevron, click to toggle
- Nested doc pages auto-expand parent categories
- Landing page hero section (title, description, CTA button)
- Footer with copyright text
- Dark mode colors apply correctly
- Doc pages render markdown content properly

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
| `collection` | Collection utilities |
| `meta` | @immutable annotation |

## Important Notes

- `docudart` re-exports `package:jaspr/jaspr.dart` — users never import jaspr directly
- User's config is `config.dart` (Dart, not YAML) for IntelliSense and type safety
- `config.dart` must export a top-level getter `Config get config => Config(...)` (convention enforced by ProjectGenerator — getter is required for hot reload to work)
- `ConfigLoader` parses `config.dart` via text-based regex (`ConfigEvaluator`), falling back to YAML if it fails
- Function fields (home/header/footer/sidebar) cannot be extracted from text parsing — managed project imports config.dart directly
- All generated user files import `package:docudart/docudart.dart`
- `website/pubspec.yaml` uses a path dependency to docudart
- Generated Jaspr project lives in `website/.dart_tool/docudart/` and also has docudart as a path dependency
- ConfigLoader absolutizes directory paths relative to the website directory
- Clean URLs by default (`/docs/intro/` not `/docs/intro.html`)
- Theme mode (system/light/dark) via `themeMode` field — injected into `theme.js` as `forcedMode`; when set to light/dark it overrides localStorage; toggle still works for user override
- WorkspaceResolver supports backward compatibility with old flat structure
- **Dart hot reload caveat**: Top-level `final` variables are NOT re-evaluated on hot reload — that's why `config.dart` uses a getter (`Config get config =>`) instead of `final config =`
- `DocuDartFileWatcher` watches: docs/, assets/, config.dart (FileWatcher), components/, pages/; uses debounce + pending-regeneration queue to handle rapid edits
- **Sidebar interactivity** (all via vanilla JS in `theme.js`):
  - **Collapsible categories**: click/keyboard toggle, CSS chevron rotation + `max-height` transition, state persisted in `localStorage` (`docudart-sidebar-state` key)
  - **Active link highlighting**: `.sidebar-link.active` class applied via JS matching `window.location.pathname` against `data-path` attributes
  - **SPA navigation detection**: monkey-patches `history.pushState`/`replaceState` to dispatch `docudart-navigate` event; also listens for `popstate`; MutationObserver fallback if Jaspr re-renders sidebar
  - **Auto-expand**: parent categories of active link automatically expand on navigation
- **Sidebar collapse default**: ALL categories start collapsed by default. Add `_expanded` suffix to folder name (e.g., `01-guides_expanded/`) to make it start expanded. The suffix is stripped from display names, URLs, and sort order. `DocFolder.expanded` field carries this flag; `SidebarGenerator` sets `collapsed: !subfolder.expanded`.
- **Docs ordering**: numeric filename prefix (`01-guides/`) or `sidebar_position` frontmatter field; `index.md`/`intro.md` default to position 0; no prefix defaults to 999. The `_expanded` suffix is stripped before extracting numeric prefix.

## References

- [Jaspr Documentation](https://docs.jaspr.site/)
- [Jaspr LLMs.txt](https://jaspr.site/llms.txt) - Machine-readable Jaspr documentation (use this for AI-assisted development)
- [Docusaurus](https://docusaurus.io/) - Inspiration for features
