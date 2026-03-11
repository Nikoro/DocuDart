import 'dart:convert';

import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

import 'package:docudart/src/markdown/frontmatter_handler.dart';
import 'package:docudart/src/markdown/component_parser.dart';
import 'package:docudart/src/markdown/opal_highlighter.dart';
import 'package:docudart/src/components/content/component_registry.dart';
import 'package:docudart/src/models/toc_entry.dart';
export '../models/toc_entry.dart';

/// Result of processing a markdown file.
@immutable
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

    // Step 3b: Escape angle brackets inside inline <code> tags.
    // With encodeHtml: false, backtick spans like `List<Object>` produce
    // raw `<Object>` which the browser parses as an HTML element.
    // We must not touch <pre><code> blocks (handled by opal).
    html = _escapeInlineCode(html);

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

  static final _nonWordPattern = RegExp(r'[^\w\s-]', unicode: true);
  static final _whitespacePattern = RegExp(r'\s+');
  static final _multiDashPattern = RegExp(r'-+');
  static final _edgeDashPattern = RegExp(r'^-|-$');

  /// Generate a URL-safe ID from heading text.
  ///
  /// Allows Unicode word characters for internationalization
  /// (e.g. "Café API" → "café-api").
  String _generateId(String text) {
    return text
        .toLowerCase()
        .replaceAll(_nonWordPattern, '')
        .replaceAll(_whitespacePattern, '-')
        .replaceAll(_multiDashPattern, '-')
        .replaceAll(_edgeDashPattern, '');
  }

  /// Escape `<` and `>` inside inline `<code>` tags so the browser doesn't
  /// parse them as real HTML elements (e.g. `List<Object>` → `List&lt;Object&gt;`).
  ///
  /// Skips `<pre><code>` blocks which are handled by the opal highlighter.
  static final _inlineCodePattern = RegExp(
    r'(?<!<pre>)<code>(.*?)</code>',
    dotAll: true,
  );

  String _escapeInlineCode(String html) {
    return html.replaceAllMapped(_inlineCodePattern, (match) {
      final content = match.group(1)!;
      final escaped = content
          .replaceAll('&', '&amp;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');
      return '<code>$escaped</code>';
    });
  }

  static final _headingPattern = RegExp(
    r'<(h[1-6])>(.*?)</\1>',
    caseSensitive: false,
  );

  /// Add IDs to heading elements in HTML.
  String _addHeadingIds(String html, List<TocEntry> toc) {
    // Build lookup: (level, text) -> id, consuming entries on first match.
    final lookup = <(int, String), String>{};
    for (final entry in toc) {
      lookup.putIfAbsent((entry.level, entry.text), () => entry.id);
    }
    final used = <(int, String)>{};

    return html.replaceAllMapped(_headingPattern, (match) {
      final tag = match.group(1)!;
      final content = match.group(2)!;
      final level = int.parse(tag.substring(1));

      // Find matching TOC entry by level and text content.
      for (final MapEntry(key: key, value: id) in lookup.entries) {
        final (entryLevel, entryText) = key;
        if (entryLevel == level &&
            content.contains(entryText) &&
            !used.contains(key)) {
          used.add(key);
          return '<$tag id="$id">$content</$tag>';
        }
      }

      return match.group(0)!;
    });
  }
}
