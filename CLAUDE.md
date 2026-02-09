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
│       ├── assets/                      # Bundled assets copied during init
│       │   ├── favicon/                 # Default favicon files
│       │   └── logo/logo.webp           # Default logo (128x128 WebP)
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
│       │   ├── link.dart                # Link (path/url navigation with leading/trailing support)
│       │   ├── repository.dart         # Repository (URL with auto-detected provider label/icon)
│       │   ├── setup.dart              # ConfigureFunction typedef
│       │   ├── project.dart            # Project (pubspec + docs + pages context object)
│       │   ├── pubspec.dart            # Pubspec model (parsed from pubspec.yaml)
│       │   ├── versioning_config.dart   # VersioningConfig
│       │   ├── theme_config.dart        # ThemeMode enum (system, light, dark)
│       │   └── custom_page.dart         # CustomPage
│       ├── core/                        # Core functionality
│       │   ├── asset_path_generator.dart # Generate type-safe asset paths
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
│       │   ├── defaults/               # Default layout + composable components
│       │   │   ├── logo.dart            # Logo component (clickable image + title)
│       │   │   ├── copyright.dart        # Copyright component (© year text)
│       │   │   ├── built_with_docudart.dart # BuiltWithDocuDart branding link
│       │   │   ├── default_sidebar.dart # DefaultSidebar component
│       │   │   ├── theme_toggle.dart    # ThemeToggle (light/dark icon swap)
│       │   │   ├── socials.dart         # Socials (social media icon links)
│       │   │   └── topics.dart          # Topics (topic tag links with optional title)
│       │   ├── layout/                # Flutter-like layout primitives
│       │   │   ├── flex_enums.dart     # MainAxisAlignment, CrossAxisAlignment, MainAxisSize
│       │   │   ├── row.dart            # Row + Column components
│       │   │   ├── flexible.dart       # Flexible component + FlexFit enum
│       │   │   ├── expanded.dart       # Expanded component
│       │   │   └── spacer.dart         # Spacer component
│       │   └── built_in/               # Built-in markdown component styles/scripts
│       │       ├── callout.dart
│       │       ├── tabs.dart
│       │       ├── code_block.dart
│       │       └── version_switcher.dart
│       ├── extensions/                  # Dart extensions (re-exported to users)
│       │   ├── extensions.dart          # Barrel file
│       │   └── object_extensions.dart   # .let() extension on T?
│       └── routing/
│           └── sidebar_generator.dart   # Generate sidebar from folder structure
├── example/                             # Example DocuDart project
│   ├── pubspec.yaml                     # Example Dart project
│   ├── lib/                             # Example project code
│   ├── README.md
│   └── website/                         # DocuDart documentation site
│       ├── pubspec.yaml                 # Depends on docudart via path: ../../
│       ├── config.dart
│       ├── icons.dart                       # SVG icon constants (Icons.github, Icons.pubDev, etc.)
│       ├── labels.dart                      # Label string constants (Labels.github, Labels.docs, etc.)
│       ├── docs/
│       ├── pages/landing_page.dart
│       ├── pages/changelog_page.dart  # Conditionally generated (when CHANGELOG.md exists)
│       ├── components/
│       │   ├── header.dart              # Header component (renders header > Row directly)
│       │   ├── footer.dart              # Footer component (leading/center/trailing slots)
│       │   └── sidebar.dart             # Sidebar wrapping DefaultSidebar
│       ├── assets/
│       │   └── assets.dart              # AUTO-GENERATED type-safe asset paths
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
    config.dart          # configure() function returning Config + header/footer/sidebar
    icons.dart           # SVG icon constants (Icons.github, Icons.pubDev, Icons.docs, etc.)
    labels.dart          # Label string constants (Labels.github, Labels.docs, etc.)
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
      changelog_page.dart # Changelog page (only if CHANGELOG.md exists in parent project)
    components/          # Layout wrapper components
      header.dart        # Header component (renders header > Row directly)
      footer.dart        # Footer component (leading/center/trailing slots)
      sidebar.dart       # Sidebar component wrapping DefaultSidebar
    assets/              # Static assets
      assets.dart        # AUTO-GENERATED type-safe asset paths (do not edit)
      logo/              # Default logo (WebP)
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
  assetsDir: String,        // default: 'assets' (absolutized by ConfigLoader)
  outputDir: String,        // default: 'build/web' (absolutized by ConfigLoader)
  theme: BaseTheme,         // default: DefaultTheme()
  themeMode: ThemeMode,     // default: ThemeMode.system (system | light | dark)
  versioning: VersioningConfig?, // optional versioning support
  customPages: List<CustomPage>, // custom Dart/Jaspr pages
  home: Component? Function()?,      // null function = redirect '/' to '/docs'; null return = same
  header: Component? Function()?,   // null = no header
  footer: Component? Function()?,   // null = no footer
  sidebar: Component? Function()?,  // null = no sidebar
)
```
- Home, header, footer, sidebar are nullable zero-arg function fields returning `Component?`
- **Double nullability**: both the function itself and its return value can be null — if the function is null or returns null, the section is not rendered
- When `home` is set, `/` renders the home component (no sidebar); when null, `/` redirects to `/docs`
- Context (pubspec, docs, pages) is available via the `project` parameter of `configure()` — accessed through closures in function fields
- `toJson()` skips function fields; `fromJson()` sets them to null
- Not `const` (functions prevent const constructors)

### configure() + Project + Pubspec (config.dart, lib/src/config/project.dart, pubspec.dart)
The user exports a `configure()` function from `config.dart` that receives a `Project` and returns a `Config`.
```dart
// config.dart — user writes this:
Config configure(Project project) => Config(
  title: project.pubspec.name,
  description: project.pubspec.description,
  home: () => project.pubspec.let(
    (pubspec) => LandingPage(title: pubspec.name, description: pubspec.description),
  ),
  sidebar: () => Sidebar(items: project.docs),
);
```
- `.let()` extension (Kotlin-style) on `T?` — enables null-safe scoping: `value.let((it) => transform(it))` returns null if value is null
- Generated layout/app code imports `config.dart` and calls `configure(project)` directly — no registration pattern
- `Project` holds: `pubspec` (Pubspec), `docs` (List<GeneratedSidebarItem>), `pages` (List<CustomPage>)
- `Pubspec` is an immutable model with: `name` (required), `version`, `description`, `homepage`, `repository` (`Repository?`), `issueTracker`, `documentation`, `publishTo`, `funding`, `topics`, `environment`

### Link (lib/src/config/link.dart)
Self-rendering navigation link (`StatelessComponent`) with optional leading/trailing icon components and label. Uses `Row` internally for horizontal layout.
```dart
Link.path('/docs', label: 'Docs', leading: Icons.docs)                              // internal path
Link.url('https://github.com', label: 'GitHub', leading: Icons.github, trailing: Icons.openInNew)  // external URL with trailing icon
Link.url('https://pub.dev', leading: someIconComponent)                              // leading-only
Link.path('/about', label: 'About')                                                  // label-only
```
- Extends `StatelessComponent` — renders itself as `<a class="{classes}">` wrapping a `Row(mainAxisSize: .min, spacing: 0.375.em)`
- `label` (`String?`), `leading` (`Component?`), `trailing` (`Component?`) — at least one required
- `classes` (`String`, defaults to `'nav-link'`): CSS class on the `<a>` element; icon wrappers use `'{classes}-icon'`
- Handles `target="_blank" rel="noopener noreferrer"` for external links, `data-path` for internal links (used by active-link JS)
- Consumers (Header, Socials, Topics) simply spread Links: `...?links` / `[...links]`
- `leading`/`trailing` accept any Jaspr `Component` (typically `RawText('<svg>...</svg>')`)
- Fields `_path`/`_url` are private; public API: `.href`, `.isExternal`
- `toJson()` uses `'label'` key, skips `leading`/`trailing`; `fromJson()` accepts legacy `'title'` key
- Default constructor is private (`Link._`); only `.path()` and `.url()` are public
- **Dart keyword gotcha**: `external`/`internal` are reserved — that's why constructors are `.url()`/`.path()` (fields renamed to `_url`/`_path` to avoid clash)

### Repository (lib/src/config/repository.dart)
Wraps a repository URL string with auto-detected provider label and icon.
```dart
const repo = Repository('https://github.com/user/repo');
repo.link   // 'https://github.com/user/repo'
repo.label  // 'GitHub' (auto-detected from host)
repo.icon   // Component (SVG icon for GitHub)
```
- `const` constructible — works in `const Pubspec(repository: Repository('...'))`
- Provider detection uses `host.contains()`: `github` → GitHub, `gitlab` → GitLab, `bitbucket` → Bitbucket, else generic link icon
- SVG icons embedded as static constants (same SVGs as generated `icons.dart`)
- Used in generated config.dart: `?project.pubspec.repository.let((repository) => .url(repository.link, label: repository.label, leading: repository.icon, trailing: Icons.openInNew))`
- `==` / `hashCode` based on `link` field

### Logo (lib/src/components/defaults/logo.dart)
Clickable logo component with optional image and/or title.
```dart
Logo(title: 'My Project')
Logo(image: img(src: Assets.logo.logo_webp, alt: 'Logo'), title: 'My Project')
Logo(image: img(src: Assets.logo.logo_svg, alt: 'Logo'), href: '/home')
```
- `image` (`Component?`) — image component (e.g., `img(src: ...)`)
- `title` (`String?`) — text title
- `href` (`String`) — link target, defaults to `"/"`
- At least one of `image` or `title` required (assert)
- CSS: `.logo` (inline-flex, no link decoration via `:visited`), `.logo-image` (1.75rem height), `.logo-title` (1.25rem semibold)

### Copyright / BuiltWithDocuDart (lib/src/components/defaults/)
Composable footer content components.
- `Copyright(text:)` - renders `<p>` with `© {year} {text}` (year from `DateTime.now().year`)
- `BuiltWithDocuDart()` - renders `<p class="built-with">` with "Built with DocuDart" link

### DefaultSidebar (lib/src/components/defaults/)
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
- Generates wrapper components in `components/` (header.dart, footer.dart, sidebar.dart); Header takes optional `leading` (typically `Logo`) + `links` + `trailing`; renders `header > Row` directly; Footer takes optional `leading`/`center`/`trailing` → `footer > Row` directly
- Generates default logo asset (`logo.webp`) in `assets/logo/` via `_generateLogo()` — same copy pattern as favicons
- `_generateAssetPaths()`: generates `assets/assets.dart` with typed asset path constants via `AssetPathGenerator`
- Generated config.dart `Logo(...)` uses `image: img(src: Assets.logo.logo_webp, alt: '...')` — type-safe asset reference
- Generates `icons.dart` at website root with default SVG icons (github, pubDev, docs, discord, youtube, etc.)
- Generates `labels.dart` at website root with label string constants (Labels.github, Labels.docs, Labels.changelog, Labels.topics, etc.)
- **Smart pub.dev URL**: `_resolvePubDevUrl()` makes a HEAD request to `https://pub.dev/packages/{name}` at init time; if 200, uses specific package URL, else falls back to generic `https://pub.dev` (5s timeout, graceful fallback on errors)
- **Smart repository link**: Generated config.dart uses `?project.pubspec.repository.let((repository) => .url(repository.link, label: repository.label, leading: repository.icon, trailing: Icons.openInNew))` for runtime provider detection with external link indicator; null-safe via `.let()` — if no repository, the entry is omitted
- **Lint dependency propagation**: `_resolveLintDependency()` checks parent's `pubspec.yaml` for `lints` or `flutter_lints` (in `dev_dependencies` then `dependencies`), propagates as `dev_dependency` in generated `website/pubspec.yaml`
- Runs `dart pub get` then `dart format .` in website/ after generation
- **Conditional changelog**: Checks for `CHANGELOG.md` in parent project root; if present, generates `pages/changelog_page.dart` via `_generateChangelogPage()` and adds `.path('/changelog', label: Labels.changelog)` link to header in config.dart; if absent, neither page nor link is generated
- Looks for `README.md` in project root to auto-generate docs
- `_generateFullTemplateSubfolders()` - creates example subfolders for full template (always runs, even when README.md exists): `01-guides_expanded/` (expanded sidebar) and `02-advanced/` with nested `deployment/` (collapsed)

