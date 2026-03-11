import 'package:test/test.dart';

import 'package:docudart/src/markdown/opal_highlighter.dart';
import 'package:docudart/src/theme/code_theme.dart';

void main() {
  late OpalHighlighter highlighter;

  setUp(() {
    highlighter = OpalHighlighter(
      lightTheme: const CodeTheme.dartDevLight(),
      darkTheme: const CodeTheme.dartDevDark(),
    );
  });

  group('highlightCodeBlock', () {
    test('highlights Dart code with colored spans', () {
      final html = highlighter.highlightCodeBlock('void main() {}', 'dart');

      expect(
        html,
        startsWith('<pre class="opal"><code class="language-dart">'),
      );
      expect(html, endsWith('</code></pre>'));
      // Should contain styled spans for keywords, functions, etc.
      expect(html, contains('<span style="color: rgba('));
      expect(html, contains('--dd-dark-color: rgba('));
    });

    test('returns plain code for unsupported language', () {
      final html = highlighter.highlightCodeBlock('some code', 'brainfuck');

      expect(
        html,
        equals(
          '<pre class="opal"><code class="language-brainfuck">'
          'some code'
          '</code></pre>',
        ),
      );
    });

    test('escapes HTML entities in code', () {
      final html = highlighter.highlightCodeBlock(
        'List<String> x = [];',
        'dart',
      );

      expect(html, contains('&lt;'));
      expect(html, contains('&gt;'));
      // Raw < > should not appear outside of HTML tags
      final codeContent = html
          .replaceAll(RegExp(r'<[^>]+>'), '') // strip HTML tags
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>');
      expect(codeContent, contains('List<String>'));
    });

    test('preserves multiline code', () {
      final html = highlighter.highlightCodeBlock(
        'int a = 1;\nint b = 2;',
        'dart',
      );

      expect(html, contains('\n'));
    });

    test('handles empty code', () {
      final html = highlighter.highlightCodeBlock('', 'dart');

      expect(html, startsWith('<pre class="opal"><code'));
      expect(html, endsWith('</code></pre>'));
    });
  });

  group('highlightHtml', () {
    test('finds and highlights code blocks in HTML', () {
      final input =
          '<p>Hello</p>'
          '<pre><code class="language-dart">void main() {}</code></pre>'
          '<p>World</p>';
      final output = highlighter.highlightHtml(input);

      expect(output, contains('<pre class="opal">'));
      expect(output, contains('<span style="color: rgba('));
      // Non-code HTML preserved
      expect(output, contains('<p>Hello</p>'));
      expect(output, contains('<p>World</p>'));
    });

    test('passes through HTML without code blocks unchanged', () {
      const input = '<p>No code here</p>';
      final output = highlighter.highlightHtml(input);

      expect(output, equals(input));
    });

    test('unescapes HTML entities before highlighting', () {
      final input =
          '<pre><code class="language-dart">'
          'var x = &quot;hello&quot;;'
          '</code></pre>';
      final output = highlighter.highlightHtml(input);

      // The highlighter should unescape then re-escape properly
      expect(output, contains('&quot;'));
      expect(output, contains('<pre class="opal">'));
    });

    test('highlights multiple code blocks', () {
      final input =
          '<pre><code class="language-dart">int a = 1;</code></pre>'
          '<p>text</p>'
          '<pre><code class="language-dart">int b = 2;</code></pre>';
      final output = highlighter.highlightHtml(input);

      expect(
        RegExp(r'<pre class="opal">').allMatches(output).length,
        equals(2),
      );
    });
  });
}
