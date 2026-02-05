import 'dart:io';

import 'package:args/command_runner.dart';

import '../../core/site_generator.dart';
import '../../config/config_loader.dart';

/// Command to start development server with hot reload.
class ServeCommand extends Command<int> {
  @override
  String get name => 'serve';

  @override
  String get description => 'Start development server with hot reload.';

  ServeCommand() {
    argParser.addOption(
      'port',
      abbr: 'p',
      help: 'Port to serve on.',
      defaultsTo: '8080',
    );
  }

  @override
  Future<int> run() async {
    final port = argResults!['port'] as String;

    print('Starting development server...');
    print('');

    // Check if config.dart exists
    final configFile = File('config.dart');
    if (!configFile.existsSync()) {
      print('Error: config.dart not found.');
      print('Run "docudart init" first to create a project.');
      return 1;
    }

    try {
      // Load configuration
      final config = await ConfigLoader.load();

      // Generate the managed Jaspr site
      final generator = SiteGenerator(config);
      await generator.generate();

      print('Server starting at http://localhost:$port');
      print('Press Ctrl+C to stop.');
      print('');

      // Run jaspr serve
      final process = await Process.start(
        'dart',
        ['run', 'jaspr', 'serve', '--port', port],
        workingDirectory: '.dart_tool/docudart',
        mode: ProcessStartMode.inheritStdio,
      );

      // Handle Ctrl+C
      ProcessSignal.sigint.watch().listen((_) {
        process.kill();
        exit(0);
      });

      return await process.exitCode;
    } catch (e) {
      print('Error: $e');
      return 1;
    }
  }
}
