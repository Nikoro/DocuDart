import 'package:jaspr/jaspr.dart';

import 'package:docudart/src/models/toc_entry.dart';

/// Information about a documentation page, passed to [DocsBuilder].
///
/// Contains the rendered content component, table of contents entries,
/// and page metadata. Extensible — new fields can be added without
/// breaking the [DocsBuilder] typedef.
@immutable
class DocPageInfo {
  const DocPageInfo({
    required this.content,
    required this.toc,
    required this.title,
    required this.urlPath,
    this.description,
    this.tags = const [],
  });

  /// The rendered HTML content as a Component (`div.docs-content > RawText`).
  final Component content;

  /// Heading entries extracted from the markdown content.
  final List<TocEntry> toc;

  /// Page title (from frontmatter or generated from filename).
  final String title;

  /// URL path for this page (e.g., `/docs/getting-started`).
  final String urlPath;

  /// Page description from frontmatter (used for SEO).
  final String? description;

  /// Tags from frontmatter for categorization.
  final List<String> tags;
}
