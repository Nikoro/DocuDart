import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../generators/project_generator.dart';
import '../errors.dart';

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
  Future<int> run() async {
    final directory = argResults!['directory'] as String;
    final targetDir = p.normalize(p.absolute(directory));

    CliPrinter.header('DocuDart Project Setup');
    CliPrinter.info('Target directory: $targetDir');
    CliPrinter.blank();

    // Check if directory already has a website/config.dart
    final existingConfig = File(p.join(targetDir, 'website', 'config.dart'));
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
      await generator.generate(directory: targetDir, template: template);

      CliPrinter.blank();
      CliPrinter.success('DocuDart project created successfully!');
      CliPrinter.blank();
      CliPrinter.info('Next steps:');
      if (directory != '.') {
        print('  cd $directory');
      }
      print('  docudart serve');
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
    print('Select a template:');
    CliPrinter.blank();
    print('  [1] Default - Basic setup with config, landing page, and docs');
    print('  [2] Full    - All features with examples');
    CliPrinter.blank();
    stdout.write('Enter choice (1 or 2) [1]: ');

    final input = stdin.readLineSync()?.trim() ?? '';

    if (input == '2') {
      return InitTemplate.full;
    }
    return InitTemplate.defaultTemplate;
  }
}
