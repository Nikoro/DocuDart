import 'package:test/test.dart';
import 'package:docudart/src/cli/errors.dart';

void main() {
  group('DocuDartException', () {
    test('toString includes message only when no hint or command', () {
      const exception = DocuDartException('Something went wrong.');
      final str = exception.toString();

      expect(str, contains('Error: Something went wrong.'));
      expect(str, isNot(contains('Hint:')));
      expect(str, isNot(contains('Try:')));
    });

    test('toString includes hint when provided', () {
      const exception = DocuDartException(
        'Config missing.',
        hint: 'Run docudart create first.',
      );
      final str = exception.toString();

      expect(str, contains('Error: Config missing.'));
      expect(str, contains('Hint: Run docudart create first.'));
      expect(str, isNot(contains('Try:')));
    });

    test('toString includes command when provided', () {
      const exception = DocuDartException(
        'Not found.',
        command: 'docudart create',
      );
      final str = exception.toString();

      expect(str, contains('Error: Not found.'));
      expect(str, contains('Try: docudart create'));
      expect(str, isNot(contains('Hint:')));
    });

    test('toString includes all fields when fully populated', () {
      const exception = DocuDartException(
        'Project not found.',
        hint: 'Make sure you are in the right directory.',
        command: 'docudart create',
      );
      final str = exception.toString();

      expect(str, contains('Error: Project not found.'));
      expect(str, contains('Hint: Make sure you are in the right directory.'));
      expect(str, contains('Try: docudart create'));
    });
  });

  group('DocuDartErrors', () {
    test('configNotFound creates exception with hint and command', () {
      final e = DocuDartErrors.configNotFound();

      expect(e.message, equals('DocuDart project not found.'));
      expect(e.hint, isNotNull);
      expect(e.hint, contains('docudart/ directory'));
      expect(e.command, equals('docudart create'));
    });

    test('docsNotFound includes directory path', () {
      final e = DocuDartErrors.docsNotFound('/path/to/docs');

      expect(e.message, contains('/path/to/docs'));
      expect(e.hint, isNotNull);
    });

    test('noDocsFound includes directory path', () {
      final e = DocuDartErrors.noDocsFound('/path/to/docs');

      expect(e.message, contains('/path/to/docs'));
      expect(e.hint, contains('.md files'));
    });

    test('versionNotFound includes version and path', () {
      final e = DocuDartErrors.versionNotFound('2.0', '/versions/2.0');

      expect(e.message, contains('2.0'));
      expect(e.message, contains('/versions/2.0'));
    });

    test('buildFailed uses error text as hint', () {
      final e = DocuDartErrors.buildFailed('compilation error');

      expect(e.message, equals('Build failed.'));
      expect(e.hint, equals('compilation error'));
    });

    test('buildFailed uses fallback hint when error is empty', () {
      final e = DocuDartErrors.buildFailed('');

      expect(e.hint, contains('Check the output'));
    });

    test('portInUse suggests next port', () {
      final e = DocuDartErrors.portInUse(8080);

      expect(e.message, contains('8080'));
      expect(e.command, contains('8081'));
    });

    test('fileReadError includes path and error', () {
      final e = DocuDartErrors.fileReadError('/file.dart', 'Permission denied');

      expect(e.message, contains('/file.dart'));
      expect(e.hint, equals('Permission denied'));
    });

    test('invalidFrontmatter includes path', () {
      final e = DocuDartErrors.invalidFrontmatter(
        '/docs/intro.md',
        'bad yaml',
      );

      expect(e.message, contains('/docs/intro.md'));
      expect(e.hint, equals('bad yaml'));
    });
  });
}
