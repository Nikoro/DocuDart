import 'package:path/path.dart' as p;

import '../markdown/frontmatter_handler.dart';
import '../markdown/markdown_processor.dart';

/// Represents a processed documentation page.
class DocPage {
  const DocPage({
    required this.relativePath,
    required this.urlPath,
    required this.meta,
    required this.html,
    required this.toc,
    this.parentPath,
    required this.order,
  });

  /// File path relative to docs directory.
  final String relativePath;

  /// URL path for this page.
  final String urlPath;

  /// Page metadata from frontmatter.
  final PageMeta meta;

  /// Processed HTML content.
  final String html;

  /// Table of contents entries.
  final List<TocEntry> toc;

  /// Parent folder path (for sidebar grouping).
  final String? parentPath;

  /// Order for sorting (from filename prefix or frontmatter).
  final int order;

  /// Display title (from meta or generated from filename).
  String get title => meta.title ?? _titleFromPath(relativePath);

  /// Sidebar title (from meta or falls back to title).
  String get sidebarTitle => meta.sidebarTitle ?? title;

  static String _titleFromPath(String path) {
    final filename = p.basenameWithoutExtension(path);
    // Remove numeric prefix if present (e.g., "01-getting-started" -> "getting-started")
    final withoutPrefix = filename.replaceFirst(RegExp(r'^\d+[-_]?'), '');
    // Convert to title case
    return withoutPrefix
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

/// Represents a folder in the documentation structure.
class DocFolder {
  const DocFolder({
    required this.relativePath,
    required this.name,
    required this.order,
    this.expanded = false,
    required this.pages,
    required this.folders,
  });

  /// Folder path relative to docs directory.
  final String relativePath;

  /// Display name for the folder.
  final String name;

  /// Order for sorting.
  final int order;

  /// Whether the folder's sidebar category starts expanded.
  /// Set by the `_expanded` suffix on the folder name.
  final bool expanded;

  /// Child pages.
  final List<DocPage> pages;

  /// Child folders.
  final List<DocFolder> folders;
}
