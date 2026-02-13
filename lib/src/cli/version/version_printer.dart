import 'dart:io';

import '../errors.dart';
import 'version_checker.dart';

// ANSI color codes
const _reset = '\x1B[0m';
const _bold = '\x1B[1m';
const _blue = '\x1B[34m';
const _orange = '\x1B[38;5;209m';

/// Prints the docudart version and checks for available updates.
///
/// Shared by both the `--version` flag and the `version` subcommand.
Future<void> showVersion() async {
  final version = await _getVersion();
  CliPrinter.line('docudart version: $_bold$_blue$version$_reset');

  if (version != null) {
    final updateCheck = await checkForUpdate(version);

    if (updateCheck != null && updateCheck.hasNewerVersion) {
      CliPrinter.line(
        '${_orange}Update available!$_reset '
        '$_blue$version$_reset → $_blue${updateCheck.latestVersion}$_reset',
      );

      if (updateCheck.changelogUrl != null) {
        final url = updateCheck.changelogUrl!;
        // OSC 8 hyperlink: \x1B]8;;URL\x1B\\TEXT\x1B]8;;\x1B\\
        final clickableLink =
            '\x1B]8;;$url\x1B\\$_blue$url$_reset\x1B]8;;\x1B\\';
        CliPrinter.line('${_orange}Changelog:$_reset $clickableLink');
      }

      CliPrinter.line('Run $_blue${_bold}docudart update$_reset to update');
    }
  }
}

Future<String?> _getVersion() async {
  final scriptPath = Platform.script.toFilePath();
  final customPubCache = Platform.environment['PUB_CACHE'];
  final isGlobalExecution =
      scriptPath.contains('.pub-cache/global_packages') ||
      (customPubCache != null &&
          scriptPath.contains('$customPubCache/global_packages'));

  if (isGlobalExecution) {
    final globalResult = await Process.run('dart', [
      'pub',
      'global',
      'list',
    ], runInShell: true);

    if (globalResult.exitCode == 0) {
      final output = globalResult.stdout.toString();
      final match = RegExp(
        r'^docudart\s+([\d\.]+)',
        multiLine: true,
      ).firstMatch(output);
      if (match != null) return match.group(1);
    }
  }

  final lockFile = File('pubspec.lock');
  if (lockFile.existsSync()) {
    final version = _parseVersionFromLock(lockFile, 'docudart');
    if (version != null) return version;
  }

  return null;
}

String? _parseVersionFromLock(File lockFile, String packageName) {
  final lines = lockFile.readAsLinesSync();
  bool inBlock = false;

  for (var line in lines) {
    line = line.trimRight();

    if (line.trim() == '$packageName:') {
      inBlock = true;
      continue;
    }

    if (inBlock) {
      if (!line.startsWith('  ')) break;
      final match = RegExp(r'version:\s*"([\d\.]+)"').firstMatch(line.trim());
      if (match != null) {
        return match.group(1);
      }
    }
  }

  return null;
}
