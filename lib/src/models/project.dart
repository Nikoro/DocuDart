import 'doc.dart';
import 'page.dart';
import 'pubspec.dart';

/// Project data passed to the [setup] callback.
///
/// Contains the project's pubspec metadata and auto-generated site
/// structure data that layout components may need.
class Project {
  const Project({
    required this.pubspec,
    required this.docs,
    required this.pages,
    this.changelog,
    this.assets,
  });

  /// The user's project pubspec.yaml data.
  final Pubspec pubspec;

  /// Auto-generated documentation items from the docs folder structure.
  final List<Doc> docs;

  /// Auto-discovered pages from the pages/ directory.
  final List<Page> pages;

  /// Raw content of CHANGELOG.md from the parent project, if it exists.
  final String? changelog;

  /// Auto-generated asset tree from the assets/ directory.
  ///
  /// The concrete type is generated per-project (e.g. `_ProjectAssets`),
  /// so this field is typed as `dynamic` to accommodate any structure.
  ///
  /// Access assets via dot notation:
  /// ```dart
  /// context.project.assets.logo.logo_webp(alt: 'Logo')
  /// ```
  final dynamic assets;
}
