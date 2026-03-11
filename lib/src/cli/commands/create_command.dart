import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:docudart/src/generators/project_generator.dart';
import 'package:docudart/src/cli/errors.dart';

/// Default folder name for DocuDart projects.
const defaultFolderName = 'docudart';

/// Regex for valid folder names (lowercase letters, digits, underscores; starts with letter).
final _validNameRegExp = RegExp(r'^[a-z][a-z0-9_]*$');

/// Command to create a new DocuDart project.
class CreateCommand extends Command<int> {
  CreateCommand() {
    argParser.addFlag(
      'full',
      abbr: 'f',
      help: 'Generate full template with all feature examples.',
      negatable: false,
    );
    argParser.addOption(
      'directory',
      abbr: 'd',
      help: 'Target directory (defaults to current directory).',
      defaultsTo: '.',
    );
  }
  @override
  String get name => 'create';

  @override
  String get description => 'Create a new DocuDart documentation project.';

  @override
  String get invocation => '${runner!.executableName} $name [name]';

  @override
  Future<int> run() async {
    final directory = argResults!['directory'] as String;
    final targetDir = p.normalize(p.absolute(directory));

    // Get folder name from positional argument or use default
    final folderName = argResults!.rest.isNotEmpty
        ? argResults!.rest.first
        : defaultFolderName;

    // Validate folder name
    if (!_validNameRegExp.hasMatch(folderName)) {
      CliPrinter.error('"$folderName" is not a valid project name.');
      CliPrinter.blank();
      CliPrinter.info(
        'Use only lowercase letters, digits, and underscores '
        '(must start with a letter).',
      );
      CliPrinter.info('Example: docudart create my_docs');
      return 1;
    }

    CliPrinter.header('DocuDart Project Setup');
    CliPrinter.info('Target directory: $targetDir');
    CliPrinter.blank();

    // Check if directory already has a <folderName>/config.dart
    final existingConfig = File(p.join(targetDir, folderName, 'config.dart'));
    if (existingConfig.existsSync()) {
      CliPrinter.warning(
        'A DocuDart project already exists in this directory.',
      );
      stdout.write('Overwrite? (y/N): ');
      final answer = stdin.readLineSync()?.trim().toLowerCase() ?? '';
      if (answer != 'y' && answer != 'yes') {
        CliPrinter.info('Cancelled.');
        return 0;
      }
      CliPrinter.blank();
    }

    // Check if --full flag is set, otherwise prompt interactively
    InitTemplate template;
    if (argResults!['full'] == true) {
      template = InitTemplate.full;
    } else {
      template = await _promptForTemplate();
    }

    final generator = ProjectGenerator();

    try {
      CliPrinter.step('Creating project structure');
      await generator.generate(
        directory: targetDir,
        template: template,
        folderName: folderName,
      );

      CliPrinter.blank();
      CliPrinter.success('DocuDart project created successfully!');
      CliPrinter.blank();
      CliPrinter.info('Next steps:');
      if (directory != '.') {
        CliPrinter.line('  cd $directory');
      }
      CliPrinter.line('  docudart serve');
      CliPrinter.blank();

      return 0;
    } on DocuDartException catch (e) {
      CliPrinter.exception(e);
      return 1;
    } catch (e) {
      CliPrinter.error('Error creating project: $e');
      return 1;
    }
  }

  Future<InitTemplate> _promptForTemplate() async {
    CliPrinter.line('Select a template:');
    CliPrinter.blank();
    CliPrinter.line(
      '  [1] Default - Basic setup with config, landing page, and docs',
    );
    CliPrinter.line('  [2] Full    - All features with examples');
    CliPrinter.blank();
    stdout.write('Enter choice (1 or 2) [1]: ');

    final input = stdin.readLineSync()?.trim() ?? '';

    if (input == '2') {
      return InitTemplate.full;
    }
    return InitTemplate.defaultTemplate;
  }
}
