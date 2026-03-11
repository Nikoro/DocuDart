import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:docudart/src/config/docudart_config.dart';
import 'package:docudart/src/generators/styles_generator.dart';
import 'package:docudart/src/theme/theme.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('styles_gen_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  Future<String> generateCss({
    Config? config,
    bool includeVersionSwitcher = false,
  }) async {
    final cfg = config ?? Config();
    final generator = StylesGenerator(cfg);
    await generator.generate(
      tempDir.path,
      includeVersionSwitcher: includeVersionSwitcher,
    );
    return File(p.join(tempDir.path, 'styles.css')).readAsString();
  }

  group('StylesGenerator', () {
    test('generates styles.css file', () async {
      final css = await generateCss();
      expect(css.isNotEmpty, isTrue);
    });

    test('includes CSS custom properties for light color scheme', () async {
      final css = await generateCss();
      expect(css, contains('--color-primary:'));
      expect(css, contains('--color-background:'));
      expect(css, contains('--color-surface:'));
      expect(css, contains('--color-text:'));
      expect(css, contains('--color-border:'));
    });

    test('includes dark mode block', () async {
      final css = await generateCss();
      expect(css, contains('[data-theme="dark"]'));
    });

    test('includes font family from text theme', () async {
      final css = await generateCss();
      expect(css, contains('--font-family:'));
    });

    test('includes heading styles', () async {
      final css = await generateCss();
      expect(css, contains('.docs-content h1'));
      expect(css, contains('.docs-content h2'));
      expect(css, contains('.docs-content h3'));
      expect(css, contains('.docs-content h4'));
    });

    test('includes opal code theme CSS', () async {
      final css = await generateCss();
      expect(css, contains('pre.opal'));
    });

    test('includes sidebar styles', () async {
      final css = await generateCss();
      expect(css, contains('.sidebar'));
    });

    test('includes mobile responsive styles', () async {
      final css = await generateCss();
      expect(css, contains('@media'));
      expect(css, contains('.sidebar-backdrop'));
    });

    test('classic preset uses Inter font', () async {
      final css = await generateCss(config: Config(theme: Theme.classic()));
      expect(css, contains('Inter'));
    });

    test('material3 preset uses Roboto font', () async {
      final css = await generateCss(config: Config(theme: Theme.material3()));
      expect(css, contains('Roboto'));
    });

    test('includes version switcher styles when requested', () async {
      final css = await generateCss(includeVersionSwitcher: true);
      expect(css, contains('version-switcher'));
    });

    test('excludes version switcher styles by default', () async {
      final css = await generateCss();
      expect(css, isNot(contains('version-switcher')));
    });
  });
}
