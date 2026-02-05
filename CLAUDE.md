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
config.dart      ─────────>
docs/*.md        ─────────>    SiteGenerator    ─────────>    .dart_tool/docudart/
pages/*.dart     ─────────>    (Jaspr project)  ─────────>    build/web/
components/      ─────────>
themes/          ─────────>
```

**Key Insight**: DocuDart generates a hidden Jaspr project in `.dart_tool/docudart/` which is then built by Jaspr to produce static HTML/CSS/JS.

## Project Structure

```
docudart/
├── bin/docudart.dart                    # CLI entry point
├── lib/
│   ├── docudart.dart                    # Library exports
│   └── src/
│       ├── cli/                         # CLI commands
│       │   ├── cli_runner.dart          # CommandRunner
│       │   └── commands/
│       │       ├── init_command.dart    # docudart init
│       │       ├── build_command.dart   # docudart build
│       │       └── serve_command.dart   # docudart serve
│       ├── config/                      # Configuration classes
│       │   ├── docudart_config.dart     # Main DocuDartConfig
│       │   ├── config_loader.dart       # Load config.dart
│       │   ├── sidebar_config.dart      # SidebarConfig, SidebarSection, SidebarLink
│       │   ├── header_config.dart       # HeaderConfig, NavLink
│       │   ├── footer_config.dart       # FooterConfig, FooterLink
│       │   ├── component_config.dart    # ComponentConfig
│       │   ├── versioning_config.dart   # VersioningConfig
│       │   ├── theme_config.dart        # DarkModeConfig enum
│       │   └── custom_page.dart         # CustomPage
│       ├── core/                        # Core functionality
│       │   ├── project_generator.dart   # Generate user project (init)
│       │   └── site_generator.dart      # Generate .dart_tool/docudart
│       └── theme/                       # Theming
│           ├── base_theme.dart          # Abstract BaseTheme
│           ├── default_theme.dart       # DefaultTheme (Flutter docs style)
│           ├── theme_colors.dart        # ThemeColors
│           └── theme_typography.dart    # ThemeTypography
├── plan.md                              # Detailed implementation plan
├── CLAUDE.md                            # This file
└── pubspec.yaml
```

## Key Classes

### DocuDartConfig (lib/src/config/docudart_config.dart)
Main configuration class. All user settings flow through this.
```dart
DocuDartConfig(
  title: String?,
  description: String?,
  docsDir: String,        // default: 'docs'
  outputDir: String,      // default: 'build/web'
  theme: BaseTheme,       // default: DefaultTheme()
  sidebar: SidebarConfig,
  header: HeaderConfig,
  footer: FooterConfig,
  // ...
)
```

### ProjectGenerator (lib/src/core/project_generator.dart)
Creates user project files during `docudart init`.
- `InitTemplate.defaultTemplate` - Basic setup
- `InitTemplate.full` - All features with examples

### SiteGenerator (lib/src/core/site_generator.dart)
Generates the managed Jaspr project in `.dart_tool/docudart/`.
- Creates pubspec.yaml, main.dart, app.dart
- Generates pages, components, styles
- Copies docs and assets

### DefaultTheme (lib/src/theme/default_theme.dart)
Flutter docs style theme with:
- Blue primary color (#0175C2)
- Light/dark mode colors
- Inter font family

## Implementation Status

### ✅ Completed (Phase 1)
- CLI with init/build/serve commands
- Configuration system (DocuDartConfig and related)
- Project generator (creates user project)
- Site generator (creates Jaspr project)
- Theme system (DefaultTheme)

### 🔲 Not Yet Implemented
- Markdown processing (convert MD to Jaspr components)
- Component embedding (`<Callout>`, `<Tabs>` in MD)
- Sidebar auto-generation from folder structure
- Hot reload file watching
- Version management
- Component auto-discovery

## Common Tasks

### Adding a New Config Option
1. Add field to `DocuDartConfig` in `lib/src/config/docudart_config.dart`
2. Add to constructor and `copyWith` method
3. Update `ProjectGenerator` to use it in generated config.dart template
4. Update `SiteGenerator` to handle it when generating site

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

### Immutable Config Classes
```dart
@immutable
class MyConfig {
  final String value;
  const MyConfig({this.value = 'default'});
}
```

### Command Pattern
```dart
class MyCommand extends Command<int> {
  @override
  String get name => 'mycommand';

  @override
  String get description => 'Does something';

  @override
  Future<int> run() async {
    // Implementation
    return 0; // exit code
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

```bash
# Test init command
mkdir /tmp/test-docudart
cd /tmp/test-docudart
dart run /path/to/docudart/bin/docudart.dart init --full
ls -la  # Verify structure

# Test generated config
cat config.dart

# Test build (requires init first)
dart run /path/to/docudart/bin/docudart.dart build
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `args` | CLI argument parsing |
| `path` | Path manipulation |
| `glob` | File pattern matching |
| `watcher` | File watching (hot reload) |
| `yaml` | YAML/frontmatter parsing |
| `markdown` | Markdown to HTML |
| `jaspr` | Web framework for SSG |
| `collection` | Collection utilities |
| `meta` | @immutable annotation |

## Next Steps (Priority Order)

1. **Markdown Processing** - Parse frontmatter, convert MD to HTML
2. **Content Processing** - Process all docs/*.md files
3. **Sidebar Generation** - Auto-generate from folder structure
4. **Component System** - `<Callout>`, `<Tabs>` in markdown
5. **Hot Reload** - Watch files and regenerate

## Important Notes

- User's config is `config.dart` (Dart, not YAML) for IntelliSense
- Generated Jaspr project lives in `.dart_tool/docudart/`
- Clean URLs by default (`/docs/intro/` not `/docs/intro.html`)
- Dark mode follows system preference by default
- No search or i18n in MVP

## References

- [plan.md](plan.md) - Detailed implementation plan
- [Jaspr Documentation](https://docs.jaspr.site/)
- [Docusaurus](https://docusaurus.io/) - Inspiration for features
