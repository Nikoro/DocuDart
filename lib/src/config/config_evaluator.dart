import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'docudart_config.dart';

/// Evaluates config.dart by running it as a Dart subprocess.
class ConfigEvaluator {
  /// Evaluate config.dart in the given website directory.
  /// Returns null if config.dart doesn't exist or evaluation fails.
  static Future<Config?> evaluate(String websiteDir) async {
    final configFile = File(p.join(websiteDir, 'config.dart'));
    if (!configFile.existsSync()) {
      return null;
    }

    // Generate the extractor script in .dart_tool/ (alongside package_config.json)
    final scriptPath = p.join(
      websiteDir,
      '.dart_tool',
      'docudart_config_extract.dart',
    );

    await Directory(p.dirname(scriptPath)).create(recursive: true);
    await File(scriptPath).writeAsString(_extractorScript);

    try {
      final result = await Process.run(
        'dart',
        ['run', scriptPath],
        workingDirectory: websiteDir,
      );

      if (result.exitCode != 0) {
        print('Warning: Failed to evaluate config.dart: ${result.stderr}');
        return null;
      }

      final jsonStr = (result.stdout as String).trim();
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Config.fromJson(json);
    } catch (e) {
      print('Warning: Failed to evaluate config.dart: $e');
      return null;
    } finally {
      try {
        await File(scriptPath).delete();
      } catch (_) {}
    }
  }

  static const _extractorScript = '''
import 'dart:convert';
import '../config.dart';

void main() {
  print(jsonEncode(config.toJson()));
}
''';
}
