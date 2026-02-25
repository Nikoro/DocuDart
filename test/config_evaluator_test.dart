import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:docudart/src/config/config_evaluator.dart';
import 'package:docudart/src/config/docudart_config.dart';
import 'package:docudart/src/models/theme_mode.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('config_evaluator_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ConfigEvaluator', () {
    test('returns null when config.dart does not exist', () async {
      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNull);
    });

    test('extracts title from single-quoted string', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  title: 'My Site',
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.title, equals('My Site'));
    });

    test('extracts title from double-quoted string', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  title: "My Site",
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.title, equals('My Site'));
    });

    test('extracts description', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  title: 'Test',
  description: "My description here",
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.description, equals('My description here'));
    });

    test('extracts themeMode dark', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  themeMode: ThemeMode.dark,
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.themeMode, equals(ThemeMode.dark));
    });

    test('extracts themeMode light', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  themeMode: ThemeMode.light,
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.themeMode, equals(ThemeMode.light));
    });

    test('extracts Theme.classic with primaryColor', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  theme: Theme.classic(seedColor: Color.value(0xFF6366F1)),
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.theme.lightColorScheme.primary, equals(0xFF6366F1));
    });

    test('extracts Theme.material3', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  theme: Theme.material3(),
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.theme.name, equals('material3'));
    });

    test('extracts Theme.shadcn with primaryColor', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  theme: Theme.shadcn(seedColor: Color.value(0xFF0EA5E9)),
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.theme.name, equals('shadcn'));
      expect(result.theme.lightColorScheme.primary, equals(0xFF0EA5E9));
    });

    test('uses default theme when theme line is commented', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  // theme: Theme.classic(seedColor: 0xFFFF0000),
  title: 'Test',
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      // Should use default classic theme since the theme line is commented
      expect(result!.theme.lightColorScheme.primary, equals(0xFF0175C2));
    });

    test('uses default themeMode (system) when not specified', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  title: 'Test',
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.themeMode, equals(ThemeMode.system));
    });

    test('uses default directory paths when not specified', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  title: 'Test',
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      final Config(:docsDir, :assetsDir, :outputDir) = result!;
      expect(docsDir, equals('docs'));
      expect(assetsDir, equals('assets'));
      expect(outputDir, equals('build/web'));
    });

    test('extracts custom directory paths', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  docsDir: 'documentation',
  assetsDir: 'static',
  outputDir: 'dist',
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      final Config(:docsDir, :assetsDir, :outputDir) = result!;
      expect(docsDir, equals('documentation'));
      expect(assetsDir, equals('static'));
      expect(outputDir, equals('dist'));
    });

    test('function fields are null (not extractable from text)', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  title: 'Test',
  header: () => Header(),
  footer: () => Footer(),
  sidebar: () => Sidebar(),
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      final Config(:title, :header, :footer, :sidebar, :home) = result!;
      expect(title, equals('Test'));
      expect(header, isNull);
      expect(footer, isNull);
      expect(sidebar, isNull);
      expect(home, isNull);
    });
  });
}
