---
title: Configuration
sidebar_position: 3
---

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
