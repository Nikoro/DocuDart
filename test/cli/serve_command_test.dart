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

  group('shouldShowLog', () {
    final suppressedLines = [
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

    final passedLines = [
      'Serving at http://localhost:8080',
      'Building web assets...',
      'Build completed successfully',
      'Hot reload triggered',
      '',
      'INFO: some user message',
    ];

    for (final line in suppressedLines) {
      test('suppresses: "${_truncate(line, 50)}"', () {
        expect(ServeCommand.shouldShowLog(line), isFalse);
      });
    }

    for (final line in passedLines) {
      test('passes through: "${_truncate(line, 50)}"', () {
        expect(ServeCommand.shouldShowLog(line), isTrue);
      });
    }
  });
}

String _truncate(String s, int maxLength) {
  if (s.length <= maxLength) return s;
  return '${s.substring(0, maxLength)}...';
}
