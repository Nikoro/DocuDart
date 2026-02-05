import 'package:test/test.dart';
import 'package:docudart/docudart.dart';

void main() {
  group('DocuDartConfig', () {
    test('creates with default values', () {
      final config = DocuDartConfig();

      expect(config.docsDir, equals('docs'));
      expect(config.outputDir, equals('build/web'));
      expect(config.assetsDir, equals('assets'));
      expect(config.cleanUrls, isTrue);
    });

    test('accepts custom values', () {
      final config = DocuDartConfig(
        title: 'My Docs',
        description: 'Test description',
        docsDir: 'documentation',
        outputDir: 'dist',
      );

      expect(config.title, equals('My Docs'));
      expect(config.description, equals('Test description'));
      expect(config.docsDir, equals('documentation'));
      expect(config.outputDir, equals('dist'));
    });

    test('copyWith creates modified copy', () {
      final config = DocuDartConfig(title: 'Original');
      final modified = config.copyWith(title: 'Modified');

      expect(config.title, equals('Original'));
      expect(modified.title, equals('Modified'));
      expect(modified.docsDir, equals(config.docsDir));
    });
  });

  group('DefaultTheme', () {
    test('has correct default values', () {
      const theme = DefaultTheme();

      expect(theme.name, equals('default'));
      expect(theme.darkMode, equals(DarkModeConfig.system));
      expect(theme.colors.primary, equals(0xFF0175C2));
    });

    test('accepts custom primary color', () {
      const theme = DefaultTheme(primaryColor: 0xFF6366F1);

      expect(theme.colors.primary, equals(0xFF6366F1));
    });
  });

  group('ThemeColors', () {
    test('toHex converts color correctly', () {
      expect(ThemeColors.toHex(0xFF0175C2), equals('#0175c2'));
      expect(ThemeColors.toHex(0xFFFFFFFF), equals('#ffffff'));
      expect(ThemeColors.toHex(0xFF000000), equals('#000000'));
    });
  });

  group('SidebarConfig', () {
    test('creates with default values', () {
      const config = SidebarConfig();

      expect(config.autoGenerate, isTrue);
      expect(config.items, isEmpty);
    });

    test('accepts sections and links', () {
      final config = SidebarConfig(
        items: [
          SidebarSection(
            title: 'Getting Started',
            items: [
              SidebarLink(title: 'Introduction', path: '/docs/intro'),
            ],
          ),
        ],
      );

      expect(config.items.length, equals(1));
      expect(config.items.first.title, equals('Getting Started'));
    });
  });

  group('HeaderConfig', () {
    test('creates with default values', () {
      const config = HeaderConfig();

      expect(config.showThemeToggle, isTrue);
      expect(config.showVersionSwitcher, isTrue);
      expect(config.navLinks, isEmpty);
    });

    test('creates internal and external nav links', () {
      final internalLink = NavLink.internal(
        title: 'Docs',
        path: '/docs',
      );
      final externalLink = NavLink.external(
        title: 'GitHub',
        url: 'https://github.com/example',
      );

      expect(internalLink.external, isFalse);
      expect(internalLink.path, equals('/docs'));

      expect(externalLink.external, isTrue);
      expect(externalLink.url, equals('https://github.com/example'));
    });
  });

  group('VersioningConfig', () {
    test('creates with disabled by default', () {
      const config = VersioningConfig();

      expect(config.enabled, isFalse);
      expect(config.versions, isEmpty);
    });

    test('can be enabled with versions', () {
      const config = VersioningConfig(
        enabled: true,
        versions: ['v1', 'v2'],
        defaultVersion: 'v2',
      );

      expect(config.enabled, isTrue);
      expect(config.versions, equals(['v1', 'v2']));
      expect(config.defaultVersion, equals('v2'));
    });
  });
}
