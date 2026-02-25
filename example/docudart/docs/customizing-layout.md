---
title: Customizing Layout
sidebar_position: 4
---

The header, footer, and sidebar are components defined in `components/`. Edit them to customize your site's layout.

### Disabling a Section

Set any layout section to `null` in `config.dart` to hide it:

```dart
Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: null,    // No footer
  sidebar: null,   // No sidebar
);
```
