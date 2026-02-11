import 'package:args/command_runner.dart';

import 'commands/build_command.dart';
import 'commands/create_command.dart';
import 'commands/serve_command.dart';
import 'commands/update_command.dart';
import 'commands/version_command.dart';
import 'version/version_printer.dart';

/// Main CLI runner for DocuDart.
class DocuDartCliRunner extends CommandRunner<int> {
  DocuDartCliRunner()
    : super(
        'docudart',
        'A static documentation generator for Dart, powered by Jaspr.',
      ) {
    addCommand(CreateCommand());
    addCommand(BuildCommand());
    addCommand(ServeCommand());
    addCommand(VersionCommand());
    addCommand(UpdateCommand());

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
        await showVersion();
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