### SiteGenerator (lib/src/core/site_generator.dart)
Generates the managed Jaspr project in `website/.dart_tool/docudart/`.
- Accepts optional `websiteDir` parameter (defaults to cwd) and `serveMode` flag (default: false)
- `serveMode: true` enables live-reload script injection (only during `docudart serve`)
- `generate({bool fullClean = true, Pubspec? pubspec})` — `fullClean: false` skips directory deletion and `dart pub get` (used during serve hot reload)
- Adds `docudart` as path dependency in managed project's pubspec
- Copies `config.dart`, `components/`, `pages/`, root-level `.dart` files (e.g. `icons.dart`), and `assets/assets.dart` into managed project's `lib/`
- Home route uses `configure(project).home?.call()` with pattern matching (`case final homeComponent?`): if non-null, renders the home component; otherwise redirects `/` to `/docs`
- **Page auto-discovery**: `_discoverPages()` scans `pages/` for `.dart` files, extracts class names via regex (`class X extends Stateless/StatefulComponent`), derives route paths from filenames (`changelog_page.dart` → `/changelog`). `_generateApp()` imports each discovered page and generates a `Route` wrapping it in `Layout(showSidebar: false)`. No manual `customPages` registration needed — just add a file to `pages/` and link to it.
- Generates `pubspec_data.dart` with const Pubspec from parent project's pubspec.yaml (repository field uses `Repository('...')` constructor)
- Generates `project_data.dart` with Project containing pubspec + auto-generated sidebar items
- Generates `layout.dart` that calls `configure(project)` then `config.header?.call()` etc.
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
- Extracts: title, description, docsDir, assetsDir, outputDir, themeMode, primaryColor
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
   - Loads pubspec.yaml for name, description, and repository
   - Checks pub.dev for package existence (HEAD request with 5s timeout)
   - Resolves lint dependency (`lints`/`flutter_lints`) from parent's pubspec.yaml
   - Generates config.dart with smart pub.dev URL and runtime repository detection
   - If `CHANGELOG.md` exists in project root: generates `pages/changelog_page.dart` and adds changelog header link
   - Copies default logo (`logo.webp`) and favicon assets into `website/assets/`
   - Generates `assets/assets.dart` with type-safe asset path constants
