import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../core/site_generator.dart';
import '../../core/file_watcher.dart';
import '../../core/workspace_resolver.dart';
import '../../config/config_loader.dart';
import '../errors.dart';

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
    argParser.addFlag(
      'watch',
      abbr: 'w',
      help: 'Watch for file changes and regenerate.',
      defaultsTo: true,
    );
  }

  @override
  Future<int> run() async {
    final port = argResults!['port'] as String;
    final portNum = int.tryParse(port) ?? 8080;
    final watchEnabled = argResults!['watch'] as bool;

    CliPrinter.header('DocuDart Development Server');

    // Auto-detect website directory
    final websiteDir = WorkspaceResolver.resolve();
    if (websiteDir == null) {
      CliPrinter.exception(DocuDartErrors.configNotFound());
      return 1;
    }

    DocuDartFileWatcher? fileWatcher;

    try {
      // Load configuration
      CliPrinter.step('Loading configuration');
      final config = await ConfigLoader.load(websiteDir);

      // Check if docs directory exists
      final docsDir = Directory(config.docsDir);
      if (!docsDir.existsSync()) {
        CliPrinter.exception(DocuDartErrors.docsNotFound(config.docsDir));
        return 1;
      }

      // Generate the managed Jaspr site
      CliPrinter.step('Generating site structure');
      final generator = SiteGenerator(config, websiteDir: websiteDir);
      await generator.generate();

      // Start file watcher if enabled
      if (watchEnabled) {
        fileWatcher = DocuDartFileWatcher(
          config: config,
          onRegenerate: () async {
            // Reload config in case it changed
            final newConfig = await ConfigLoader.load(websiteDir);
            final newGenerator = SiteGenerator(newConfig, websiteDir: websiteDir);
            await newGenerator.generate();
          },
        );
        await fileWatcher.start();
      }

      CliPrinter.blank();
      CliPrinter.success('Server starting at http://localhost:$port');
      if (watchEnabled) {
        CliPrinter.info('File watching enabled - changes will auto-reload');
      }
      CliPrinter.info('Press Ctrl+C to stop');
      CliPrinter.blank();

      // Run jaspr serve
      final managedDir = p.join(websiteDir, '.dart_tool', 'docudart');
      final process = await Process.start(
        'dart',
        ['run', 'jaspr_cli:jaspr', 'serve', '--port', port],
        workingDirectory: managedDir,
        mode: ProcessStartMode.inheritStdio,
      );

      // Handle Ctrl+C
      ProcessSignal.sigint.watch().listen((_) async {
        await fileWatcher?.stop();
        process.kill();
        exit(0);
      });

      final exitCode = await process.exitCode;

      // Clean up file watcher
      await fileWatcher?.stop();

      // Check for port in use error
      if (exitCode != 0) {
        CliPrinter.exception(DocuDartErrors.portInUse(portNum));
      }

      return exitCode;
    } on DocuDartException catch (e) {
      await fileWatcher?.stop();
      CliPrinter.exception(e);
      return 1;
    } catch (e) {
      await fileWatcher?.stop();
      CliPrinter.error('Unexpected error: $e');
      return 1;
    }
  }
}
