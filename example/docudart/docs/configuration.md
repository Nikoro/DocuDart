---
title: Configuration
sidebar_position: 5
---

All site settings live in `config.dart`:

```dart
import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';

Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  description: context.project.pubspec.description,

  // Theme
  themeMode: ThemeMode.system,  // system | light | dark
  theme: Theme.classic(
    seedColor: Colors.blue,     // accepts Colors.xxx or Color.value(0xAARRGGBB)
  ),

  // Layout components (set to null to hide)
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: () => Footer(center: Copyright(text: context.project.pubspec.name)),
  sidebar: () => Sidebar(),
);
```
