import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../core/project_generator.dart';

/// Command to initialize a new DocuDart project.
class InitCommand extends Command<int> {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize a new DocuDart documentation project.';

  InitCommand() {
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
  Future<int> run() async {
    final directory = argResults!['directory'] as String;
    final targetDir = p.normalize(p.absolute(directory));

    print('Initializing DocuDart project in $targetDir...');
    print('');

    // Check if --full flag is set, otherwise prompt interactively
    InitTemplate template;
    if (argResults!['full'] == true) {
      template = InitTemplate.full;
    } else {
      template = await _promptForTemplate();
    }

    final generator = ProjectGenerator();

    try {
      await generator.generate(
        directory: targetDir,
        template: template,
      );

      print('');
      print('DocuDart project initialized successfully!');
      print('');
      print('Next steps:');
      if (directory != '.') {
        print('  cd $directory');
      }
      print('  dart pub get');
      print('  docudart serve');
      print('');

      return 0;
    } catch (e) {
      print('Error initializing project: $e');
      return 1;
    }
  }

  Future<InitTemplate> _promptForTemplate() async {
    print('Select a template:');
    print('');
    print('  [1] Default - Basic setup with config, landing page, and docs');
    print('  [2] Full    - All features with examples');
    print('');
    stdout.write('Enter choice (1 or 2) [1]: ');

    final input = stdin.readLineSync()?.trim() ?? '';

    if (input == '2') {
      return InitTemplate.full;
    }
    return InitTemplate.defaultTemplate;
  }
}
