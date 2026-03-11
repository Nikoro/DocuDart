import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import 'package:docudart/src/markdown/markdown_processor.dart';
import 'package:docudart/src/markdown/opal_highlighter.dart';

/// A component that renders a raw markdown string as formatted HTML.
///
/// Uses the same markdown processing pipeline as docs pages, including
/// support for embedded components (Callout, Tabs, CodeBlock, etc.).
///
/// ```dart
/// Markdown(content: '# Hello\n\nSome **bold** text.')
/// Markdown(content: context.project.changelog ?? '')
/// ```
class Markdown extends StatelessComponent {
  const Markdown({
    required this.content,
    this.classes,
    this.highlighter,
    super.key,
  });

  /// The raw markdown string to render.
  final String content;

  /// Optional CSS classes for the wrapper div.
  /// Defaults to `'docs-content'` to reuse existing markdown styles.
  final String? classes;

  /// Optional build-time syntax highlighter for code blocks.
  final OpalHighlighter? highlighter;

  static final _preBlockPattern = RegExp(r'<pre[\s>][\s\S]*?</pre>');

  @override
  Component build(BuildContext context) {
    if (content.isEmpty) {
      return div(classes: classes ?? 'docs-content', []);
    }

    final result = MarkdownProcessor(highlighter: highlighter).process(content);

    // Encode newlines inside <pre> blocks as &#10; so Jaspr's SSR
    // pretty-printer doesn't inject indentation whitespace into code.
    final html = result.html.replaceAllMapped(_preBlockPattern, (match) {
      return match.group(0)!.replaceAll('\n', '&#10;');
    });

    return div(classes: classes ?? 'docs-content', [RawText(html)]);
  }
}
