import 'dart:convert';

import 'package:markdown/markdown.dart' as md;

import 'frontmatter_handler.dart';
import 'component_parser.dart';
import 'opal_highlighter.dart';
import '../components/content/component_registry.dart';

/// Result of processing a markdown file.
class ProcessedMarkdown {
  const ProcessedMarkdown({
    required this.meta,
    required this.html,
    required this.components,
    required this.tableOfContents,
  });

  /// Metadata from frontmatter.
  final PageMeta meta;

  /// Processed HTML content.
  final String html;

  /// Embedded components found in the content.
  final List<EmbeddedComponent> components;

  /// Table of contents extracted from headings.
  final List<TocEntry> tableOfContents;
}

/// Entry in the table of contents.
class TocEntry {
  const TocEntry({required this.text, required this.level, required this.id});

  /// Heading text.
  final String text;

  /// Heading level (1-6).
  final int level;

  /// Anchor ID for linking.
  final String id;
}

/// Processes markdown content into HTML with component support.
class MarkdownProcessor {
  MarkdownProcessor({ComponentRegistry? registry, this.highlighter})
    : _registry = registry ?? ComponentRegistry.withBuiltIns();

  /// Component registry for rendering embedded components.
  final ComponentRegistry _registry;

  /// Optional build-time syntax highlighter for code blocks.
  final OpalHighlighter? highlighter;

  /// Process markdown content from a file.
  ///
  /// 1. Parse frontmatter
  /// 2. Extract and replace embedded components with placeholders
  /// 3. Convert markdown to HTML
  /// 4. Extract table of contents
  /// 5. Replace placeholders with rendered components
  ProcessedMarkdown process(String content) {
    // Step 1: Parse frontmatter
    final (meta, markdownContent) = FrontmatterHandler.parseWithMeta(content);

    // Step 2: Extract embedded components
    final componentResult = ComponentParser.parse(markdownContent);

    // Step 3: Convert markdown to HTML
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubWeb,
      encodeHtml: false, // Allow HTML passthrough for components
    );

    final lines = componentResult.content.split('\n');
    final nodes = document.parseLines(lines);
    String html = md.renderToHtml(nodes);

    // Step 4: Extract table of contents
    final toc = _extractTableOfContents(nodes);

    // Step 5: Add IDs to headings for anchor links
    html = _addHeadingIds(html, toc);

    // Step 6: Replace component placeholders with rendered HTML
    html = _replaceComponentPlaceholders(html, componentResult.components);

    // Step 7: Apply build-time syntax highlighting to all code blocks
    if (highlighter != null) {
      html = highlighter!.highlightHtml(html);
    }

    return ProcessedMarkdown(
      meta: meta,
      html: html,
      components: componentResult.components,
      tableOfContents: toc,
    );
  }

  /// Replace component placeholders with rendered HTML.
  String _replaceComponentPlaceholders(
    String html,
    List<EmbeddedComponent> components,
  ) {
    String result = html;

    for (final component in components) {
      // Find the placeholder div
      final placeholder =
          '<div data-component="${component.placeholderId}"></div>';

      // Build the component HTML
      final componentHtml = _registry.buildComponent(component);

      if (componentHtml != null) {
        result = result.replaceAll(placeholder, componentHtml);
      } else {
        // Unknown component - render a warning
        result = result.replaceAll(
          placeholder,
          '<div class="component-unknown">Unknown component: ${htmlEscape.convert(component.name)}</div>',
        );
      }
    }

    return result;
  }

  /// Extract table of contents from parsed markdown nodes.
  List<TocEntry> _extractTableOfContents(List<md.Node> nodes) {
    final toc = <TocEntry>[];

    for (final node in nodes) {
      if (node is md.Element && node.tag.startsWith('h')) {
        final level = int.tryParse(node.tag.substring(1)) ?? 0;
        if (level >= 1 && level <= 6) {
          final text = _extractText(node);
          final id = _generateId(text);
          toc.add(TocEntry(text: text, level: level, id: id));
        }
      }
    }

    return toc;
  }

  /// Extract plain text from a markdown node.
  String _extractText(md.Node node) {
    if (node is md.Text) {
      return node.text;
    }
    if (node is md.Element) {
      return node.children?.map(_extractText).join('') ?? '';
    }
    return '';
  }

  /// Generate a URL-safe ID from heading text.
  ///
  /// Allows Unicode word characters for internationalization
  /// (e.g. "Café API" → "café-api").
  String _generateId(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Add IDs to heading elements in HTML.
  String _addHeadingIds(String html, List<TocEntry> toc) {
    String result = html;

    for (final entry in toc) {
      // Match heading tag without id attribute
      final pattern = RegExp(
        '<(h${entry.level})>([^<]*${RegExp.escape(entry.text)}[^<]*)</(h${entry.level})>',
        caseSensitive: false,
      );

      result = result.replaceFirstMapped(pattern, (match) {
        return '<${match.group(1)} id="${entry.id}">${match.group(2)}</${match.group(3)}>';
      });
    }

    return result;
  }
}
