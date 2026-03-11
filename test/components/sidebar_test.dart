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
      final DocLink(:name, :path, :order) = DocLink(
        name: 'Intro',
        path: '/docs/intro',
      );
      expect(name, equals('Intro'));
      expect(path, equals('/docs/intro'));
      expect(order, equals(0));
    });

    test('DocLink with custom order', () {
      const link = DocLink(name: 'Setup', path: '/docs/setup', order: 5);
      expect(link.order, equals(5));
    });

    test('DocCategory stores children and expanded state', () {
      final DocCategory(:name, :children, :expanded) = DocCategory(
        name: 'Guides',
        children: const [
          DocLink(name: 'Quick Start', path: '/docs/quick-start'),
          DocLink(name: 'Advanced', path: '/docs/advanced'),
        ],
        expanded: true,
      );
      expect(name, equals('Guides'));
      expect(children, hasLength(2));
      expect(expanded, isTrue);
    });

    test('DocCategory defaults to collapsed', () {
      final category = DocCategory(name: 'API', children: []);
      expect(category.expanded, isFalse);
    });

    test('nested DocCategory', () {
      final nested = DocCategory(
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
      final Doc item = DocLink(name: 'Test', path: '/test');
      final result = switch (item) {
        DocLink(:final path) => 'link:$path',
        DocCategory(:final children) => 'cat:${children.length}',
      };
      expect(result, equals('link:/test'));
    });
  });
}
