import 'package:test/test.dart';
import 'package:docudart/src/extensions/object_extensions.dart';

T? nullable<T>(T value) => value;

void main() {
  group('OptionalAnyObjectExtensions (.let)', () {
    test('returns null when receiver is null', () {
      const String? value = null;
      final result = value.let((it) => it.length);

      expect(result, isNull);
    });

    test('applies block when receiver is non-null', () {
      final result = nullable('hello').let((it) => it.length);

      expect(result, equals(5));
    });

    test('transforms non-null value to different type', () {
      final result = nullable(42).let((it) => 'Number: $it');

      expect(result, equals('Number: 42'));
    });

    test('block can return null from non-null input', () {
      final result = nullable('hello').let((it) => it.isEmpty ? it : null);

      expect(result, isNull);
    });

    test('works with custom objects', () {
      final result = nullable([1, 2, 3]).let((it) => it.length);

      expect(result, equals(3));
    });

    test('chains correctly with null propagation', () {
      const String? value = null;
      final result = value.let((it) => it.toUpperCase()).let((it) => '$it!');

      expect(result, isNull);
    });

    test('chains correctly with non-null value', () {
      final result = nullable(
        'hello',
      ).let((it) => it.toUpperCase()).let((it) => '$it!');

      expect(result, equals('HELLO!'));
    });
  });
}
