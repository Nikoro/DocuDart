import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';

import 'package:docudart/src/cli/errors.dart';
import 'package:docudart/src/cli/version/installation_source.dart';

/// Command to update docudart to the latest version.
class UpdateCommand extends Command<int> {
  @override
  String get name => 'update';

  @override
  String get description => 'Update docudart to the latest version.';

  @override
  Future<int> run() async {
    final isGlobalExecution = Platform.script.toFilePath().contains(
      '.pub-cache/global_packages',
    );

    if (!isGlobalExecution) {
      CliPrinter.info('You are using a local path installation.');
      CliPrinter.info('To update, pull the latest changes manually.');
      return 0;
    }

    final installationInfo = await detectInstallationSource();

    final ProcessResult result;

    if (installationInfo.source == .git) {
      CliPrinter.step('Updating from git...');
      result = await Process.run('dart', [
        'pub',
        'global',
        'activate',
        '--source',
        'git',
        'https://github.com/Nikoro/docudart',
      ], runInShell: true);
    } else {
      CliPrinter.step('Updating from pub.dev...');
      result = await Process.run('dart', [
        'pub',
        'global',
        'activate',
        'docudart',
      ], runInShell: true);
    }

    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      CliPrinter.line(output);

      if (isAlreadyUpToDate(output)) {
        CliPrinter.success('Already up to date!');
      } else {
        CliPrinter.success('Successfully updated!');
      }
      return 0;
    } else {
      stderr.write(result.stderr);
      CliPrinter.error('Update failed.');
      return 1;
    }
  }

  /// Whether [output] from `dart pub global activate` indicates no update.
  @visibleForTesting
  static bool isAlreadyUpToDate(String output) => const [
    'already activated at newest available version',
    'is already active',
    'already using',
  ].any(output.contains);
}
