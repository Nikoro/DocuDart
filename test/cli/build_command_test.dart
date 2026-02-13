import 'package:test/test.dart';
import 'package:docudart/src/cli/commands/build_command.dart';

void main() {
  group('BuildCommand', () {
    test('has correct name', () {
      final command = BuildCommand();
      expect(command.name, equals('build'));
    });

    test('has --output option', () {
      final command = BuildCommand();
      final options = command.argParser.options;

      expect(options.containsKey('output'), isTrue);
      expect(options['output']!.abbr, equals('o'));
    });
  });
}
