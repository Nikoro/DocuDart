import 'package:args/command_runner.dart';

import 'commands/init_command.dart';
import 'commands/build_command.dart';
import 'commands/serve_command.dart';

/// Main CLI runner for DocuDart.
class DocuDartCliRunner extends CommandRunner<int> {
  DocuDartCliRunner()
      : super(
          'docudart',
          'A static documentation generator for Dart, powered by Jaspr.',
        ) {
    addCommand(InitCommand());
    addCommand(BuildCommand());
    addCommand(ServeCommand());

    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the docudart version.',
    );
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final results = parse(args);
      if (results['version'] == true) {
        print('docudart version 0.0.1');
        return 0;
      }
      return await runCommand(results) ?? 0;
    } on UsageException catch (e) {
      print(e);
      return 64;
    } catch (e) {
      print('Error: $e');
      return 1;
    }
  }
}
