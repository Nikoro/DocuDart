import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../core/site_generator.dart';
import '../../config/config_loader.dart';
import '../errors.dart';

/// Command to build the documentation site for production.
class BuildCommand extends Command<int> {
  @override
  String get name => 'build';

  @override
  String get description => 'Build the documentation site for production.';

  BuildCommand() {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output directory (overrides config).',
    );
  }

  @override
  Future<int> run() async {
    CliPrinter.header('DocuDart Build');

    // Check if config.dart exists
    final configFile = File('config.dart');
    if (!configFile.existsSync()) {
      CliPrinter.exception(DocuDartErrors.configNotFound());
      return 1;
    }

    try {
      // Load configuration
      CliPrinter.step('Loading configuration');
      final config = await ConfigLoader.load();

      // Check if docs directory exists
      final docsDir = Directory(config.docsDir);
      if (!docsDir.existsSync()) {
        CliPrinter.exception(DocuDartErrors.docsNotFound(config.docsDir));
        return 1;
      }

      // Determine output directory
      final outputDir = argResults!['output'] as String? ?? config.outputDir;
      final absoluteOutput = p.normalize(p.absolute(outputDir));

      // Generate the managed Jaspr site
      CliPrinter.step('Generating site structure');
      final generator = SiteGenerator(config);
      await generator.generate();

      // Run jaspr build
      CliPrinter.step('Running Jaspr build');
      final result = await Process.run(
        'dart',
        ['run', 'jaspr', 'build'],
        workingDirectory: '.dart_tool/docudart',
      );

      if (result.exitCode != 0) {
        CliPrinter.exception(
          DocuDartErrors.buildFailed(result.stderr.toString()),
        );
        return 1;
      }

      // Copy build output to target directory
      CliPrinter.step('Copying build output');
      await _copyBuildOutput(absoluteOutput);

      CliPrinter.blank();
      CliPrinter.success('Build complete!');
      CliPrinter.info('Output: $absoluteOutput');

      return 0;
    } on DocuDartException catch (e) {
      CliPrinter.exception(e);
      return 1;
    } catch (e) {
      CliPrinter.error('Unexpected error: $e');
      return 1;
    }
  }

  Future<void> _copyBuildOutput(String outputDir) async {
    final sourceDir = Directory('.dart_tool/docudart/build/jaspr');
    final targetDir = Directory(outputDir);

    if (!sourceDir.existsSync()) {
      throw Exception('Build output not found at ${sourceDir.path}');
    }

    // Create target directory
    if (targetDir.existsSync()) {
      await targetDir.delete(recursive: true);
    }
    await targetDir.create(recursive: true);

    // Copy all files
    await for (final entity in sourceDir.list(recursive: true)) {
      final relativePath = p.relative(entity.path, from: sourceDir.path);
      final targetPath = p.join(outputDir, relativePath);

      if (entity is File) {
        final targetFile = File(targetPath);
        await targetFile.parent.create(recursive: true);
        await entity.copy(targetPath);
      } else if (entity is Directory) {
        await Directory(targetPath).create(recursive: true);
      }
    }
  }
}
