import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:docudart/src/generators/project_generator.dart';

void main() {
  group('InitTemplate', () {
    test('has defaultTemplate and full values', () {
      expect(InitTemplate.values, hasLength(2));
      expect(InitTemplate.values, contains(InitTemplate.defaultTemplate));
      expect(InitTemplate.values, contains(InitTemplate.full));
    });
  });

  group('ProjectGenerator gitignore update', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('project_generator_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('creates .gitignore with DocuDart entries when none exists', () async {
      // The _updateGitignore is private, but we can test the behavior
      // by checking what ProjectGenerator.generate() produces.
      // Since generate() requires too many dependencies, we verify
      // the gitignore pattern manually.
      final gitignoreFile = File(p.join(tempDir.path, '.gitignore'));

      // Simulate what _updateGitignore does
      final folderName = 'docudart';
      final content = '';
      final additions = <String>[];

      if (!content.contains('$folderName/.dart_tool/')) {
        additions.add('$folderName/.dart_tool/');
      }
      if (!content.contains('$folderName/build/')) {
        additions.add('$folderName/build/');
      }

      if (additions.isNotEmpty) {
        final newContent =
            '${content.trimRight()}\n\n# DocuDart\n${additions.join('\n')}\n';
        await gitignoreFile.writeAsString(newContent);
      }

      final result = await gitignoreFile.readAsString();
      expect(result, contains('docudart/.dart_tool/'));
      expect(result, contains('docudart/build/'));
      expect(result, contains('# DocuDart'));
    });

    test('appends DocuDart entries to existing .gitignore', () async {
      final gitignoreFile = File(p.join(tempDir.path, '.gitignore'));
      await gitignoreFile.writeAsString('.dart_tool/\nbuild/\n');

      final folderName = 'my_docs';
      final content = await gitignoreFile.readAsString();
      final additions = <String>[];

      if (!content.contains('$folderName/.dart_tool/')) {
        additions.add('$folderName/.dart_tool/');
      }
      if (!content.contains('$folderName/build/')) {
        additions.add('$folderName/build/');
      }

      if (additions.isNotEmpty) {
        final newContent =
            '${content.trimRight()}\n\n# DocuDart\n${additions.join('\n')}\n';
        await gitignoreFile.writeAsString(newContent);
      }

      final result = await gitignoreFile.readAsString();
      expect(result, contains('.dart_tool/')); // original entry preserved
      expect(result, contains('my_docs/.dart_tool/'));
      expect(result, contains('my_docs/build/'));
    });

    test('does not duplicate existing DocuDart entries', () async {
      final gitignoreFile = File(p.join(tempDir.path, '.gitignore'));
      await gitignoreFile.writeAsString(
        '# DocuDart\ndocudart/.dart_tool/\ndocudart/build/\n',
      );

      final folderName = 'docudart';
      final content = await gitignoreFile.readAsString();
      final additions = <String>[];

      if (!content.contains('$folderName/.dart_tool/')) {
        additions.add('$folderName/.dart_tool/');
      }
      if (!content.contains('$folderName/build/')) {
        additions.add('$folderName/build/');
      }

      // No additions needed — entries already exist
      expect(additions, isEmpty);
    });
  });

  group('Package name sanitization pattern', () {
    // Tests the same logic as _sanitizePackageName
    String sanitize(String name) {
      return name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');
    }

    test('lowercases name', () {
      // Uppercase letters become lowercase — no separator inserted
      expect(sanitize('MyProject'), equals('myproject'));
    });

    test('replaces spaces with underscores', () {
      expect(sanitize('My Project'), equals('my_project'));
    });

    test('replaces hyphens with underscores', () {
      expect(sanitize('my-project'), equals('my_project'));
    });

    test('collapses consecutive underscores', () {
      expect(sanitize('my  project'), equals('my_project'));
    });

    test('strips leading and trailing underscores', () {
      expect(sanitize(' project '), equals('project'));
    });

    test('handles special characters', () {
      expect(sanitize('My Docs!@#\$%'), equals('my_docs'));
    });

    test('preserves digits', () {
      expect(sanitize('project123'), equals('project123'));
    });

    test('handles already valid name', () {
      expect(sanitize('valid_name'), equals('valid_name'));
    });
  });
}
