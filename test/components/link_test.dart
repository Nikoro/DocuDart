import 'package:docudart/src/components/navigation/link.dart';
import 'package:jaspr/dom.dart' show span;
import 'package:test/test.dart';

void main() {
  group('Link', () {
    group('Link.path', () {
      test('isExternal is false', () {
        final link = Link.path('/docs', label: 'Docs');
        expect(link.isExternal, isFalse);
      });

      test('href returns the path', () {
        final link = Link.path('/docs/intro', label: 'Intro');
        expect(link.href, equals('/docs/intro'));
      });

      test('defaults classes to nav-link', () {
        final link = Link.path('/docs', label: 'Docs');
        expect(link.classes, equals('nav-link'));
      });

      test('accepts custom classes', () {
        final link = Link.path('/docs', label: 'Docs', classes: 'sidebar-link');
        expect(link.classes, equals('sidebar-link'));
      });
    });

    group('Link.url', () {
      test('isExternal is true', () {
        final link = Link.url('https://github.com', label: 'GitHub');
        expect(link.isExternal, isTrue);
      });

      test('href returns the url', () {
        final link = Link.url('https://github.com', label: 'GitHub');
        expect(link.href, equals('https://github.com'));
      });
    });

    group('fromJson', () {
      test('parses path link', () {
        final link = Link.fromJson({'label': 'Docs', 'path': '/docs'});
        expect(link.label, equals('Docs'));
        expect(link.href, equals('/docs'));
        expect(link.isExternal, isFalse);
      });

      test('parses url link', () {
        final link = Link.fromJson({
          'label': 'GitHub',
          'url': 'https://github.com',
        });
        expect(link.label, equals('GitHub'));
        expect(link.href, equals('https://github.com'));
        expect(link.isExternal, isTrue);
      });

      test('supports legacy title key', () {
        final link = Link.fromJson({'title': 'Old Label', 'path': '/docs'});
        expect(link.label, equals('Old Label'));
      });

      test('prefers label over title', () {
        final link = Link.fromJson({
          'label': 'New',
          'title': 'Old',
          'path': '/docs',
        });
        expect(link.label, equals('New'));
      });
    });

    group('toJson', () {
      test('serializes path link', () {
        final link = Link.path('/docs', label: 'Docs');
        final json = link.toJson();
        expect(json, equals({'label': 'Docs', 'path': '/docs'}));
      });

      test('serializes url link', () {
        final link = Link.url('https://github.com', label: 'GitHub');
        final json = link.toJson();
        expect(json, equals({'label': 'GitHub', 'url': 'https://github.com'}));
      });

      test('omits null label', () {
        // Link.fromJson requires at least label/title, so we use Link.path
        // with a leading icon to create a label-less link.
        final link = Link.path('/docs', leading: span([]));
        final json = link.toJson();
        expect(json.containsKey('label'), isFalse);
        expect(json['path'], equals('/docs'));
      });

      test('roundtrips through fromJson/toJson', () {
        final original = Link.path('/docs/intro', label: 'Introduction');
        final json = original.toJson();
        final restored = Link.fromJson(json);
        expect(restored.label, equals(original.label));
        expect(restored.href, equals(original.href));
        expect(restored.isExternal, equals(original.isExternal));
      });
    });
  });
}
