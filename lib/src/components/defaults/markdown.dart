import 'package:docudart/docudart.dart';

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
  const Markdown({required this.content, this.classes, super.key});

  /// The raw markdown string to render.
  final String content;

  /// Optional CSS classes for the wrapper div.
  /// Defaults to `'docs-content'` to reuse existing markdown styles.
  final String? classes;

  @override
  Component build(BuildContext context) {
    if (content.isEmpty) {
      return div(classes: classes ?? 'docs-content', []);
    }

    final result = MarkdownProcessor().process(content);

    return div(classes: classes ?? 'docs-content', [RawText(result.html)]);
  }
}
