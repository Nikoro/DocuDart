import '../routing/sidebar_generator.dart';
import 'custom_page.dart';
import 'pubspec.dart';

/// Project data passed to the [setup] callback.
///
/// Contains the project's pubspec metadata and auto-generated site
/// structure data that layout components may need.
class Project {
  /// The user's project pubspec.yaml data.
  final Pubspec pubspec;

  /// Auto-generated sidebar items from the docs folder structure.
  final List<GeneratedSidebarItem> docs;

  /// Custom pages registered in the config.
  final List<CustomPage> pages;

  const Project({
    required this.pubspec,
    required this.docs,
    required this.pages,
  });
}
