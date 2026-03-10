---
title: Custom Pages
sidebar_position: 6
---

# Custom Pages

Add custom Dart pages to the `pages/` directory. Each `.dart` file is auto-discovered and becomes a route.

## Route mapping

The filename determines the route:

| File | Route |
|------|-------|
| `pages/landing_page.dart` | `/` (configured via `home` in config) |
| `pages/changelog_page.dart` | `/changelog` |
| `pages/about_page.dart` | `/about` |
| `pages/foo/bar_page.dart` | `/foo/bar` |

The `_page` suffix is stripped from the route, and underscores become hyphens.

## Landing page

The generated landing page reads from your pubspec:

```dart
import 'package:docudart/docudart.dart';

class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 1.5.rem,
      children: [
        Logo(image: context.project.assets.logo.logo_webp()),
        ?context.project.pubspec.name.let((t) => h1([.text(t)])),
        ?context.project.pubspec.description.let((d) => p([.text(d)])),
        Button.primary(text: 'Get Started', href: '/docs'),
      ],
    ).apply(classes: 'landing-page');
  }
}
```

Wire it up in `config.dart`:

```dart
home: () => LandingPage(),
```

Set `home: null` to skip the landing page and redirect `/` to `/docs`.

## Changelog page

If your project has a `CHANGELOG.md`, DocuDart auto-generates a changelog page with syntax highlighting and a table of contents:

```dart
import 'package:docudart/docudart.dart';

class ChangelogPage extends StatelessComponent {
  const ChangelogPage({super.key});

  @override
  Component build(BuildContext context) {
    final changelog = context.project.changelog;
    return Row(children: [
      Expanded(
        child: div(classes: 'docs-content', [
          RawText(changelog?.raw ?? ''),
        ]),
      ),
      if (changelog != null)
        TableOfContents(entries: changelog.toc, basePath: '/changelog/'),
      TocScrollSpy(),
    ]);
  }
}
```

The changelog HTML is pre-processed at build time — markdown is converted to HTML with syntax highlighting via Opal.

## Linking to custom pages

Add links to your custom pages in the header:

```dart
links: [
  .path('/docs', label: 'Docs'),
  .path('/changelog', label: 'Changelog'),
  .path('/about', label: 'About'),
],
```

You can also access discovered pages programmatically:

```dart
context.project.pages.map((p) => .path(p.path, label: p.name))
```
