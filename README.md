<p align="center">
  <a alt="DocuDart Logo" href="https://pub.dev/packages/docudart"><img src="https://raw.githubusercontent.com/nikoro/docudart/main/logo/logo-long.webp" width="500"/></a>
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
- **Rich Markdown components** — `Callout`, `Tabs`, `CodeBlock`, `Card` / `CardGrid` embedded via MDX-like syntax
- **Live reload** — Instant preview with `docudart serve`
- **Light & dark mode** — System preference detection with manual toggle
- **Responsive design** — Mobile sidebar drawer, CSS breakpoints via `context.screen`
- **Flutter-like API** — `Row`, `Column`, `IconButton`, `SlideTransition` — looks like Flutter, outputs HTML/CSS/JS
- **52,000+ icons** — 7 icon families (Material, Lucide, Tabler, Font Awesome, Fluent, Remix, Material Symbols)
- **Collapsible sidebar** — Auto-generated from folder structure with `_expanded` suffix control
- **Type-safe config** — `config.dart` with full IntelliSense, not YAML
- **Custom pages** — Add Jaspr components to `pages/` for landing pages, changelogs, etc.
- **Type-safe assets** — `context.project.assets.logo.logo_webp` auto-generated from your `assets/` directory
- **Theming** — 3 built-in presets (Classic, Material 3, shadcn) with seed color support
- **Auto-discovered pages** — Just add a `.dart` file to `pages/` and link to it
- **SEO built-in** — Canonical URLs, Open Graph tags, JSON-LD, and `noindex` frontmatter support
- **Accessible** — Skip-to-content link, `aria-expanded` attributes, keyboard navigation, semantic HTML

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

## CLI Reference

| Command | Description |
|---------|-------------|
| `docudart create [name]` | Scaffold a new project. `--full` for all features, `--directory` to set target. |
| `docudart serve` | Dev server with live reload. `--port` (default `8080`), `--no-watch` to disable. |
| `docudart build` | Build for production. `--output` to override output directory. |
| `docudart update` | Update DocuDart to the latest version. |
| `docudart version` | Print current version and check for updates. |

## Markdown Components

Embed rich components directly in your Markdown files using MDX-like syntax:

### Callout

```markdown
<Callout type="tip" title="Did you know?">
DocuDart supports **Markdown** inside components.
</Callout>
```

Available types: `info`, `tip`, `warning`, `danger`, `note`.

### Tabs

```markdown
<Tabs>
<Tab label="Dart">
Content for the Dart tab.
</Tab>
<Tab label="Flutter">
Content for the Flutter tab.
</Tab>
</Tabs>
```

### CodeBlock

```markdown
<CodeBlock language="dart" title="main.dart" lineNumbers={true}>
void main() => print('Hello, DocuDart!');
</CodeBlock>
```

### Card Grid

```markdown
<CardGrid cols={3}>
<Card title="Quick Start" icon="🚀" href="/docs/quick-start">
Get up and running in minutes.
</Card>
<Card title="Theming" icon="🎨" href="/docs/theming">
Customize colors and presets.
</Card>
</CardGrid>
```

## Responsive Design

Use `context.screen` for CSS-based responsive layouts with no JavaScript:

```dart
context.screen.when(
  desktop: () => Row(children: [sidebar, content]),
  tablet: () => Column(children: [topNav, content]),
  mobile: () => Column(children: [content]),
);
```

Breakpoints: mobile ≤ 768px, tablet 769–1024px, desktop 1025px+.

## Configuration

DocuDart uses a `config.dart` file (not YAML) for type-safe configuration:

```dart
import 'package:docudart/docudart.dart';

Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  description: context.project.pubspec.description,
  themeMode: .system,
  home: () => LandingPage(title: 'My Project'),
  header: () => Header(
    leading: Logo(title: 'My Project'),
    links: [.path('/docs', label: 'Docs')],
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
