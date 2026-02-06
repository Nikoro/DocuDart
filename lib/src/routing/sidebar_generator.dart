import '../core/content_processor.dart';
import '../config/sidebar_config.dart';

/// Generated sidebar item for rendering.
class GeneratedSidebarItem {
  /// Display title.
  final String title;

  /// URL path (null for categories).
  final String? path;

  /// Whether this is a category (folder).
  final bool isCategory;

  /// Child items (for categories).
  final List<GeneratedSidebarItem> children;

  /// Whether the category is collapsed by default.
  final bool collapsed;

  /// Nesting depth (0 for root items).
  final int depth;

  const GeneratedSidebarItem({
    required this.title,
    this.path,
    this.isCategory = false,
    this.children = const [],
    this.collapsed = false,
    this.depth = 0,
  });

  /// Create a link item.
  factory GeneratedSidebarItem.link({
    required String title,
    required String path,
    int depth = 0,
  }) {
    return GeneratedSidebarItem(
      title: title,
      path: path,
      isCategory: false,
      depth: depth,
    );
  }

  /// Create a category item.
  factory GeneratedSidebarItem.category({
    required String title,
    required List<GeneratedSidebarItem> children,
    bool collapsed = false,
    int depth = 0,
  }) {
    return GeneratedSidebarItem(
      title: title,
      path: null,
      isCategory: true,
      children: children,
      collapsed: collapsed,
      depth: depth,
    );
  }
}

/// Generates sidebar structure from documentation pages.
class SidebarGenerator {
  /// Generate sidebar items from processed docs and config.
  ///
  /// If [config.autoGenerate] is true, generates from folder structure.
  /// Manual items from config are merged/override auto-generated ones.
  static List<GeneratedSidebarItem> generate({
    required DocFolder rootFolder,
    required SidebarConfig config,
  }) {
    if (!config.autoGenerate) {
      // Only use manual items
      return _convertManualItems(config.items, 0);
    }

    // Auto-generate from folder structure
    final autoItems = _generateFromFolder(rootFolder, 0);

    // Merge with manual items if any
    if (config.items.isEmpty) {
      return autoItems;
    }

    return _mergeItems(autoItems, _convertManualItems(config.items, 0));
  }

  /// Generate sidebar items from a folder structure.
  static List<GeneratedSidebarItem> _generateFromFolder(
    DocFolder folder,
    int depth,
  ) {
    final items = <GeneratedSidebarItem>[];

    // Add pages from this folder
    for (final page in folder.pages) {
      // Skip pages that shouldn't be in sidebar
      if (!page.meta.showInSidebar) continue;

      items.add(
        GeneratedSidebarItem.link(
          title: page.sidebarTitle,
          path: page.urlPath,
          depth: depth,
        ),
      );
    }

    // Add subfolders as categories
    for (final subfolder in folder.folders) {
      final children = _generateFromFolder(subfolder, depth + 1);
      if (children.isNotEmpty) {
        items.add(
          GeneratedSidebarItem.category(
            title: subfolder.name,
            children: children,
            collapsed: depth > 0, // Collapse nested folders by default
            depth: depth,
          ),
        );
      }
    }

    return items;
  }

  /// Convert manual sidebar config items to generated items.
  static List<GeneratedSidebarItem> _convertManualItems(
    List<SidebarSection> sections,
    int depth,
  ) {
    final items = <GeneratedSidebarItem>[];

    for (final section in sections) {
      final children = <GeneratedSidebarItem>[];

      for (final item in section.items) {
        if (item is SidebarLink) {
          children.add(
            GeneratedSidebarItem.link(
              title: item.title,
              path: item.path,
              depth: depth + 1,
            ),
          );
        } else if (item is SidebarExternalLink) {
          children.add(
            GeneratedSidebarItem.link(
              title: item.title,
              path: item.url,
              depth: depth + 1,
            ),
          );
        }
      }

      items.add(
        GeneratedSidebarItem.category(
          title: section.title,
          children: children,
          collapsed: section.collapsed,
          depth: depth,
        ),
      );
    }

    return items;
  }

  /// Merge auto-generated items with manual items.
  /// Manual items override auto-generated ones with the same title.
  static List<GeneratedSidebarItem> _mergeItems(
    List<GeneratedSidebarItem> auto,
    List<GeneratedSidebarItem> manual,
  ) {
    final result = <GeneratedSidebarItem>[];
    final manualTitles = manual.map((m) => m.title.toLowerCase()).toSet();

    // Add auto items that aren't overridden
    for (final item in auto) {
      if (!manualTitles.contains(item.title.toLowerCase())) {
        result.add(item);
      }
    }

    // Add all manual items
    result.addAll(manual);

    return result;
  }

  /// Generate Dart code for sidebar items (for site generator).
  static String generateDartCode(List<GeneratedSidebarItem> items) {
    final buffer = StringBuffer();
    buffer.writeln('const sidebarItems = <Map<String, dynamic>>[');

    for (final item in items) {
      _writeItemCode(buffer, item, '  ');
    }

    buffer.writeln('];');
    return buffer.toString();
  }

  static void _writeItemCode(
    StringBuffer buffer,
    GeneratedSidebarItem item,
    String indent,
  ) {
    buffer.writeln('$indent{');
    buffer.writeln("$indent  'title': '${_escapeString(item.title)}',");

    if (item.path != null) {
      buffer.writeln("$indent  'path': '${item.path}',");
    }

    buffer.writeln("$indent  'isCategory': ${item.isCategory},");

    if (item.isCategory) {
      buffer.writeln("$indent  'collapsed': ${item.collapsed},");
      buffer.writeln("$indent  'children': [");
      for (final child in item.children) {
        _writeItemCode(buffer, child, '$indent    ');
      }
      buffer.writeln('$indent  ],');
    }

    buffer.writeln('$indent},');
  }

  static String _escapeString(String s) {
    return s.replaceAll("'", "\\'").replaceAll('\n', '\\n');
  }
}
