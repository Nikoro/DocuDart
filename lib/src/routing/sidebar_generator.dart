import '../core/content_processor.dart';

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
  /// Generate sidebar items from the docs folder structure.
  static List<GeneratedSidebarItem> generate({
    required DocFolder rootFolder,
  }) {
    return _generateFromFolder(rootFolder, 0);
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
