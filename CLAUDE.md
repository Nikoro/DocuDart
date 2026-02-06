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
│       │   ├── docudart_config.dart     # Main DocuDartConfig (has toJson/fromJson)
│       │   ├── config_loader.dart       # Load config (evaluates config.dart, falls back to YAML)
│       │   ├── config_evaluator.dart    # Subprocess evaluation of config.dart
│       │   ├── sidebar_config.dart      # SidebarConfig, SidebarSection, SidebarLink
│       │   ├── header_config.dart       # HeaderConfig, NavLink
│       │   ├── footer_config.dart       # FooterConfig, FooterLink
│       │   ├── component_config.dart    # ComponentConfig
│       │   ├── versioning_config.dart   # VersioningConfig
│       │   ├── theme_config.dart        # DarkModeConfig enum
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
│       ├── pages/landing.dart
│       ├── components/
│       ├── assets/
│       └── themes/
├── CLAUDE.md                            # This file
└── pubspec.yaml
```

## Generated User Project Structure (after `docudart init`)

```
user-project/
  pubspec.yaml           # User's own project
  lib/                   # User's own code
  website/               # Created by docudart init
    pubspec.yaml         # Depends on docudart (path dependency)
    config.dart          # DocuDartConfig instance
    docs/                # Markdown documentation files
      index.md
      getting-started.md
    pages/               # Custom Jaspr page components
      landing.dart       # Landing page (imports package:docudart/docudart.dart)
    components/          # Custom Jaspr components
    assets/              # Static assets
    themes/              # Custom theme implementations
