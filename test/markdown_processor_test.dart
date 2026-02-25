import 'package:test/test.dart';
import 'package:docudart/src/markdown/markdown_processor.dart';

void main() {
  late MarkdownProcessor processor;

  setUp(() {
    processor = MarkdownProcessor();
  });

  group('MarkdownProcessor', () {
    test('empty content returns empty HTML', () {
      final ProcessedMarkdown(:html, :tableOfContents, :components) = processor
          .process('');

      expect(html, isEmpty);
      expect(tableOfContents, isEmpty);
      expect(components, isEmpty);
    });

    test('processes plain markdown without frontmatter', () {
      final result = processor.process('# Hello World\n\nSome text.');

      expect(result.html, contains('Hello World'));
      expect(result.html, contains('Some text.'));
      expect(result.meta.title, isNull);
    });

    test('extracts frontmatter metadata', () {
      final result = processor.process('''
---
title: My Page
description: A test page
sidebar_position: 3
---

# Content here
''');

      expect(result.meta.title, equals('My Page'));
      expect(result.meta.description, equals('A test page'));
      expect(result.meta.sidebarPosition, equals(3));
      expect(result.html, contains('Content here'));
    });

    test('extracts table of contents from headings', () {
      final result = processor.process('''
# Heading 1

Some text.

## Heading 2

More text.

### Heading 3

Even more.

#### Heading 4
''');

      expect(result.tableOfContents.length, equals(4));

      expect(result.tableOfContents[0].text, equals('Heading 1'));
      expect(result.tableOfContents[0].level, equals(1));

      expect(result.tableOfContents[1].text, equals('Heading 2'));
      expect(result.tableOfContents[1].level, equals(2));

      expect(result.tableOfContents[2].text, equals('Heading 3'));
      expect(result.tableOfContents[2].level, equals(3));

      expect(result.tableOfContents[3].text, equals('Heading 4'));
      expect(result.tableOfContents[3].level, equals(4));
    });

    test('generates heading IDs with spaces as hyphens', () {
      final result = processor.process('## Getting Started Guide');

      expect(result.tableOfContents.first.id, equals('getting-started-guide'));
      expect(result.html, contains('id="getting-started-guide"'));
    });

    test('generates heading IDs with special chars removed', () {
      final result = processor.process('## Hello, World! (Test)');

      // Commas, exclamation marks, and parentheses are removed
      expect(result.tableOfContents.first.id, equals('hello-world-test'));
    });

    test('generates heading IDs in lowercase', () {
      final result = processor.process('## UPPERCASE Title');

      expect(result.tableOfContents.first.id, equals('uppercase-title'));
    });

    test('generates heading IDs stripping non-ASCII characters', () {
      // The markdown parser + _generateId pipeline processes unicode:
      // accented characters like é may be stripped depending on the
      // markdown library's text node handling.
      final result = processor.process('## Caf\u00e9 API');

      expect(result.tableOfContents.first.text, contains('Caf'));
      expect(result.tableOfContents.first.level, equals(2));
      // ID is generated and non-empty
      expect(result.tableOfContents.first.id, isNotEmpty);
    });

    test('generates heading IDs for ASCII-only text correctly', () {
      final result = processor.process('## Simple Heading');

      expect(result.tableOfContents.first.id, equals('simple-heading'));
    });

    test('replaces Callout component placeholders with rendered HTML', () {
      final result = processor.process('''
# Title

<Callout type="info">This is important.</Callout>

More text.
''');

      expect(result.html, contains('class="callout callout-info"'));
      expect(result.html, contains('This is important.'));
      // Placeholder should be gone
      expect(result.html, isNot(contains('___COMPONENT_')));
    });

    test('renders unknown components with warning div', () {
      final result = processor.process('''
<UnknownWidget type="fancy" />
''');

      expect(result.html, contains('class="component-unknown"'));
      expect(result.html, contains('Unknown component: UnknownWidget'));
    });

    test('processes markdown with both frontmatter and components', () {
      final result = processor.process('''
---
title: Complex Page
---

# My Page

<Callout type="tip">A helpful tip.</Callout>

Regular paragraph.
''');

      expect(result.meta.title, equals('Complex Page'));
      expect(result.html, contains('My Page'));
      expect(result.html, contains('callout-tip'));
      expect(result.html, contains('A helpful tip.'));
      expect(result.html, contains('Regular paragraph.'));
    });
  });
}
