import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../core/site_generator.dart';
import '../../config/config_loader.dart';

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
    print('Building documentation site...');
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

      // Determine output directory
      final outputDir = argResults!['output'] as String? ?? config.outputDir;
      final absoluteOutput = p.normalize(p.absolute(outputDir));

      // Generate the managed Jaspr site
      final generator = SiteGenerator(config);
      await generator.generate();

      // Run jaspr build
      print('Running Jaspr build...');
      final result = await Process.run(
        'dart',
        ['run', 'jaspr', 'build'],
        workingDirectory: '.dart_tool/docudart',
      );

      if (result.exitCode != 0) {
        print('Build failed:');
        print(result.stderr);
        return 1;
      }

      // Copy build output to target directory
      await _copyBuildOutput(absoluteOutput);

      print('');
      print('Build complete!');
      print('Output: $absoluteOutput');

      return 0;
    } catch (e) {
      print('Error: $e');
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
