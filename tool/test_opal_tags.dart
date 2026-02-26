import 'dart:convert';

import 'package:opal/opal.dart';

void main() {
  final registry = LanguageRegistry.withDefaults();
  final dart = registry['dart']!;

  const code =
      "flybyObjects.where((name) => name.contains('turn')).forEach(print);";

  final lines = const LineSplitter().convert(code);
  final tokenizedLines = dart.tokenize(lines);

  for (int i = 0; i < tokenizedLines.length; i++) {
    for (final token in tokenizedLines[i]) {
      if (token.content.trim().isEmpty) continue;
      final tagStrs = token.tags.map((t) => t.toString()).join(', ');
      print('"${token.content.trim()}" -> [$tagStrs]');
    }
  }
}
