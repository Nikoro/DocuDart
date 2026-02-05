import 'dart:io';

import 'package:docudart/src/cli/cli_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = DocuDartCliRunner();
  final exitCode = await runner.run(arguments);
  exit(exitCode);
}
