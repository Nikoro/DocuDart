import 'package:args/command_runner.dart';

import '../version/version_printer.dart';

/// Command to print the docudart version and check for updates.
class VersionCommand extends Command<int> {
  @override
  String get name => 'version';

  @override
  String get description => 'Print the docudart version and check for updates.';

  @override
  Future<int> run() async {
    await showVersion();
    return 0;
  }
}
