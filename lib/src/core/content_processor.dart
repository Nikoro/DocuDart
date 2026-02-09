import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/docudart_config.dart';
import '../markdown/markdown_processor.dart';
import '../markdown/frontmatter_handler.dart';

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

/// Processes all documentation files in the docs directory.
class ContentProcessor {
  ContentProcessor(this.config);
  final Config config;
  final MarkdownProcessor _markdownProcessor = MarkdownProcessor();

  /// Process all markdown files in the docs directory.
  ///
  /// Returns a list of processed pages and the folder structure.
  Future<(List<DocPage>, DocFolder)> processAll() async {
    final docsDir = Directory(config.docsDir);
    if (!docsDir.existsSync()) {
      return (
        const <DocPage>[],
        DocFolder(
          relativePath: '',
          name: 'Docs',
          order: 0,
          pages: [],
          folders: [],
        ),
      );
    }

    final allPages = <DocPage>[];
    final rootFolder = await _processDirectory(docsDir, '', allPages);

    // Sort pages by order
    allPages.sort((a, b) => a.order.compareTo(b.order));

    return (allPages, rootFolder);
  }

  /// Process a single markdown file.
  Future<DocPage?> processFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return null;

    final content = await file.readAsString();
    final relativePath = p.relative(filePath, from: config.docsDir);

    return _processMarkdownFile(content, relativePath);
  }

  Future<DocFolder> _processDirectory(
    Directory dir,
    String relativePath,
    List<DocPage> allPages,
  ) async {
    final pages = <DocPage>[];
    final folders = <DocFolder>[];

    await for (final entity in dir.list()) {
      final name = p.basename(entity.path);

      // Skip hidden files and folders
      if (name.startsWith('.')) continue;

      if (entity is File && name.endsWith('.md')) {
        final content = await entity.readAsString();
        final fileRelativePath = relativePath.isEmpty
            ? name
            : p.join(relativePath, name);

        final page = _processMarkdownFile(content, fileRelativePath);
        if (page != null) {
          pages.add(page);
          allPages.add(page);
        }
      } else if (entity is Directory) {
        final folderRelativePath = relativePath.isEmpty
            ? name
            : p.join(relativePath, name);

        final folder = await _processDirectory(
          entity,
          folderRelativePath,
          allPages,
        );
        folders.add(folder);
      }
    }

    // Sort pages and folders by order
    pages.sort((a, b) => a.order.compareTo(b.order));
    folders.sort((a, b) => a.order.compareTo(b.order));

    final baseName = p.basename(relativePath.isEmpty ? 'docs' : relativePath);
    final isExpanded = baseName.endsWith('_expanded');

    return DocFolder(
      relativePath: relativePath,
      name: _folderName(relativePath),
      order: _extractOrder(baseName),
      expanded: isExpanded,
      pages: pages,
      folders: folders,
    );
  }

  DocPage? _processMarkdownFile(String content, String relativePath) {
    try {
      final processed = _markdownProcessor.process(content);

      // Generate URL path
      final urlPath = _generateUrlPath(relativePath);

      // Determine order from filename or frontmatter
      final filename = p.basenameWithoutExtension(relativePath);
      final fileOrder = _extractOrder(filename);
      final order = processed.meta.sidebarPosition ?? fileOrder;

      // Determine parent path
      final parentPath = p.dirname(relativePath);

      return DocPage(
        relativePath: relativePath,
        urlPath: urlPath,
        meta: processed.meta,
        html: processed.html,
        toc: processed.tableOfContents,
        parentPath: parentPath == '.' ? null : parentPath,
        order: order,
      );
    } catch (e) {
      print('Warning: Failed to process $relativePath: $e');
      return null;
    }
  }

  String _generateUrlPath(String relativePath) {
    // Remove .md extension
    var path = relativePath.replaceAll('.md', '');

    // Remove _expanded suffix and numeric prefixes from path segments
    path = path
        .split(p.separator)
        .map((segment) {
          var s = segment;
          if (s.endsWith('_expanded')) {
            s = s.substring(0, s.length - '_expanded'.length);
          }
          return s.replaceFirst(RegExp(r'^\d+[-_]?'), '');
        })
        .join('/');

    // Handle index files
    if (path.endsWith('/index') || path == 'index') {
      path = path.replaceAll('/index', '').replaceAll('index', '');
    }

    // Ensure leading slash and clean URL format
    if (path.isEmpty) {
      return '/docs';
    }

    return '/docs/$path';
  }

  int _extractOrder(String name) {
    // Strip _expanded suffix before extracting order
    if (name.endsWith('_expanded')) {
      name = name.substring(0, name.length - '_expanded'.length);
    }
    // Extract numeric prefix (e.g., "01-getting-started" -> 1)
    final match = RegExp(r'^(\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 999;
    }

    // Special cases
    if (name == 'index' || name == 'intro' || name == 'introduction') {
      return 0;
    }

    return 999; // Default order
  }

  String _folderName(String relativePath) {
    if (relativePath.isEmpty) return 'Documentation';

    var name = p.basename(relativePath);
    // Remove _expanded suffix
    if (name.endsWith('_expanded')) {
      name = name.substring(0, name.length - '_expanded'.length);
    }
    // Remove numeric prefix and convert to title case
    final withoutPrefix = name.replaceFirst(RegExp(r'^\d+[-_]?'), '');
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
