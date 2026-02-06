import 'package:meta/meta.dart';

/// Configuration for sidebar navigation.
@immutable
class SidebarConfig {
  /// Whether to auto-generate sidebar from folder structure.
  final bool autoGenerate;

  /// Manual sidebar items (merged with auto-generated if autoGenerate is true).
  final List<SidebarSection> items;

  const SidebarConfig({this.autoGenerate = true, this.items = const []});

  Map<String, dynamic> toJson() => {
    'autoGenerate': autoGenerate,
    'items': items.map((s) => s.toJson()).toList(),
  };

  factory SidebarConfig.fromJson(Map<String, dynamic> json) => SidebarConfig(
    autoGenerate: json['autoGenerate'] as bool? ?? true,
    items: (json['items'] as List<dynamic>?)
            ?.map((e) => SidebarSection.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
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

  Map<String, dynamic> toJson() => {
    'title': title,
    'items': items.map((i) => i.toJson()).toList(),
    'collapsed': collapsed,
  };

  factory SidebarSection.fromJson(Map<String, dynamic> json) => SidebarSection(
    title: json['title'] as String,
    items: (json['items'] as List<dynamic>?)
            ?.map((e) => SidebarItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    collapsed: json['collapsed'] as bool? ?? false,
  );
}

/// Base class for sidebar items.
@immutable
sealed class SidebarItem {
  const SidebarItem();

  Map<String, dynamic> toJson();

  static SidebarItem fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'auto':
        return AutoSidebarLink(json['path'] as String);
      case 'external':
        return SidebarExternalLink(
          title: json['title'] as String,
          url: json['url'] as String,
        );
      case 'link':
      default:
        return SidebarLink(
          title: json['title'] as String,
          path: json['path'] as String,
        );
    }
  }
}

/// A link to a documentation page.
@immutable
class SidebarLink extends SidebarItem {
  /// Display title in the sidebar.
  final String title;

  /// Path to the page.
  final String path;

  const SidebarLink({required this.title, required this.path});

  /// Creates a sidebar link that auto-detects pages from a folder.
  factory SidebarLink.auto(String folderPath) = AutoSidebarLink;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'link',
    'title': title,
    'path': path,
  };
}

/// A sidebar link that auto-generates from a folder path.
@immutable
class AutoSidebarLink extends SidebarLink {
  const AutoSidebarLink(String folderPath) : super(title: '', path: folderPath);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'auto',
    'path': path,
  };
}

/// An external link in the sidebar.
@immutable
class SidebarExternalLink extends SidebarItem {
  /// Display title in the sidebar.
  final String title;

  /// External URL.
  final String url;

  const SidebarExternalLink({required this.title, required this.url});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'external',
    'title': title,
    'url': url,
  };
}
