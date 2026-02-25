import 'dart:io';

import 'package:path/path.dart' as p;

import '../cli/errors.dart';
import '../config/docudart_config.dart';
import '../markdown/markdown_processor.dart';
import '../markdown/opal_highlighter.dart';
import '../models/doc_content.dart';

export '../models/doc_content.dart';

/// Processes all documentation files in the docs directory.
class ContentProcessor {
  ContentProcessor(this.config)
    : _markdownProcessor = MarkdownProcessor(
        highlighter: OpalHighlighter(
          lightTheme: config.theme.markdownTheme.lightCodeTheme,
          darkTheme: config.theme.markdownTheme.darkCodeTheme,
        ),
      );
  final Config config;
  final MarkdownProcessor _markdownProcessor;

  static const _expandedSuffix = '_expanded';
  static const _docsPathPrefix = '/docs';
  static final _numericPrefixPattern = RegExp(r'^\d+[-_]?');
  static final _numericLeadingPattern = RegExp(r'^(\d+)');

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
    final isExpanded = baseName.endsWith(_expandedSuffix);

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
      final ProcessedMarkdown(:meta, :html, :tableOfContents) = processed;

      // Generate URL path
      final urlPath = _generateUrlPath(relativePath);

      // Determine order from filename or frontmatter
      final filename = p.basenameWithoutExtension(relativePath);
      final fileOrder = _extractOrder(filename);
      final order = meta.sidebarPosition ?? fileOrder;

      // Determine parent path
      final parentPath = p.dirname(relativePath);

      return DocPage(
        relativePath: relativePath,
        urlPath: urlPath,
        meta: meta,
        html: html,
        toc: tableOfContents,
        parentPath: parentPath == '.' ? null : parentPath,
        order: order,
      );
    } catch (e) {
      CliPrinter.warning('Failed to process $relativePath: $e');
      return null;
    }
  }

  String _generateUrlPath(String relativePath) {
    // Remove .md extension
    String path = relativePath.replaceAll('.md', '');

    // Remove _expanded suffix and numeric prefixes from path segments
    // Always use forward slashes for URLs, regardless of platform
    path = path
        .split(p.separator)
        .map((segment) {
          String s = segment;
          if (s.endsWith(_expandedSuffix)) {
            s = s.substring(0, s.length - _expandedSuffix.length);
          }
          return s.replaceFirst(_numericPrefixPattern, '');
        })
        .join('/');

    // Handle index files — use targeted removal to avoid corrupting
    // paths that contain "index" as a substring (e.g. "indexing-guide")
    if (path.endsWith('/index')) {
      path = path.substring(0, path.length - '/index'.length);
    } else if (path == 'index') {
      path = '';
    }

    // Ensure leading slash and clean URL format
    if (path.isEmpty) {
      return _docsPathPrefix;
    }

    return '$_docsPathPrefix/$path';
  }

  int _extractOrder(String name) {
    // Strip _expanded suffix before extracting order
    if (name.endsWith(_expandedSuffix)) {
      name = name.substring(0, name.length - _expandedSuffix.length);
    }
    // Extract numeric prefix (e.g., "01-getting-started" -> 1)
    final match = _numericLeadingPattern.firstMatch(name);
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

    String name = p.basename(relativePath);
    // Remove _expanded suffix
    if (name.endsWith(_expandedSuffix)) {
      name = name.substring(0, name.length - _expandedSuffix.length);
    }
    // Remove numeric prefix and convert to title case
    final withoutPrefix = name.replaceFirst(_numericPrefixPattern, '');
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
