import 'package:test/test.dart';
import 'package:docudart/src/cli/cli_runner.dart';

void main() {
  late DocuDartCliRunner runner;

  setUp(() {
    runner = DocuDartCliRunner();
  });

  group('DocuDartCliRunner', () {
    test('has correct executable name', () {
      expect(runner.executableName, equals('docudart'));
    });

    test('has correct description', () {
      expect(runner.description, contains('documentation generator'));
    });

    test('registers all expected commands', () {
      final commandNames = runner.commands.keys.toSet();

      expect(commandNames, contains('create'));
      expect(commandNames, contains('build'));
      expect(commandNames, contains('serve'));
      expect(commandNames, contains('version'));
      expect(commandNames, contains('update'));
    });

    test('has --version flag', () {
      final options = runner.argParser.options;

      expect(options.containsKey('version'), isTrue);
      expect(options['version']!.abbr, equals('v'));
      expect(options['version']!.negatable, isFalse);
    });

    test('returns 64 for usage errors', () async {
      // Unknown command triggers UsageException
      final exitCode = await runner.run(['nonexistent-command']);

      expect(exitCode, equals(64));
    });
  });
}
