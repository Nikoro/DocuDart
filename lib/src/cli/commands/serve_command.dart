import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package:docudart/src/generators/site_generator.dart';
import 'package:docudart/src/services/file_watcher.dart';
import 'package:docudart/src/services/workspace_resolver.dart';
import 'package:docudart/src/config/config_loader.dart';
import 'package:docudart/src/cli/errors.dart';

/// Command to start development server with hot reload.
class ServeCommand extends Command<int> {
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
  String get name => 'serve';

  @override
  String get description => 'Start development server with hot reload.';

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

      // Load parent project pubspec, changelog, and license
      final pubspec = await ConfigLoader.loadParentPubspec(websiteDir);
      final changelog = await ConfigLoader.loadParentChangelog(websiteDir);
      final license = await ConfigLoader.loadParentLicense(websiteDir);

      // Generate the managed Jaspr site
      CliPrinter.step('Generating site structure');
      final generator = SiteGenerator(
        config,
        websiteDir: websiteDir,
        serveMode: true,
      );
      await generator.generate(
        pubspec: pubspec,
        changelog: changelog,
        license: license,
      );

      // Start file watcher if enabled.
      // On change, regenerate files in-place and bump live-reload version.
      // The browser polls live-reload-version.txt and auto-refreshes.
      if (watchEnabled) {
        fileWatcher = DocuDartFileWatcher(
          config: config,
          websiteDir: websiteDir,
          onRegenerate: () async {
            final newConfig = await ConfigLoader.load(websiteDir);
            final newPubspec = await ConfigLoader.loadParentPubspec(websiteDir);
            final newChangelog = await ConfigLoader.loadParentChangelog(
              websiteDir,
            );
            final newLicense = await ConfigLoader.loadParentLicense(websiteDir);
            final newGenerator = SiteGenerator(
              newConfig,
              websiteDir: websiteDir,
              serveMode: true,
            );
            await newGenerator.generate(
              fullClean: false,
              pubspec: newPubspec,
              changelog: newChangelog,
              license: newLicense,
            );
            await newGenerator.bumpLiveReloadVersion();
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

      // Run jaspr serve in the managed project directory.
      final managedDir = p.join(websiteDir, '.dart_tool', 'docudart');
      final process = await Process.start('dart', [
        'run',
        'jaspr_cli:jaspr',
        'serve',
        '--port',
        port,
      ], workingDirectory: managedDir);

      // Filter Jaspr output — suppress noisy internal logs.
      final stdoutSub = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (shouldShowLog(line)) {
              stdout.writeln(line);
            }
          });
      final stderrLines = <String>[];
      final stderrSub = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            stderrLines.add(line);
            if (shouldShowLog(line)) {
              stderr.writeln(line);
            }
          });

      // Forward stdin to the process.
      final stdinSub = stdin.listen(process.stdin.add);

      // Handle Ctrl+C
      final sigintSub = ProcessSignal.sigint.watch().listen((_) async {
        await fileWatcher?.stop();
        process.kill();
        exit(0);
      });

      final exitCode = await process.exitCode;

      // Clean up subscriptions and file watcher
      await stdoutSub.cancel();
      await stderrSub.cancel();
      await stdinSub.cancel();
      await sigintSub.cancel();
      await fileWatcher?.stop();

      if (exitCode != 0) {
        final stderrOutput = stderrLines.join('\n');
        if (stderrOutput.contains('already in use') ||
            stderrOutput.contains('SocketException') ||
            stderrOutput.contains('Address already in use')) {
          CliPrinter.exception(DocuDartErrors.portInUse(portNum));
        } else {
          CliPrinter.exception(DocuDartErrors.buildFailed(stderrOutput));
        }
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

  /// Filter out noisy Jaspr internal logs (proxy errors, stack traces, etc.).
  /// Only show lines that are useful to the user.
  @visibleForTesting
  static bool shouldShowLog(String line) {
    // Suppress empty lines from filtered blocks
    if (line.trim().isEmpty) return true;

    // Suppress proxy socket errors (transient during reload)
    if (line.contains('SocketException') ||
        line.contains('Connection attempt cancelled') ||
        line.contains('ClientException with SocketException')) {
      return false;
    }

    // Suppress internal stack frames
    if (line.contains('dart:_http') ||
        line.contains('package:http/') ||
        line.contains('package:shelf_proxy/') ||
        line.contains('package:shelf_gzip/') ||
        line.contains('package:shelf/shelf_io.dart') ||
        line.contains('package:jaspr/src/server/')) {
      return false;
    }

    // Suppress generic error headers for suppressed errors
    if (line.contains('[SERVER] [ERROR] ERROR -') ||
        line.contains('[SERVER] [ERROR] Asynchronous error') ||
        line.contains('[SERVER] [ERROR] Error thrown by handler.') ||
        line.contains('[SERVER] [ERROR] GET /')) {
      return false;
    }

    return true;
  }
}
