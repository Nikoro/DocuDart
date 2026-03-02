# Config

Configuration system for DocuDart. The user writes a `config.dart` that exports a `configure()` function returning a `Config`.

## Config Class (`docudart_config.dart`)

Main configuration — all user settings flow through this.

```dart
Config(
  title: String?,
  description: String?,
  siteUrl: String?,            // enables canonical URLs, OG tags, sitemap, robots.txt
  docsDir: String,             // default: 'docs' (absolutized by ConfigLoader)
  assetsDir: String,           // default: 'assets'
  outputDir: String,           // default: 'build/web'
  theme: Theme,                // default: Theme.classic()
  themeMode: ThemeMode,        // default: ThemeMode.system
  versioning: VersioningConfig?,
  home: Component? Function()?,      // null = redirect '/' to '/docs'
  header: Component? Function()?,
  footer: Component? Function()?,
  sidebar: Component? Function()?,
  layoutBuilder: LayoutBuilder?,     // null = use default Layout
  docsBuilder: DocsBuilder?,         // null = built-in TOC layout
)
```

### Double Nullability

Both the function itself and its return value can be null — if either is null, the section is not rendered. This enables conditional rendering:

```dart
sidebar: () => context.url.contains('/docs') ? Sidebar(items: context.project.docs) : null,
```

### Serialization Boundary

`toJson()` skips function fields; `fromJson()` sets them to null. The managed Jaspr project imports `config.dart` directly to access function fields. Not `const` (functions prevent const constructors).

## configure() Pattern (`setup.dart`)

```dart
// User writes this in config.dart:
Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  home: () => LandingPage(title: context.project.pubspec.name),
  sidebar: () => context.url.contains('/docs')
      ? Sidebar(items: context.project.docs)
      : null,
);
```

- Generated layout/app code imports `config.dart` and calls `configure(context)` directly
- Context (pubspec, docs, pages) available via `context.project` — accessed through closures
- `context.url` returns current URL path — enables conditional layout

### LayoutBuilder Typedef

```dart
typedef LayoutBuilder = Component Function({
  Component? header, Component? footer, Component? sidebar, Component? body,
});
```

Used by `Config.layoutBuilder` to fully replace the default `Layout` component.

### DocsBuilder Typedef

```dart
typedef DocsBuilder = Component Function(DocPageInfo page);
```

Used by `Config.docsBuilder` to customize the doc page body. When null, uses a built-in default (Row with content + TableOfContents + TocScrollSpy). `DocPageInfo` provides: `content` (Component), `toc` (List\<TocEntry\>), `title`, `urlPath`, `description`, `tags`.

## ConfigLoader (`config_loader.dart`)

Two-step loading strategy:

1. Tries `ConfigEvaluator` (text-based regex parsing of `config.dart`)
2. Falls back to `pubspec.yaml` + `docudart.yaml` (YAML-based)

- Absolutizes directory paths (docsDir, outputDir, assetsDir) relative to the loaded directory
- Function fields are always null from ConfigEvaluator — managed project imports config.dart directly
- `loadParentPubspec(websiteDir)` reads parent project's pubspec.yaml
- `loadParentChangelog(websiteDir)` reads CHANGELOG.md

## ConfigEvaluator (`config_evaluator.dart`)

Parses serializable fields from `config.dart` by reading it as **text** (no subprocess).

- Extracts: title, description, docsDir, assetsDir, outputDir, themeMode, theme (preset + seedColor)
- Detects theme preset (`.classic()`, `.material3()`, `.shadcn()`) and seedColor (`0xFF...`, `Colors.xxx`, `Color.value(0xFF...)`)
- Skips commented lines for theme extraction
- Returns null if parsing fails (ConfigLoader falls back to YAML)
- **Why text-based?** Running config.dart as a subprocess fails because it imports `package:docudart` and user components that aren't resolvable in the CLI context

## Naming

File is named `docudart_config.dart` (not `config.dart`) to avoid conflicts with the user's `config.dart` in generated projects. The barrel file `config.dart` in this directory re-exports the config types.
