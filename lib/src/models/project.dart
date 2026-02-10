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
  });

  /// The user's project pubspec.yaml data.
  final Pubspec pubspec;

  /// Auto-generated documentation items from the docs folder structure.
  final List<Doc> docs;

  /// Auto-discovered pages from the pages/ directory.
  final List<Page> pages;

  /// Raw content of CHANGELOG.md from the parent project, if it exists.
  final String? changelog;
}