```

## Key Classes

### DocuDartConfig (lib/src/config/docudart_config.dart)
Main configuration class. All user settings flow through this.
```dart
DocuDartConfig(
  title: String?,
  description: String?,
  docsDir: String,        // default: 'docs' (absolutized by ConfigLoader)
  outputDir: String,      // default: 'build/web' (absolutized by ConfigLoader)
  theme: BaseTheme,       // default: DefaultTheme()
  sidebar: SidebarConfig,
  header: HeaderConfig,
  footer: FooterConfig,
  // ...
)
```

### ProjectGenerator (lib/src/core/project_generator.dart)
Creates `website/` subdirectory with its own `pubspec.yaml` during `docudart init`.
- `InitTemplate.defaultTemplate` - Basic setup
- `InitTemplate.full` - All features with examples
- Uses `PackageResolver` to compute path dependency to docudart
- Runs `dart pub get` in website/ after generation
- Looks for `README.md` in project root to auto-generate docs

### SiteGenerator (lib/src/core/site_generator.dart)
Generates the managed Jaspr project in `website/.dart_tool/docudart/`.
- Accepts optional `websiteDir` parameter (defaults to cwd)
- Creates pubspec.yaml, main.dart, app.dart
- Generates pages, components, styles
- Copies docs and assets

### PackageResolver (lib/src/core/package_resolver.dart)
Resolves the docudart package installation path using `Isolate.resolvePackageUri`.
Used to generate the path dependency in `website/pubspec.yaml`.

### WorkspaceResolver (lib/src/core/workspace_resolver.dart)
Auto-detects the website directory for build/serve commands.
- Checks if cwd IS the website dir (has config.dart + pubspec.yaml)
- Checks for `website/` subdirectory
- Legacy: supports old-style config.dart directly in cwd

### ConfigLoader (lib/src/config/config_loader.dart)
Loads configuration with a two-step strategy:
1. **First**: Tries to evaluate `config.dart` via `ConfigEvaluator` (subprocess that runs a temp Dart script)
2. **Fallback**: If that fails, reads `pubspec.yaml` + `docudart.yaml` (YAML-based)
- **Important**: Absolutizes directory paths (docsDir, outputDir, assetsDir) relative to the loaded directory
- This ensures downstream code (ContentProcessor, SiteGenerator) works with absolute paths

### ConfigEvaluator (lib/src/config/config_evaluator.dart)
Evaluates the user's `config.dart` by running a temporary Dart script as a subprocess.
- Generates a script at `website/.dart_tool/docudart_config_extract.dart`
- Script imports `config.dart`, calls `config.toJson()`, prints JSON to stdout
- CLI parses the JSON output → `DocuDartConfig.fromJson()`
- Cleans up the temp script after execution
- Returns `null` on failure (ConfigLoader falls back to YAML)

### DefaultTheme (lib/src/theme/default_theme.dart)
Flutter docs style theme with:
- Blue primary color (#0175C2)
- Light/dark mode colors
- Inter font family

## CLI Command Flow

### `docudart init`
1. `InitCommand` resolves target directory
2. Checks for existing `website/config.dart`
3. `ProjectGenerator.generate()` creates `website/` with all files
4. Runs `dart pub get` in `website/`

### `docudart build`
1. `WorkspaceResolver.resolve()` finds `website/` directory
2. `ConfigLoader.load(websiteDir)` loads config with absolute paths
3. `SiteGenerator(config, websiteDir: websiteDir).generate()` creates Jaspr project
4. Runs `dart run jaspr build` in `website/.dart_tool/docudart/`
5. Copies output to `website/build/web/` (or `--output` flag)

### `docudart serve`
1. Same as build steps 1-3
2. Starts `DocuDartFileWatcher` (watches docs, assets, config)
3. Runs `dart run jaspr serve` in `website/.dart_tool/docudart/`

## Common Tasks

### Adding a New Config Option
1. Add field to `DocuDartConfig` in `lib/src/config/docudart_config.dart`
2. Add to constructor, `copyWith`, `toJson()`, and `fromJson()` methods
3. If the field is in a sub-config class (e.g., `HeaderConfig`), update its `toJson()`/`fromJson()` too
4. Update `ProjectGenerator` to use it in generated config.dart template
5. Update `SiteGenerator` to handle it when generating site

### Adding a New CLI Command
1. Create `lib/src/cli/commands/my_command.dart`
2. Extend `Command<int>` from `package:args`
3. Register in `DocuDartCliRunner` constructor

### Modifying Generated Site
The managed Jaspr site is generated in `SiteGenerator`:
- `_generatePubspec()` - pubspec.yaml
- `_generateMain()` - lib/main.dart
- `_generateApp()` - lib/app.dart with Router
- `_generatePages()` - lib/pages/*.dart
- `_generateComponents()` - lib/components/*.dart
- `_generateStyles()` - web/styles.css

### Adding a Built-in Component
1. Create `lib/src/components/built_in/my_component.dart`
2. Register in ComponentRegistry (when implemented)
3. Add to component parser to recognize `<MyComponent>` in MD

## Code Patterns

### Immutable Config Classes with Serialization
All config classes have `toJson()` and `fromJson()` for subprocess evaluation of `config.dart`.
```dart
@immutable
class MyConfig {
  final String value;
  const MyConfig({this.value = 'default'});

  Map<String, dynamic> toJson() => {'value': value};

  factory MyConfig.fromJson(Map<String, dynamic> json) =>
      MyConfig(value: json['value'] as String? ?? 'default');
}
```
For sealed class hierarchies (e.g., `SidebarItem`), use a `type` discriminator field in `toJson()`.

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
- Sidebar links are present and properly listed
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
- `config.dart` must export a top-level `final config = DocuDartConfig(...)` variable (convention enforced by ProjectGenerator)
- `ConfigLoader` evaluates `config.dart` via subprocess (`ConfigEvaluator`), falling back to YAML if it fails
- All config classes have `toJson()`/`fromJson()` to support the subprocess serialization boundary
- All generated user files import `package:docudart/docudart.dart`
- `website/pubspec.yaml` uses a path dependency to docudart
- Generated Jaspr project lives in `website/.dart_tool/docudart/`
- ConfigLoader absolutizes directory paths relative to the website directory
- Clean URLs by default (`/docs/intro/` not `/docs/intro.html`)
- Dark mode follows system preference by default; theme toggle button added when `showThemeToggle: true`
- WorkspaceResolver supports backward compatibility with old flat structure

## References

- [plan.md](plan.md) - Detailed implementation plan
- [Jaspr Documentation](https://docs.jaspr.site/)
- [Jaspr LLMs.txt](https://jaspr.site/llms.txt) - Machine-readable Jaspr documentation (use this for AI-assisted development)
- [Docusaurus](https://docusaurus.io/) - Inspiration for features
