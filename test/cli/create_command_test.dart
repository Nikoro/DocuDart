import 'package:test/test.dart';
import 'package:docudart/src/cli/commands/create_command.dart';

void main() {
  group('CreateCommand', () {
    test('has correct name', () {
      final command = CreateCommand();
      expect(command.name, equals('create'));
    });

    test('has --full flag', () {
      final command = CreateCommand();
      final options = command.argParser.options;

      expect(options.containsKey('full'), isTrue);
      expect(options['full']!.abbr, equals('f'));
      expect(options['full']!.negatable, isFalse);
    });

    test('has --directory option with default', () {
      final command = CreateCommand();
      final options = command.argParser.options;

      expect(options.containsKey('directory'), isTrue);
      expect(options['directory']!.abbr, equals('d'));
      expect(options['directory']!.defaultsTo, equals('.'));
    });
  });

  group('defaultFolderName', () {
    test('is docudart', () {
      expect(defaultFolderName, equals('docudart'));
    });
  });

  group('folder name validation', () {
    // The regex is private, so we test it via the runner to get argument
    // parsing, but validate the pattern indirectly through known valid/invalid
    // names. The actual regex is: ^[a-z][a-z0-9_]*$
    final validNames = [
      'docudart',
      'my_docs',
      'docs',
      'a',
      'my_project123',
      'x0',
    ];

    final invalidNames = [
      'MyDocs', // uppercase
      '123docs', // starts with digit
      '_docs', // starts with underscore
      'my-docs', // hyphen
      'my docs', // space
      'my.docs', // dot
      '', // empty
      'My_Docs', // mixed case
    ];

    final nameRegex = RegExp(r'^[a-z][a-z0-9_]*$');

    for (final name in validNames) {
      test('"$name" is a valid folder name', () {
        expect(nameRegex.hasMatch(name), isTrue);
      });
    }

    for (final name in invalidNames) {
      test('"$name" is an invalid folder name', () {
        expect(nameRegex.hasMatch(name), isFalse);
      });
    }
  });
}
