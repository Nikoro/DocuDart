import 'package:docudart/src/models/asset.dart';
import 'package:test/test.dart';

void main() {
  group('AssetVariant', () {
    test('path returns the stored path', () {
      const variant = AssetVariant('/assets/logo.webp');
      expect(variant.path, equals('/assets/logo.webp'));
    });
  });

  group('SimpleAsset', () {
    test('path returns the single path', () {
      const asset = SimpleAsset('/assets/logo.webp');
      expect(asset.path, equals('/assets/logo.webp'));
    });

    test('light.path returns the same path', () {
      const asset = SimpleAsset('/assets/logo.webp');
      expect(asset.light.path, equals('/assets/logo.webp'));
    });

    test('dark.path returns the same path', () {
      const asset = SimpleAsset('/assets/logo.webp');
      expect(asset.dark.path, equals('/assets/logo.webp'));
    });
  });

  group('ThemedAsset', () {
    test('path returns the light path by default', () {
      final asset = ThemedAsset(
        light: '/assets/light/logo.webp',
        dark: '/assets/dark/logo.webp',
      );
      expect(asset.path, equals('/assets/light/logo.webp'));
    });

    test('light.path returns the light path', () {
      final asset = ThemedAsset(
        light: '/assets/light/logo.webp',
        dark: '/assets/dark/logo.webp',
      );
      expect(asset.light.path, equals('/assets/light/logo.webp'));
    });

    test('dark.path returns the dark path', () {
      final asset = ThemedAsset(
        light: '/assets/light/logo.webp',
        dark: '/assets/dark/logo.webp',
      );
      expect(asset.dark.path, equals('/assets/dark/logo.webp'));
    });
  });

  group('Asset sealed class', () {
    test('SimpleAsset is an Asset', () {
      const Asset asset = SimpleAsset('/assets/logo.webp');
      expect(asset, isA<SimpleAsset>());
    });

    test('ThemedAsset is an Asset', () {
      final Asset asset = ThemedAsset(
        light: '/assets/light/logo.webp',
        dark: '/assets/dark/logo.webp',
      );
      expect(asset, isA<ThemedAsset>());
    });

    test('pattern matching works on Asset', () {
      final Asset asset = ThemedAsset(
        light: '/assets/light/logo.webp',
        dark: '/assets/dark/logo.webp',
      );

      final result = switch (asset) {
        SimpleAsset() => 'simple',
        ThemedAsset() => 'themed',
      };
      expect(result, equals('themed'));
    });
  });
}