4. Runs `dart pub get` in `website/`
5. Runs `dart format .` in `website/`

### `docudart build`
1. `WorkspaceResolver.resolve()` finds `website/` directory
2. `ConfigLoader.load(websiteDir)` loads config with absolute paths
3. `ConfigLoader.loadParentPubspec(websiteDir)` reads parent project's pubspec.yaml
4. `SiteGenerator(config, websiteDir: websiteDir).generate(pubspec: pubspec)`:
   - Generates `assets/assets.dart` (type-safe asset paths) in website dir
   - Copies config.dart, root `.dart` files, components/, pages/, `assets/assets.dart` into managed project
   - Generates pubspec_data.dart + project_data.dart with Project/Pubspec data
   - Generates layout.dart that calls `configure(project)` then delegates to config functions
5. Runs `dart run jaspr build` in `website/.dart_tool/docudart/`
6. Copies output to `website/build/web/` (or `--output` flag)

### `docudart serve`
1. Same as build steps 1-3 (uses `generate()` with `fullClean: true` for initial build)
2. Starts `DocuDartFileWatcher` (watches docs, assets, all root `.dart` files, components/, pages/)
3. Runs `dart run jaspr serve` in `website/.dart_tool/docudart/`
4. On file change: regenerates with `fullClean: false` (in-place update, no pub get) → Jaspr rebuilds → browser auto-refreshes via live-reload polling
5. Jaspr's internal proxy logs (SocketException, shelf_proxy errors) are filtered out by `_shouldShowLog()` in `ServeCommand`

