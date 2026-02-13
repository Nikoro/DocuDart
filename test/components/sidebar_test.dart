import 'package:docudart/src/models/doc.dart';
import 'package:test/test.dart';

// DefaultSidebar._slugify is private, so we replicate it here for testing.
// This ensures the slugification logic is correct.
String slugify(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

void main() {
  group('Sidebar slugify logic', () {
    test('converts to lowercase', () {
      expect(slugify('Getting Started'), equals('getting-started'));
    });

    test('replaces spaces with hyphens', () {
      expect(slugify('my category'), equals('my-category'));
    });

    test('strips non-alphanumeric characters', () {
      expect(slugify('C++ & Rust!'), equals('c-rust'));
    });

    test('strips leading and trailing hyphens', () {
      expect(slugify('--hello--'), equals('hello'));
    });

    test('collapses multiple separators', () {
      expect(slugify('a   b   c'), equals('a-b-c'));
    });

    test('handles pure numbers', () {
      expect(slugify('123'), equals('123'));
    });

    test('handles special characters only', () {
      expect(slugify('!@#\$%'), equals(''));
    });

    test('preserves already slugified text', () {
      expect(slugify('already-slugified'), equals('already-slugified'));
    });
  });

  group('Doc model', () {
    test('DocLink stores name and path', () {
      const link = DocLink(name: 'Intro', path: '/docs/intro');
      expect(link.name, equals('Intro'));
      expect(link.path, equals('/docs/intro'));
      expect(link.order, equals(0));
    });

    test('DocLink with custom order', () {
      const link = DocLink(name: 'Setup', path: '/docs/setup', order: 5);
      expect(link.order, equals(5));
    });

    test('DocCategory stores children and expanded state', () {
      const category = DocCategory(
        name: 'Guides',
        children: [
          DocLink(name: 'Quick Start', path: '/docs/quick-start'),
          DocLink(name: 'Advanced', path: '/docs/advanced'),
        ],
        expanded: true,
      );
      expect(category.name, equals('Guides'));
      expect(category.children, hasLength(2));
      expect(category.expanded, isTrue);
    });

    test('DocCategory defaults to collapsed', () {
      const category = DocCategory(name: 'API', children: []);
      expect(category.expanded, isFalse);
    });

    test('nested DocCategory', () {
      const nested = DocCategory(
        name: 'Top',
        children: [
          DocCategory(
            name: 'Sub',
            children: [DocLink(name: 'Leaf', path: '/docs/leaf')],
          ),
        ],
      );
      final sub = nested.children.first as DocCategory;
      expect(sub.name, equals('Sub'));
      expect(sub.children.first, isA<DocLink>());
    });

    test('Doc sealed class pattern matching', () {
      const Doc item = DocLink(name: 'Test', path: '/test');
      final result = switch (item) {
        DocLink(:final path) => 'link:$path',
        DocCategory(:final children) => 'cat:${children.length}',
      };
      expect(result, equals('link:/test'));
    });
  });
}
