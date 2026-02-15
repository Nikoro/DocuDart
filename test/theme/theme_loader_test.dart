import 'dart:io';

import 'package:docudart/src/theme/theme_loader.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('theme_loader_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<String> writeTheme(String filename, String content) async {
    final path = p.join(tempDir.path, filename);
    await File(path).writeAsString(content);
    return path;
  }

  group('ThemeLoader.loadFromFile', () {
    test('returns null for non-existent file', () async {
      final theme = await ThemeLoader.loadFromFile(
        p.join(tempDir.path, 'nonexistent.yaml'),
      );
      expect(theme, isNull);
    });

    test('loads a complete theme from YAML', () async {
      final path = await writeTheme('custom.yaml', '''
name: My Custom Theme
lightColorScheme:
  primary: "#FF5733"
  secondary: "#13B9FD"
  background: "#FFFFFF"
  surface: "#F8F9FA"
  surfaceVariant: "#F1F3F5"
  text: "#1D1D1D"
  textMuted: "#6C757D"
  border: "#E0E0E0"
  codeBackground: "#F5F5F5"
  error: "#DC3545"
  success: "#28A745"
  warning: "#FFC107"
  info: "#17A2B8"
darkColorScheme:
  primary: "#54C5F8"
  secondary: "#13B9FD"
  background: "#0D1117"
  surface: "#161B22"
  surfaceVariant: "#21262D"
  text: "#E6EDF3"
  textMuted: "#8B949E"
  border: "#30363D"
  codeBackground: "#161B22"
  error: "#FF6B6B"
  success: "#51CF66"
  warning: "#FFD43B"
  info: "#4DABF7"
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNotNull);
      expect(theme!.name, equals('My Custom Theme'));
      expect(theme.lightColorScheme.primary, equals(0xFFFF5733));
      expect(theme.darkColorScheme.primary, equals(0xFF54C5F8));
    });

    test('uses filename as fallback name when name field missing', () async {
      final path = await writeTheme('ocean.yaml', '''
lightColorScheme:
  primary: "#0077B6"
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNotNull);
      expect(theme!.name, equals('ocean'));
    });

    test('parses hex color with # prefix', () async {
      final path = await writeTheme('hex.yaml', '''
lightColorScheme:
  primary: "#FF5733"
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNotNull);
      expect(theme!.lightColorScheme.primary, equals(0xFFFF5733));
    });

    test('parses shorthand 3-char hex (#F00 -> FF0000)', () async {
      final path = await writeTheme('short.yaml', '''
lightColorScheme:
  primary: "#F00"
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNotNull);
      expect(theme!.lightColorScheme.primary, equals(0xFFFF0000));
    });

    test('parses hex without # prefix', () async {
      final path = await writeTheme('nohash.yaml', '''
lightColorScheme:
  primary: "00AAFF"
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNotNull);
      expect(theme!.lightColorScheme.primary, equals(0xFF00AAFF));
    });

    test('parses integer color values', () async {
      final path = await writeTheme('intcolor.yaml', '''
lightColorScheme:
  primary: 16734003
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNotNull);
      expect(theme!.lightColorScheme.primary, equals(16734003));
    });

    test('uses default colors when color schemes are missing', () async {
      final path = await writeTheme('minimal.yaml', '''
name: Minimal
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNotNull);
      // Check default light primary color
      expect(theme!.lightColorScheme.primary, equals(0xFF0175C2));
      // Check default dark primary color
      expect(theme.darkColorScheme.primary, equals(0xFF54C5F8));
    });

    test('returns null for invalid YAML', () async {
      final path = await writeTheme('broken.yaml', '''
this is not: [valid: yaml: content
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNull);
    });

    test('toJson includes name', () async {
      final path = await writeTheme('typed.yaml', '''
name: Typed
''');

      final theme = await ThemeLoader.loadFromFile(path);
      expect(theme, isNotNull);
      final json = theme!.toJson();
      expect(json['name'], equals('Typed'));
    });
  });

  group('ThemeLoader.loadByName', () {
    test('finds .yaml file', () async {
      final themesDir = p.join(tempDir.path, 'themes');
      await Directory(themesDir).create();
      await File(p.join(themesDir, 'ocean.yaml')).writeAsString('''
name: Ocean
lightColorScheme:
  primary: "#0077B6"
''');

      final theme = await ThemeLoader.loadByName('ocean', themesDir);
      expect(theme, isNotNull);
      expect(theme!.name, equals('Ocean'));
    });

    test('finds .yml file', () async {
      final themesDir = p.join(tempDir.path, 'themes');
      await Directory(themesDir).create();
      await File(p.join(themesDir, 'forest.yml')).writeAsString('''
name: Forest
lightColorScheme:
  primary: "#228B22"
''');

      final theme = await ThemeLoader.loadByName('forest', themesDir);
      expect(theme, isNotNull);
      expect(theme!.name, equals('Forest'));
    });

    test('prefers .yaml over .yml', () async {
      final themesDir = p.join(tempDir.path, 'themes');
      await Directory(themesDir).create();
      await File(p.join(themesDir, 'dual.yaml')).writeAsString('''
name: YAML Version
''');
      await File(p.join(themesDir, 'dual.yml')).writeAsString('''
name: YML Version
''');

      final theme = await ThemeLoader.loadByName('dual', themesDir);
      expect(theme, isNotNull);
      expect(theme!.name, equals('YAML Version'));
    });

    test('returns null for non-existent theme', () async {
      final themesDir = p.join(tempDir.path, 'themes');
      await Directory(themesDir).create();

      final theme = await ThemeLoader.loadByName('missing', themesDir);
      expect(theme, isNull);
    });
  });

  group('ThemeLoader.discoverThemes', () {
    test('returns empty list for non-existent directory', () async {
      final themes = await ThemeLoader.discoverThemes(
        p.join(tempDir.path, 'nonexistent'),
      );
      expect(themes, isEmpty);
    });

    test('discovers all YAML and YML files', () async {
      final themesDir = p.join(tempDir.path, 'themes');
      await Directory(themesDir).create();
      await File(p.join(themesDir, 'a.yaml')).writeAsString('name: A');
      await File(p.join(themesDir, 'b.yml')).writeAsString('name: B');
      await File(p.join(themesDir, 'readme.md')).writeAsString('# Themes');

      final themes = await ThemeLoader.discoverThemes(themesDir);
      expect(themes, hasLength(2));
      final names = themes.map((t) => t.name).toSet();
      expect(names, containsAll(['A', 'B']));
    });

    test('returns empty list for directory with no theme files', () async {
      final themesDir = p.join(tempDir.path, 'themes');
      await Directory(themesDir).create();
      await File(p.join(themesDir, 'readme.md')).writeAsString('# Nothing');

      final themes = await ThemeLoader.discoverThemes(themesDir);
      expect(themes, isEmpty);
    });
  });
}
