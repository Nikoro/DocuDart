import 'package:meta/meta.dart';

/// Configuration for sidebar navigation.
@immutable
class SidebarConfig {
  /// Whether to auto-generate sidebar from folder structure.
  final bool autoGenerate;

  /// Manual sidebar items (merged with auto-generated if autoGenerate is true).
  final List<SidebarSection> items;

  const SidebarConfig({
    this.autoGenerate = true,
    this.items = const [],
  });
}

/// A section in the sidebar with a title and items.
@immutable
class SidebarSection {
  /// Section title displayed in the sidebar.
  final String title;

  /// Items in this section.
  final List<SidebarItem> items;

  /// Whether this section is collapsed by default.
  final bool collapsed;

  const SidebarSection({
    required this.title,
    required this.items,
    this.collapsed = false,
  });
}

/// Base class for sidebar items.
@immutable
sealed class SidebarItem {
  const SidebarItem();
}

/// A link to a documentation page.
@immutable
class SidebarLink extends SidebarItem {
  /// Display title in the sidebar.
  final String title;

  /// Path to the page.
  final String path;

  const SidebarLink({
    required this.title,
    required this.path,
  });

  /// Creates a sidebar link that auto-detects pages from a folder.
  factory SidebarLink.auto(String folderPath) = AutoSidebarLink;
}

/// A sidebar link that auto-generates from a folder path.
@immutable
class AutoSidebarLink extends SidebarLink {
  const AutoSidebarLink(String folderPath)
      : super(title: '', path: folderPath);
}

/// An external link in the sidebar.
@immutable
class SidebarExternalLink extends SidebarItem {
  /// Display title in the sidebar.
  final String title;

  /// External URL.
  final String url;

  const SidebarExternalLink({
    required this.title,
    required this.url,
  });
}
