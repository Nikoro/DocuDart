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

  group('up-to-date detection patterns', () {
    // UpdateCommand checks these patterns in dart pub global activate output
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

    final patterns = [
      'already activated at newest available version',
      'is already active',
      'already using',
    ];

    for (final msg in upToDateMessages) {
      test('"${msg.substring(0, msg.length.clamp(0, 50))}..." detected as up-to-date', () {
        final isUpToDate = patterns.any(msg.contains);
        expect(isUpToDate, isTrue);
      });
    }

    for (final msg in notUpToDateMessages) {
      test('"$msg" detected as new update', () {
        final isUpToDate = patterns.any(msg.contains);
        expect(isUpToDate, isFalse);
      });
    }
  });
}
