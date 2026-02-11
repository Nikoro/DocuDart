<p align="center">
  <a alt="DocuDart Logo" href="https://pub.dev/packages/docudart"><img src="./logo/logo-long2.png" width="500"/></a>
</p>
<h2 align="center">
A static documentation generator<br/>
powered by <a href="https://pub.dev/packages/jaspr">Jaspr</a>
</h2>
<p align="center">
  <a href="https://pub.dev/packages/docudart">
    <img alt="Pub Package" src="https://tinyurl.com/2bxjjh2p">
  </a>
  <a href="https://github.com/Nikoro/docudart/actions">
    <img alt="Build Status" src="https://img.shields.io/github/actions/workflow/status/Nikoro/docudart/ci.yaml?label=build">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://tinyurl.com/3uf9tzpy">
  </a>
  <a href="https://docudart.dev">
     <img alt="Documentation" src="https://img.shields.io/badge/docs-DocuDart-1FBCFE.svg?logoColor=white&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iNDhweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSI0OHB4IiBmaWxsPSIjMUVCQ0ZEIj48cGF0aCBkPSJNMzIwLTQ2MGgzMjB2LTYwSDMyMHY2MFptMCAxMjBoMzIwdi02MEgzMjB2NjBabTAgMTIwaDIwMHYtNjBIMzIwdjYwWk0yMjAtODBxLTI0IDAtNDItMTh0LTE4LTQydi02ODBxMC0yNCAxOC00MnQ0Mi0xOGgzNjFsMjE5IDIxOXY1MjFxMCAyNC0xOCA0MnQtNDIgMThIMjIwWm0zMzEtNTU0di0xODZIMjIwdjY4MGg1MjB2LTQ5NEg1NTFaTTIyMC04MjB2MTg2LTE4NiA2ODAtNjgwWiIvPjwvc3ZnPg==">
  </a>
</p>

## Features

- **Markdown-first** — Write docs in Markdown with YAML frontmatter
- **Live reload** — Instant preview with `docudart serve`
- **Light & dark mode** — System preference detection with manual toggle
- **52,000+ icons** — 7 icon families (Material, Lucide, Tabler, Font Awesome, Fluent, Remix, Material Symbols)
- **Collapsible sidebar** — Auto-generated from folder structure with `_expanded` suffix control
- **Type-safe config** — `config.dart` with full IntelliSense, not YAML
- **Custom pages** — Add Jaspr components to `pages/` for landing pages, changelogs, etc.
- **Type-safe assets** — `Assets.logo.logo_webp` auto-generated from your `assets/` directory
- **Theming** — Customizable colors, typography, and layout via code
- **Auto-discovered pages** — Just add a `.dart` file to `pages/` and link to it

## Quick Start

### Installation

```bash
dart pub global activate docudart
```

### Create a project

```bash
# Inside your Dart project directory:
docudart create --full
```

This creates a `docudart/` subdirectory with config, docs, components, and pages.

### Preview locally

```bash
docudart serve
```

Open `http://localhost:8080` — changes to docs, config, and components reload automatically.

### Build for production

```bash
docudart build
```

Output goes to `docudart/build/web/` — ready to deploy to any static hosting.

## Configuration

DocuDart uses a `config.dart` file (not YAML) for type-safe configuration:

```dart
import 'package:docudart/docudart.dart';

Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  description: context.project.pubspec.description,
  themeMode: ThemeMode.system,
  home: () => LandingPage(title: 'My Project'),
  header: () => Header(
    leading: Logo(title: 'My Project'),
    links: [Link.path('/docs', label: 'Docs')],
  ),
  sidebar: () => context.url.contains('/docs')
      ? Sidebar(items: context.project.docs)
      : null,
);
```

## Documentation Structure

```
docudart/
  config.dart          # Type-safe configuration
  docs/                # Markdown documentation
    index.md
    getting-started.md
    01-guides_expanded/ # _expanded = starts open in sidebar
      components.md
  pages/               # Custom Jaspr pages
    landing_page.dart
  components/          # Reusable components
    header.dart
    footer.dart
  assets/              # Static assets (logo, images)
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## License

MIT License — see [LICENSE](LICENSE) for details.
