import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:docudart/src/config/config_evaluator.dart';
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

    test('extracts primaryColor from uncommented line', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  theme: DefaultTheme(primaryColor: 0xFF6366F1),
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      expect(result!.theme.colors.primary, equals(0xFF6366F1));
    });

    test('skips primaryColor on commented lines', () async {
      File(p.join(tempDir.path, 'config.dart')).writeAsStringSync('''
Config configure(BuildContext context) => Config(
  // theme: DefaultTheme(primaryColor: 0xFFFF0000),
  title: 'Test',
);
''');

      final result = await ConfigEvaluator.evaluate(tempDir.path);

      expect(result, isNotNull);
      // Should use default theme since the primaryColor line is commented
      expect(result!.theme.colors.primary, equals(0xFF0175C2));
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
      final config = result!;
      expect(config.docsDir, equals('docs'));
      expect(config.assetsDir, equals('assets'));
      expect(config.outputDir, equals('build/web'));
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
      final config = result!;
      expect(config.docsDir, equals('documentation'));
      expect(config.assetsDir, equals('static'));
      expect(config.outputDir, equals('dist'));
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
      final config = result!;
      expect(config.title, equals('Test'));
      expect(config.header, isNull);
      expect(config.footer, isNull);
      expect(config.sidebar, isNull);
      expect(config.home, isNull);
    });
  });
}
