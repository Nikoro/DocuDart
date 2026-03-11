import 'package:test/test.dart';
import 'package:docudart/src/cli/commands/update_command.dart';

void main() {
  group('UpdateCommand', () {
    test('has correct name', () {
      final command = UpdateCommand();
      expect(command.name, equals('update'));
    });

    test('has correct description', () {
      final command = UpdateCommand();
      expect(command.description, contains('Update'));
    });
  });

  group('isAlreadyUpToDate', () {
    final upToDateMessages = [
      'Package docudart is already activated at newest available version.',
      'Package docudart is already active at 1.0.0.',
      'already using docudart 1.0.0',
    ];

    final notUpToDateMessages = [
      'Activated docudart 1.1.0.',
      'Resolving dependencies...',
      'Some other output',
    ];

    for (final msg in upToDateMessages) {
      test('detects up-to-date: "$msg"', () {
        expect(UpdateCommand.isAlreadyUpToDate(msg), isTrue);
      });
    }

    for (final msg in notUpToDateMessages) {
      test('detects new update: "$msg"', () {
        expect(UpdateCommand.isAlreadyUpToDate(msg), isFalse);
      });
    }
  });
}
