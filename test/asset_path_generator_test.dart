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

  group('AssetPathGenerator', () {
    test('non-existent directory returns empty Assets class', () {
      final result = AssetPathGenerator.generate(
        p.join(tempDir.path, 'nonexistent'),
      );

      expect(result, contains('abstract class Assets'));
      expect(result, contains('Assets._()'));
      expect(result, contains('assets directory is empty'));
    });

    test('empty directory returns empty Assets class', () {
      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('abstract class Assets'));
      expect(result, contains('assets directory is empty'));
    });

    test('root-level files generate static const fields', () {
      File(p.join(tempDir.path, 'logo.webp')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('static const String logo_webp'));
      expect(result, contains("'/assets/logo.webp'"));
    });

    test('subdirectory generates nested private class', () {
      final logoDir = Directory(p.join(tempDir.path, 'logo'));
      logoDir.createSync();
      File(p.join(logoDir.path, 'logo.webp')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('static const logo = _AssetsLogo()'));
      expect(result, contains('class _AssetsLogo'));
      expect(result, contains('logo_webp'));
      expect(result, contains("'/assets/logo/logo.webp'"));
    });

    test('filenames with hyphens and dots become valid identifiers', () {
      File(p.join(tempDir.path, 'favicon-32x32.png')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('favicon_32x32_png'));
    });

    test('filenames starting with digits get \$ prefix', () {
      File(p.join(tempDir.path, '1icon.svg')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains(r'$1icon_svg'));
    });

    test('hidden files are skipped', () {
      File(p.join(tempDir.path, '.gitkeep')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('assets directory is empty'));
      expect(result, isNot(contains('gitkeep')));
    });

    test('assets.dart file itself is skipped', () {
      File(p.join(tempDir.path, 'assets.dart')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('assets directory is empty'));
    });

    test('.dart files other than assets.dart are included', () {
      File(p.join(tempDir.path, 'helpers.dart')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('helpers_dart'));
      expect(result, contains("'/assets/helpers.dart'"));
    });

    test('empty subdirectories are skipped', () {
      Directory(p.join(tempDir.path, 'empty_dir')).createSync();
      File(p.join(tempDir.path, 'logo.webp')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, isNot(contains('empty_dir')));
      expect(result, contains('logo_webp'));
    });

    test('multiple root-level files are generated', () {
      File(p.join(tempDir.path, 'logo.webp')).writeAsStringSync('');
      File(p.join(tempDir.path, 'banner.png')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('logo_webp'));
      expect(result, contains('banner_png'));
    });

    test('nested subdirectories generate nested classes', () {
      final iconsDir = Directory(p.join(tempDir.path, 'images', 'icons'));
      iconsDir.createSync(recursive: true);
      File(p.join(iconsDir.path, 'arrow.svg')).writeAsStringSync('');

      final result = AssetPathGenerator.generate(tempDir.path);

      expect(result, contains('_AssetsImages'));
      expect(result, contains('_AssetsImagesIcons'));
      expect(result, contains('arrow_svg'));
    });
  });
}
