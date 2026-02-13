import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:docudart/src/generators/asset_path_generator.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('asset_path_gen_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AssetPathGenerator.generateProjectAssets', () {
    test('non-existent directory returns empty _ProjectAssets class', () {
      final result = AssetPathGenerator.generateProjectAssets(
        p.join(tempDir.path, 'nonexistent'),
      );

      expect(result, contains('class _ProjectAssets'));
      expect(result, isNot(contains('SimpleAsset')));
      expect(result, isNot(contains('ThemedAsset')));
    });

    test('empty directory returns empty _ProjectAssets class', () {
      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains('class _ProjectAssets'));
      expect(result, isNot(contains('SimpleAsset')));
    });

    test('root-only file generates SimpleAsset', () {
      File(p.join(tempDir.path, 'banner.png')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains('SimpleAsset'));
      expect(result, contains("'/assets/banner.png'"));
      expect(result, contains('banner_png'));
    });

    test('subdirectory generates nested class with SimpleAsset', () {
      final logoDir = Directory(p.join(tempDir.path, 'logo'));
      logoDir.createSync();
      File(p.join(logoDir.path, 'logo.webp')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains('_ProjectAssetsLogo'));
      expect(result, contains('logo_webp'));
      expect(result, contains("SimpleAsset('/assets/logo/logo.webp')"));
    });

    test('light/ + dark/ variants generate ThemedAsset', () {
      // Create light and dark variants.
      final lightLogo = Directory(p.join(tempDir.path, 'light', 'logo'));
      final darkLogo = Directory(p.join(tempDir.path, 'dark', 'logo'));
      lightLogo.createSync(recursive: true);
      darkLogo.createSync(recursive: true);
      File(p.join(lightLogo.path, 'logo.webp')).writeAsStringSync('');
      File(p.join(darkLogo.path, 'logo.webp')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains('ThemedAsset'));
      expect(result, contains("light: '/assets/light/logo/logo.webp'"));
      expect(result, contains("dark: '/assets/dark/logo/logo.webp'"));
      // light/ and dark/ should not appear as subdirectories in the tree.
      expect(result, isNot(contains('_ProjectAssetsLight')));
      expect(result, isNot(contains('_ProjectAssetsDark')));
    });

    test(
      'root + light/ (no dark/) generates ThemedAsset with root as dark fallback',
      () {
        // Root version.
        final logoDir = Directory(p.join(tempDir.path, 'logo'));
        logoDir.createSync();
        File(p.join(logoDir.path, 'logo.webp')).writeAsStringSync('');
        // Light version.
        final lightLogo = Directory(p.join(tempDir.path, 'light', 'logo'));
        lightLogo.createSync(recursive: true);
        File(p.join(lightLogo.path, 'logo.webp')).writeAsStringSync('');

        final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

        expect(result, contains('ThemedAsset'));
        expect(result, contains("light: '/assets/light/logo/logo.webp'"));
        expect(result, contains("dark: '/assets/logo/logo.webp'"));
      },
    );

    test(
      'root + dark/ (no light/) generates ThemedAsset with root as light fallback',
      () {
        // Root version.
        final logoDir = Directory(p.join(tempDir.path, 'logo'));
        logoDir.createSync();
        File(p.join(logoDir.path, 'logo.webp')).writeAsStringSync('');
        // Dark version.
        final darkLogo = Directory(p.join(tempDir.path, 'dark', 'logo'));
        darkLogo.createSync(recursive: true);
        File(p.join(darkLogo.path, 'logo.webp')).writeAsStringSync('');

        final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

        expect(result, contains('ThemedAsset'));
        expect(result, contains("light: '/assets/logo/logo.webp'"));
        expect(result, contains("dark: '/assets/dark/logo/logo.webp'"));
      },
    );

    test('light-only file generates SimpleAsset with light path', () {
      final lightDir = Directory(p.join(tempDir.path, 'light'));
      lightDir.createSync();
      File(p.join(lightDir.path, 'icon.svg')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains("SimpleAsset('/assets/light/icon.svg')"));
    });

    test('dark-only file generates SimpleAsset with dark path', () {
      final darkDir = Directory(p.join(tempDir.path, 'dark'));
      darkDir.createSync();
      File(p.join(darkDir.path, 'icon.svg')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains("SimpleAsset('/assets/dark/icon.svg')"));
    });

    test('light/ and dark/ are excluded from the tree namespace', () {
      final lightDir = Directory(p.join(tempDir.path, 'light'));
      lightDir.createSync();
      File(p.join(lightDir.path, 'banner.png')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      // The asset should appear at root level, not under a "light" subdirectory.
      expect(result, isNot(contains('_ProjectAssetsLight')));
      expect(result, contains('banner_png'));
    });

    test('hidden files are skipped', () {
      File(p.join(tempDir.path, '.gitkeep')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, isNot(contains('gitkeep')));
    });

    test('assets.dart is skipped', () {
      File(p.join(tempDir.path, 'assets.dart')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, isNot(contains('assets_dart')));
    });

    test('empty subdirectories are skipped', () {
      Directory(p.join(tempDir.path, 'empty_dir')).createSync();
      File(p.join(tempDir.path, 'logo.webp')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, isNot(contains('empty_dir')));
      expect(result, contains('logo_webp'));
    });

    test('filenames with hyphens and dots become valid identifiers', () {
      File(p.join(tempDir.path, 'favicon-32x32.png')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains('favicon_32x32_png'));
    });

    test('filenames starting with digits get \$ prefix', () {
      File(p.join(tempDir.path, '1icon.svg')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains(r'$1icon_svg'));
    });

    test('nested theme directories merge correctly', () {
      // light/images/icons/arrow.svg + dark/images/icons/arrow.svg
      final lightIcons = Directory(
        p.join(tempDir.path, 'light', 'images', 'icons'),
      );
      final darkIcons = Directory(
        p.join(tempDir.path, 'dark', 'images', 'icons'),
      );
      lightIcons.createSync(recursive: true);
      darkIcons.createSync(recursive: true);
      File(p.join(lightIcons.path, 'arrow.svg')).writeAsStringSync('');
      File(p.join(darkIcons.path, 'arrow.svg')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains('ThemedAsset'));
      expect(result, contains("'/assets/light/images/icons/arrow.svg'"));
      expect(result, contains("'/assets/dark/images/icons/arrow.svg'"));
      expect(result, contains('_ProjectAssetsImages'));
      expect(result, contains('_ProjectAssetsImagesIcons'));
    });

    test('mixed root and themed assets coexist', () {
      // Root-only: images/banner.png
      final imagesDir = Directory(p.join(tempDir.path, 'images'));
      imagesDir.createSync();
      File(p.join(imagesDir.path, 'banner.png')).writeAsStringSync('');

      // Themed: logo/logo.webp (light + dark)
      final lightLogo = Directory(p.join(tempDir.path, 'light', 'logo'));
      final darkLogo = Directory(p.join(tempDir.path, 'dark', 'logo'));
      lightLogo.createSync(recursive: true);
      darkLogo.createSync(recursive: true);
      File(p.join(lightLogo.path, 'logo.webp')).writeAsStringSync('');
      File(p.join(darkLogo.path, 'logo.webp')).writeAsStringSync('');

      final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

      expect(result, contains("SimpleAsset('/assets/images/banner.png')"));
      expect(result, contains('ThemedAsset'));
      expect(result, contains("light: '/assets/light/logo/logo.webp'"));
      expect(result, contains("dark: '/assets/dark/logo/logo.webp'"));
    });

    test(
      'light+dark+root all exist for same file uses light and dark (root ignored)',
      () {
        // All three exist.
        final logoDir = Directory(p.join(tempDir.path, 'logo'));
        logoDir.createSync();
        File(p.join(logoDir.path, 'logo.webp')).writeAsStringSync('');

        final lightLogo = Directory(p.join(tempDir.path, 'light', 'logo'));
        lightLogo.createSync(recursive: true);
        File(p.join(lightLogo.path, 'logo.webp')).writeAsStringSync('');

        final darkLogo = Directory(p.join(tempDir.path, 'dark', 'logo'));
        darkLogo.createSync(recursive: true);
        File(p.join(darkLogo.path, 'logo.webp')).writeAsStringSync('');

        final result = AssetPathGenerator.generateProjectAssets(tempDir.path);

        // light + dark both exist → uses those, root is ignored.
        expect(result, contains("light: '/assets/light/logo/logo.webp'"));
        expect(result, contains("dark: '/assets/dark/logo/logo.webp'"));
        // Should NOT reference root path.
        expect(result, isNot(contains("'/assets/logo/logo.webp'")));
      },
    );
  });
}
