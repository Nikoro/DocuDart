import 'package:test/test.dart';
import 'package:docudart/docudart.dart';

void main() {
  group('FrontmatterHandler', () {
    test('parses empty content', () {
      final result = FrontmatterHandler.parse('');

      expect(result.data, isEmpty);
      expect(result.content, equals(''));
    });

    test('parses content without frontmatter', () {
      final content = '# Hello\n\nThis is content.';
      final result = FrontmatterHandler.parse(content);

      expect(result.data, isEmpty);
      expect(result.content, equals(content));
    });

    test('parses basic frontmatter', () {
      final content = '''
---
title: My Title
description: My description
---

# Content
''';
      final result = FrontmatterHandler.parse(content);

      expect(result.data['title'], equals('My Title'));
      expect(result.data['description'], equals('My description'));
      expect(result.content.trim(), equals('# Content'));
    });

    test('parses frontmatter with sidebar_position', () {
      final content = '''
---
title: Getting Started
sidebar_position: 1
---

Content here.
''';
      final result = FrontmatterHandler.parse(content);

      expect(result.data['sidebar_position'], equals(1));
    });

    test('parses frontmatter with tags', () {
      final content = '''
---
title: Tutorial
tags: [beginner, tutorial]
---

Content.
''';
      final result = FrontmatterHandler.parse(content);

      expect(result.data['tags'], equals(['beginner', 'tutorial']));
    });

    test('parseWithMeta returns PageMeta object', () {
      final content = '''
---
title: My Page
sidebar_position: 2
sidebar_title: Short Title
description: SEO description
tags: [api, reference]
---

Content.
''';
      final (meta, markdown) = FrontmatterHandler.parseWithMeta(content);

      expect(meta.title, equals('My Page'));
      expect(meta.sidebarPosition, equals(2));
      expect(meta.sidebarTitle, equals('Short Title'));
      expect(meta.description, equals('SEO description'));
      expect(meta.tags, equals(['api', 'reference']));
      expect(meta.showInSidebar, isTrue);
      expect(markdown.trim(), equals('Content.'));
    });

    test('handles invalid YAML gracefully', () {
      final content = '''
---
title: [invalid yaml
---

Content.
''';
      final result = FrontmatterHandler.parse(content);

      // Should return original content on parse error
      expect(result.data, isEmpty);
    });
  });

  group('ComponentParser', () {
    test('parses empty content', () {
      final result = ComponentParser.parse('');

      expect(result.content, equals(''));
      expect(result.components, isEmpty);
    });

    test('parses content without components', () {
      final content = '# Hello\n\nRegular markdown content.';
      final result = ComponentParser.parse(content);

      expect(result.content, equals(content));
      expect(result.components, isEmpty);
    });

    test('parses self-closing component', () {
      final content = '''
# Title

<Callout type="info" />

More content.
''';
      final result = ComponentParser.parse(content);

      expect(result.components.length, equals(1));
      expect(result.components.first.name, equals('Callout'));
      expect(result.components.first.props['type'], equals('info'));
      expect(result.components.first.children, isNull);
    });

    test('parses component with children', () {
      final content = '''
<Callout type="warning">
This is a warning message.
</Callout>
''';
      final result = ComponentParser.parse(content);

      expect(result.components.length, equals(1));
      expect(result.components.first.name, equals('Callout'));
      expect(result.components.first.props['type'], equals('warning'));
      expect(result.components.first.children, contains('warning message'));
    });

    test('parses multiple components', () {
      final content = '''
<Callout type="info">Info here.</Callout>

Some text.

<Card title="Feature" />
''';
      final result = ComponentParser.parse(content);

      expect(result.components.length, equals(2));
      expect(result.components[0].name, equals('Callout'));
      expect(result.components[1].name, equals('Card'));
    });

    test('parses various prop types', () {
      final content = '<MyComponent str="hello" num={42} bool={true} />';
      final result = ComponentParser.parse(content);

      expect(result.components.first.props['str'], equals('hello'));
      expect(result.components.first.props['num'], equals(42));
      expect(result.components.first.props['bool'], equals(true));
    });

    test('isBuiltIn identifies built-in components', () {
      expect(ComponentParser.isBuiltIn('Callout'), isTrue);
      expect(ComponentParser.isBuiltIn('Tabs'), isTrue);
      expect(ComponentParser.isBuiltIn('Tab'), isTrue);
      expect(ComponentParser.isBuiltIn('CodeBlock'), isTrue);
      expect(ComponentParser.isBuiltIn('Card'), isTrue);
      expect(ComponentParser.isBuiltIn('CardGrid'), isTrue);
      expect(ComponentParser.isBuiltIn('CustomComponent'), isFalse);
    });

    test('replaces components with placeholders', () {
      final content = '<Callout type="info">Test</Callout>';
      final result = ComponentParser.parse(content);

      expect(result.content, contains('data-component='));
      expect(result.content, contains('___COMPONENT_0___'));
    });
  });

  group('PageMeta', () {
    test('creates with default values', () {
      const meta = PageMeta();

      expect(meta.title, isNull);
      expect(meta.showInSidebar, isTrue);
      expect(meta.tags, isEmpty);
    });

    test('fromMap parses all fields', () {
      final map = {
        'title': 'Test',
        'description': 'Desc',
        'sidebar_position': 5,
        'sidebar_title': 'Short',
        'sidebar': false,
        'tags': ['a', 'b'],
        'slug': '/custom-slug',
      };

      final meta = PageMeta.fromMap(map);

      expect(meta.title, equals('Test'));
      expect(meta.description, equals('Desc'));
      expect(meta.sidebarPosition, equals(5));
      expect(meta.sidebarTitle, equals('Short'));
      expect(meta.showInSidebar, isFalse);
      expect(meta.tags, equals(['a', 'b']));
      expect(meta.slug, equals('/custom-slug'));
    });

    test('toMap exports fields correctly', () {
      const meta = PageMeta(title: 'Test', sidebarPosition: 1, tags: ['tag1']);

      final map = meta.toMap();

      expect(map['title'], equals('Test'));
      expect(map['sidebar_position'], equals(1));
      expect(map['tags'], equals(['tag1']));
      expect(map.containsKey('description'), isFalse);
    });
  });
}
