import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:docudart/src/cli/errors.dart';
import 'package:docudart/src/config/config_loader.dart';
import 'package:docudart/src/models/license.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('config_loader_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('load', () {
    test('loads from YAML fallback when no config.dart exists', () async {
      // Create a minimal pubspec.yaml
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_project
description: A test project
environment:
  sdk: ^3.10.0
''');

      final config = await ConfigLoader.load(tempDir.path);

      expect(config.title, equals('test_project'));
      expect(config.description, equals('A test project'));
    });

    test('absolutizes directory paths', () async {
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_project
environment:
  sdk: any
''');

      final config = await ConfigLoader.load(tempDir.path);

      expect(p.isAbsolute(config.docsDir), isTrue);
      expect(p.isAbsolute(config.outputDir), isTrue);
      expect(p.isAbsolute(config.assetsDir), isTrue);
    });

    test('rejects path traversal in directory config', () async {
      // Create docudart.yaml with path traversal
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_project
environment:
  sdk: any
''');
      File(p.join(tempDir.path, 'docudart.yaml')).writeAsStringSync('''
docsDir: ../../etc
''');

      expect(
        () => ConfigLoader.load(tempDir.path),
        throwsA(isA<DocuDartException>()),
      );
    });
  });

  group('loadParentPubspec', () {
    test('loads pubspec from parent directory', () async {
      final websiteDir = Directory(p.join(tempDir.path, 'docudart'))
        ..createSync();

      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: my_package
version: 1.2.3
description: My package description
homepage: https://example.com
repository: https://github.com/user/repo
environment:
  sdk: ^3.10.0
topics:
  - documentation
  - dart
''');

      final pubspec = await ConfigLoader.loadParentPubspec(websiteDir.path);

      expect(pubspec.name, equals('my_package'));
      expect(pubspec.version, equals('1.2.3'));
      expect(pubspec.description, equals('My package description'));
      expect(pubspec.homepage, equals('https://example.com'));
      expect(pubspec.repository?.link, equals('https://github.com/user/repo'));
      expect(pubspec.topics, equals(['documentation', 'dart']));
    });

    test('falls back to website pubspec when parent missing', () async {
      final websiteDir = Directory(p.join(tempDir.path, 'docudart'))
        ..createSync();

      File(p.join(websiteDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: website_package
environment:
  sdk: any
''');

      final pubspec = await ConfigLoader.loadParentPubspec(websiteDir.path);
      expect(pubspec.name, equals('website_package'));
    });

    test('returns fallback when no pubspec exists', () async {
      final websiteDir = Directory(p.join(tempDir.path, 'docudart'))
        ..createSync();

      final pubspec = await ConfigLoader.loadParentPubspec(websiteDir.path);
      expect(pubspec.name, equals('unknown'));
    });
  });

  group('loadParentChangelog', () {
    test('loads changelog from parent directory', () async {
      final websiteDir = Directory(p.join(tempDir.path, 'docudart'))
        ..createSync();

      File(
        p.join(tempDir.path, 'CHANGELOG.md'),
      ).writeAsStringSync('# Changelog\n\n## 1.0.0\n- Initial release');

      final changelog = await ConfigLoader.loadParentChangelog(websiteDir.path);
      expect(changelog, contains('Initial release'));
    });

    test('returns null when no changelog exists', () async {
      final websiteDir = Directory(p.join(tempDir.path, 'docudart'))
        ..createSync();

      final changelog = await ConfigLoader.loadParentChangelog(websiteDir.path);
      expect(changelog, isNull);
    });
  });

  group('loadParentLicense', () {
    test('loads LICENSE from parent directory', () async {
      final websiteDir = Directory(p.join(tempDir.path, 'docudart'))
        ..createSync();

      File(
        p.join(tempDir.path, 'LICENSE'),
      ).writeAsStringSync('MIT License\n\nCopyright (c) 2026 Test Author');

      final license = await ConfigLoader.loadParentLicense(websiteDir.path);
      expect(license, isNotNull);
      expect(license!.type, equals(LicenseType.mit));
    });

    test('returns null when no license file exists', () async {
      final websiteDir = Directory(p.join(tempDir.path, 'docudart'))
        ..createSync();

      final license = await ConfigLoader.loadParentLicense(websiteDir.path);
      expect(license, isNull);
    });

    test('finds LICENSE.md variant', () async {
      final websiteDir = Directory(p.join(tempDir.path, 'docudart'))
        ..createSync();

      File(
        p.join(tempDir.path, 'LICENSE.md'),
      ).writeAsStringSync('MIT License\n\nCopyright (c) 2026 Test');

      final license = await ConfigLoader.loadParentLicense(websiteDir.path);
      expect(license, isNotNull);
    });
  });
}
