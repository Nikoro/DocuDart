import '../routing/sidebar_generator.dart';
import 'custom_page.dart';

/// Context passed to header, footer, and sidebar builder functions.
///
/// Contains the processed site data that layout components may need
/// to render navigation, menus, or other site-aware UI.
class SiteContext {
  /// Auto-generated sidebar items from the docs folder structure.
  final List<GeneratedSidebarItem> docs;

  /// Custom pages registered in the config.
  final List<CustomPage> pages;

  const SiteContext({required this.docs, required this.pages});
}
