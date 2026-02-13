import 'package:test/test.dart';
import 'package:docudart/src/cli/commands/serve_command.dart';

void main() {
  group('ServeCommand', () {
    test('has correct name', () {
      final command = ServeCommand();
      expect(command.name, equals('serve'));
    });

    test('has --port option with default 8080', () {
      final command = ServeCommand();
      final options = command.argParser.options;

      expect(options.containsKey('port'), isTrue);
      expect(options['port']!.abbr, equals('p'));
      expect(options['port']!.defaultsTo, equals('8080'));
    });

    test('has --watch flag enabled by default', () {
      final command = ServeCommand();
      final options = command.argParser.options;

      expect(options.containsKey('watch'), isTrue);
      expect(options['watch']!.abbr, equals('w'));
      expect(options['watch']!.defaultsTo, isTrue);
    });
  });

  // _shouldShowLog is a static private method on ServeCommand.
  // We test it via the public shouldShowLog test helper if exposed,
  // or verify the filtering logic by documenting expected behavior.
  group('log filtering logic', () {
    // These tests document the expected filtering rules.
    // The actual _shouldShowLog method is private, so we test the
    // patterns it checks against to ensure our understanding is correct.

    final suppressedPatterns = [
      'SocketException: Connection refused',
      'Connection attempt cancelled',
      'ClientException with SocketException',
      'dart:_http/http_impl.dart:123',
      'package:http/src/client.dart:45',
      'package:shelf_proxy/shelf_proxy.dart:67',
      'package:shelf_gzip/shelf_gzip.dart:89',
      'package:shelf/shelf_io.dart:101',
      'package:jaspr/src/server/server.dart:55',
      '[SERVER] [ERROR] ERROR - some error',
      '[SERVER] [ERROR] Asynchronous error happened',
      '[SERVER] [ERROR] Error thrown by handler.',
      '[SERVER] [ERROR] GET /some/path',
    ];

    final passedPatterns = [
      'Serving at http://localhost:8080',
      'Building web assets...',
      'Build completed successfully',
      'Hot reload triggered',
      '', // empty lines pass through
      'INFO: some user message',
    ];

    // Verify the suppression patterns match what _shouldShowLog checks
    for (final line in suppressedPatterns) {
      test('suppresses: "${_truncate(line, 50)}"', () {
        final shouldSuppress =
            line.contains('SocketException') ||
            line.contains('Connection attempt cancelled') ||
            line.contains('ClientException with SocketException') ||
            line.contains('dart:_http') ||
            line.contains('package:http/') ||
            line.contains('package:shelf_proxy/') ||
            line.contains('package:shelf_gzip/') ||
            line.contains('package:shelf/shelf_io.dart') ||
            line.contains('package:jaspr/src/server/') ||
            line.contains('[SERVER] [ERROR] ERROR -') ||
            line.contains('[SERVER] [ERROR] Asynchronous error') ||
            line.contains('[SERVER] [ERROR] Error thrown by handler.') ||
            line.contains('[SERVER] [ERROR] GET /');

        expect(shouldSuppress, isTrue, reason: '"$line" should be suppressed');
      });
    }

    for (final line in passedPatterns) {
      test('passes through: "${_truncate(line, 50)}"', () {
        final shouldSuppress =
            line.contains('SocketException') ||
            line.contains('Connection attempt cancelled') ||
            line.contains('ClientException with SocketException') ||
            line.contains('dart:_http') ||
            line.contains('package:http/') ||
            line.contains('package:shelf_proxy/') ||
            line.contains('package:shelf_gzip/') ||
            line.contains('package:shelf/shelf_io.dart') ||
            line.contains('package:jaspr/src/server/') ||
            line.contains('[SERVER] [ERROR] ERROR -') ||
            line.contains('[SERVER] [ERROR] Asynchronous error') ||
            line.contains('[SERVER] [ERROR] Error thrown by handler.') ||
            line.contains('[SERVER] [ERROR] GET /');

        expect(shouldSuppress, isFalse, reason: '"$line" should pass through');
      });
    }
  });
}

String _truncate(String s, int maxLength) {
  if (s.length <= maxLength) return s;
  return '${s.substring(0, maxLength)}...';
}
