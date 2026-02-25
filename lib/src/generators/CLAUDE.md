# Generators

Code generation modules for DocuDart.

## Files

| File | Class | Purpose |
|------|-------|---------|
| `site_generator.dart` | `SiteGenerator` | Orchestrates managed Jaspr project generation in `.dart_tool/docudart/` |
| `project_generator.dart` | `ProjectGenerator` | Creates new user project via `docudart create` |
| `project_templates.dart` | `ProjectTemplates` | Template content (components, config, labels, pages, docs, README) |
| `styles_generator.dart` | `StylesGenerator` | Generates `styles.css` with theme colors, component styles, and mobile drawer CSS (`.sidebar-backdrop`, responsive sidebar at `<= 1024px`) |
| `theme_script_generator.dart` | `ThemeScriptGenerator` | Generates `theme.js` (toggle + sidebar + mobile drawer close + code block copy/label) and `live-reload.js` |
| `asset_path_generator.dart` | `AssetPathGenerator` | Scans `assets/` (with `light/`/`dark/` theme variants) → generates typed asset tree for `project_data.dart` |
| `sidebar_generator.dart` | `SidebarGenerator` | Converts `DocFolder` tree → `List<Doc>` for sidebar rendering |

## Architecture

### SiteGenerator (build/serve)

`SiteGenerator` is the central orchestrator called by `build` and `serve` commands. It delegates CSS/JS generation to `StylesGenerator` and `ThemeScriptGenerator`.

```
SiteGenerator.generate()
  ├─ ContentProcessor → DocFolder/DocPage tree
  ├─ SidebarGenerator → List<Doc>
  ├─ _generatePubspec()      — managed project pubspec.yaml
  ├─ _generateMain()         — main.server.dart, main.client.dart
  ├─ _copyUserFiles()        — config.dart, components/, pages/, labels.dart
  ├─ _generatePubspecData()  — pubspec_data.dart (const Pubspec)
  ├─ _generateProjectData()  — project_data.dart (Project with docs + pages + asset tree)
  ├─ _generateLayout()       — layout.dart (LayoutDelegate)
  ├─ _generateApp()          — app.dart (Router with ProjectProvider)
  ├─ _generateStyles()       → delegates to StylesGenerator
  │   ├─ StylesGenerator.generate()      — styles.css
  │   ├─ ThemeScriptGenerator.generateThemeScript() — theme.js
  │   └─ ThemeScriptGenerator.generateLiveReload()  — live-reload.js (serve only)
  └─ _copyAssets()           — static files to web/assets/
```

### ProjectGenerator (create)

`ProjectGenerator` handles `docudart create`. It delegates template content to `ProjectTemplates` and keeps infrastructure concerns (pubspec resolution, directory creation, asset copying, pub get, formatting) in the main class.

```
ProjectGenerator.generate()
  ├─ _loadPubspecInfo()           — read parent pubspec.yaml
  ├─ _resolvePubDevUrl()          — HEAD request to pub.dev
  ├─ _resolveLintDependency()     — propagate lints/flutter_lints
  ├─ _createDirectories()         — docs/, pages/, components/, etc.
  ├─ _generateWebsitePubspec()    — website pubspec.yaml
  ├─ ProjectTemplates
  │   ├─ .generateComponents()    — header.dart, footer.dart, button.dart, sidebar.dart
  │   ├─ .generateChangelogPage() — changelog_page.dart (if CHANGELOG.md exists)
  │   ├─ .generateConfig()        — config.dart
  │   ├─ .generateLabels()        — labels.dart
  │   ├─ .generateLandingPage()   — landing_page.dart
  │   ├─ .generateDocs()          — docs from README.md or example templates
  │   └─ .generateReadme()        — website README.md
  ├─ _generateFavicons()          — copy bundled favicon assets
  ├─ _generateLogo()              — copy bundled logo asset
  ├─ _updateGitignore()           — add .dart_tool/ and build/ entries
  ├─ dart pub get
  └─ dart format .
```

## Key Patterns

- **String templates**: Generated Dart/JS/CSS files use multi-line string interpolation
- **`_escapeForDart()`**: Escapes `\`, `'`, `$`, `\n`, `\r`, `\t` for safe embedding in Dart string literals
- **`_encodePreNewlines()`**: Replaces `\n` with `&#10;` inside `<pre>` blocks so Jaspr's SSR pretty-printer doesn't inject indentation whitespace into code. Applied to docs page HTML and changelog HTML before embedding.
- **Changelog pre-processing**: `_generateProjectData()` runs the raw CHANGELOG.md through `MarkdownProcessor` + `OpalHighlighter` at generation time, so `project_data.dart` stores highlighted HTML (not raw markdown). The `ChangelogPage` template renders it with `RawText`, not the `Markdown` component.
- **`writeAsString()` over `File.copy()`**: Triggers filesystem events for hot reload detection
- **Theme-aware assets**: `AssetPathGenerator.generateProjectAssets()` scans root, `light/`, `dark/` and merges into `SimpleAsset`/`ThemedAsset` tree embedded in `project_data.dart`

## @client Component Hydration Pipeline

Jaspr's `@client` annotation marks components for client-side hydration. The full pipeline for `@client` components to work in DocuDart:

1. **`jaspr_builder`** scans all packages (including dependencies) for `@client` classes
2. Generates `main.server.options.dart` (maps `@client` types to `ClientTarget`) and `main.client.options.dart` (deferred imports + `ClientLoader`)
3. Generates `web/main.client.dart` (web entrypoint) in the build cache — feeds into `build_web_compilers`
4. **`build_web_compilers`** compiles `web/main.client.dart` → `main.client.dart.js` via `dart2js`
5. Server uses `defaultServerOptions` to insert hydration comment markers (`<!--@pkg:component-->`) in SSR HTML
6. Server's `ClientScriptAdapter` auto-inserts `<script src="/main.client.dart.js" defer>` in `<head>`
7. In browser, `ClientApp` finds markers, loads deferred components via `ClientLoader`, and hydrates with live event handlers

### Critical: `build_web_compilers` in generated pubspec

The managed project's `pubspec.yaml` (generated by `SiteGenerator._generatePubspec()`) **must** include `build_web_compilers` in `dev_dependencies`. Without it, `dart2js` never compiles the client entrypoint and `main.client.dart.js` is never produced — `@client` components render HTML but their callbacks (like `onPressed`) never get wired up.

### Don't manually add client script tag

Jaspr's `ClientScriptAdapter` automatically inserts `<script src="/main.client.dart.js">` in the Document head when `@client` components exist (via `ServerOptions.clientId`). Do NOT add it manually in `_generateMain()` — that creates duplicate script tags.

### Placeholder options files

`SiteGenerator._generateMain()` writes placeholder `main.server.options.dart` and `main.client.options.dart` so imports resolve before `jaspr_builder` generates the real ones during the build. The placeholders have empty `ServerOptions()` / `ClientOptions()`.

## Known Limitations

- **All page HTML is embedded in `app.dart`**: Every `DocPage`'s full HTML content is embedded as a string literal in the generated `app.dart` route map. For very large documentation sets (1000+ pages), this could produce a multi-megabyte Dart file that is slow to compile. A future improvement could lazy-load HTML content from separate files instead of embedding everything inline.