**Live reload**: During `docudart serve`, a `live-reload.js` script is injected into the HTML and a `live-reload-version.txt` file is written to the web directory. The JS polls the version file every 1 second. After each file change, DocuDart regenerates the site and bumps the version file — the browser detects the change and calls `location.reload()` automatically. This only runs during serve mode (`serveMode: true`); `docudart build` does not include the live-reload script.

**Log filtering**: Jaspr's serve runs an internal build daemon on a separate port; during reload transitions the proxy briefly disconnects, producing transient SocketException errors. `ServeCommand._shouldShowLog()` suppresses these noisy internal logs while preserving user-facing output. Process output is piped (not `inheritStdio`) and filtered line-by-line.

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
- `_generateAssetPaths()` - generates `website/assets/assets.dart` via `AssetPathGenerator` (type-safe asset constants)
- `_copyUserFiles()` - copies config.dart, root `.dart` files, components/, pages/, and `assets/assets.dart` into lib/
- `_generatePubspecData()` - lib/pubspec_data.dart (const Pubspec from parent pubspec.yaml)
- `_generateProjectData()` - lib/project_data.dart (Project with pubspec + sidebar items)
- `_generateLayout()` - lib/layout.dart (calls configure(project) then config.header/footer/sidebar)
- `_discoverPages()` - scans pages/ directory, extracts class names and derives route paths from filenames
- `_generateApp()` - lib/app.dart with Router (home + doc + auto-discovered custom page routes)
- `_generatePages()` - lib/pages/ directory (user pages copied by _copyUserFiles)
- `_generateDocsPageContent()` - lib/docs_page_content.dart
- `_generateStyles()` - web/styles.css (includes collapsible sidebar CSS with chevron + transitions)
- `_generateThemeScript()` - web/theme.js (theme toggle + sidebar collapse/expand + active link highlighting)
- `_generateLiveReload()` - web/live-reload.js + web/live-reload-version.txt (only when `serveMode: true`)
- `bumpLiveReloadVersion()` - public method; writes new timestamp to version file after each regeneration during serve

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

