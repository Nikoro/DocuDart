import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:docudart/src/services/workspace_resolver.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('workspace_resolver_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('WorkspaceResolver', () {
    test('returns null for empty directory', () {
      final result = WorkspaceResolver.resolve(tempDir.path);

      expect(result, isNull);
    });

    test('detects website dir when cwd has config.dart and pubspec.yaml', () {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('');
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('');

      final result = WorkspaceResolver.resolve(tempDir.path);

      expect(result, isNotNull);
      expect(result, equals(p.normalize(p.absolute(tempDir.path))));
    });

    test('detects docudart/ subdirectory from parent', () {
      final docudartDir = Directory(p.join(tempDir.path, 'docudart'));
      docudartDir.createSync();
      File(p.join(docudartDir.path, 'config.dart')).writeAsStringSync('');
      File(p.join(docudartDir.path, 'pubspec.yaml')).writeAsStringSync('');

      final result = WorkspaceResolver.resolve(tempDir.path);

      expect(result, isNotNull);
      expect(result, equals(p.normalize(p.absolute(docudartDir.path))));
    });

    test('legacy mode: detects config.dart without pubspec.yaml', () {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('');

      final result = WorkspaceResolver.resolve(tempDir.path);

      expect(result, isNotNull);
      expect(result, equals(p.normalize(p.absolute(tempDir.path))));
    });

    test('returns null when only pubspec.yaml exists', () {
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('');

      final result = WorkspaceResolver.resolve(tempDir.path);

      expect(result, isNull);
    });

    test(
      'prefers website dir (config.dart + pubspec.yaml) over docudart/ subdir',
      () {
        // cwd has both config.dart and pubspec.yaml
        File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('');
        File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('');

        // Also has docudart/ subdir
        final docudartDir = Directory(p.join(tempDir.path, 'docudart'));
        docudartDir.createSync();
        File(p.join(docudartDir.path, 'config.dart')).writeAsStringSync('');
        File(p.join(docudartDir.path, 'pubspec.yaml')).writeAsStringSync('');

        final result = WorkspaceResolver.resolve(tempDir.path);

        // Should resolve to cwd itself (first check wins)
        expect(result, equals(p.normalize(p.absolute(tempDir.path))));
      },
    );
  });
}