### Verifying Hot Reload with Playwright

Live reload works automatically during `docudart serve`. To verify with Playwright:

1. Start the server and open a page in Playwright (keep the same browser tab open)
2. Make a change to a watched file (e.g., change `Icons.docs` to `Icons.flutter` in `config.dart`)
3. Wait for `page.waitForEvent('framenavigated')` — the browser reloads itself via `live-reload.js`
4. Extract DOM values and compare — they should reflect the change
5. Stop the server: `pkill -f "docudart.dart serve"; pkill -f "jaspr"`

## Known Bugs

None currently tracked.

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

- `docudart` re-exports `package:jaspr/jaspr.dart` and Dart extensions (`.let()`) — users never import jaspr directly
- User's config is `config.dart` (Dart, not YAML) for IntelliSense and type safety
- `config.dart` must export a `Config configure(Project project)` function (convention enforced by ProjectGenerator — generated code imports config.dart and calls `configure(project)` directly)
- `ConfigLoader` parses `config.dart` via text-based regex (`ConfigEvaluator`), falling back to YAML if it fails
- Function fields (home/header/footer/sidebar) cannot be extracted from text parsing — managed project imports config.dart directly
- All generated user files import `package:docudart/docudart.dart`
- `website/pubspec.yaml` uses a path dependency to docudart
- Generated Jaspr project lives in `website/.dart_tool/docudart/` and also has docudart as a path dependency
- ConfigLoader absolutizes directory paths relative to the website directory
- Clean URLs by default (`/docs/intro/` not `/docs/intro.html`)
- Theme mode (system/light/dark) via `themeMode` field — injected into `theme.js` as `forcedMode`; when set to light/dark it overrides localStorage; toggle still works for user override
- WorkspaceResolver supports backward compatibility with old flat structure
- **Live reload**: `configure()` is a plain function — no lazy init, no stored callbacks. `_copyUserFiles()` uses `writeAsString` (not `File.copy()`) for reliable filesystem events. During serve, `live-reload.js` polls `live-reload-version.txt` every 1s; after regeneration, version is bumped and the browser auto-refreshes. The live-reload script is only injected during `docudart serve` (`serveMode: true`), not during `docudart build`.
- `DocuDartFileWatcher` watches: docs/, assets/, all root `.dart` files (config.dart, icons.dart, etc.), components/, pages/, and parent project's `pubspec.yaml`; uses debounce + pending-regeneration queue to handle rapid edits
- `_handleEvent()` skips `assets.dart` inside the assets dir to prevent infinite rebuild loops (it's regenerated on each build and lives inside the watched assets/ dir)
- **Sidebar interactivity** (all via vanilla JS in `theme.js`):
  - **Collapsible categories**: click/keyboard toggle, CSS chevron rotation + `max-height` transition, state persisted in `localStorage` (`docudart-sidebar-state` key)
  - **Active link highlighting**: `.sidebar-link.active` class applied via JS matching `window.location.pathname` against `data-path` attributes
  - **SPA navigation detection**: monkey-patches `history.pushState`/`replaceState` to dispatch `docudart-navigate` event; also listens for `popstate`; MutationObserver fallback if Jaspr re-renders sidebar
  - **Auto-expand**: parent categories of active link automatically expand on navigation
- **Sidebar collapse default**: ALL categories start collapsed by default. Add `_expanded` suffix to folder name (e.g., `01-guides_expanded/`) to make it start expanded. The suffix is stripped from display names, URLs, and sort order. `DocFolder.expanded` field carries this flag; `SidebarGenerator` sets `collapsed: !subfolder.expanded`.
- **Docs ordering**: numeric filename prefix (`01-guides/`) or `sidebar_position` frontmatter field; `index.md`/`intro.md` default to position 0; no prefix defaults to 999. The `_expanded` suffix is stripped before extracting numeric prefix.

- **Type-safe asset paths**: `AssetPathGenerator` scans `assets/` directory and generates `assets/assets.dart` with typed constants. Generated during both `init` (ProjectGenerator) and `build`/`serve` (SiteGenerator). File lives inside `assets/` dir to signal auto-generated nature (user should not edit). `_copyUserFiles()` copies it to managed project's `lib/assets/`. `_copyAssets()` skips `.dart` files to avoid copying it into `web/assets/`. Hot reload: `DocuDartFileWatcher` already watches assets/ — asset changes trigger regeneration of `assets.dart`. API: `Assets.logo.logo_webp` → `'/assets/logo/logo.webp'`. Subdirs become nested objects with `_Assets*` private classes. Identifiers use snake_case. Config.dart uses `import 'assets/assets.dart';`.

## References

- [Jaspr Documentation](https://docs.jaspr.site/)
- [Jaspr LLMs.txt](https://jaspr.site/llms.txt) - Machine-readable Jaspr documentation (use this for AI-assisted development)
- [Docusaurus](https://docusaurus.io/) - Inspiration for features
