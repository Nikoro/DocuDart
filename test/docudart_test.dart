import 'package:test/test.dart';
import 'package:docudart/docudart.dart';

void main() {
  group('Config', () {
    test('creates with default values', () {
      final config = Config();

      expect(config.docsDir, equals('docs'));
      expect(config.outputDir, equals('build/web'));
      expect(config.assetsDir, equals('assets'));
      expect(config.cleanUrls, isTrue);
      expect(config.themeMode, equals(ThemeMode.system));
      expect(config.header, isNull);
      expect(config.footer, isNull);
      expect(config.sidebar, isNull);
    });

    test('accepts custom values', () {
      final config = Config(
        title: 'My Docs',
        description: 'Test description',
        docsDir: 'documentation',
        outputDir: 'dist',
        themeMode: ThemeMode.dark,
      );

      expect(config.title, equals('My Docs'));
      expect(config.description, equals('Test description'));
      expect(config.docsDir, equals('documentation'));
      expect(config.outputDir, equals('dist'));
      expect(config.themeMode, equals(ThemeMode.dark));
    });

    test('copyWith creates modified copy', () {
      final config = Config(title: 'Original');
      final modified = config.copyWith(title: 'Modified');

      expect(config.title, equals('Original'));
      expect(modified.title, equals('Modified'));
      expect(modified.docsDir, equals(config.docsDir));
    });

    test('header/footer/sidebar accept functions', () {
      final config = Config(
        header: (context) => div([.text('header')]),
        footer: (context) => div([.text('footer')]),
        sidebar: (context) => div([.text('sidebar')]),
      );

      expect(config.header, isNotNull);
      expect(config.footer, isNotNull);
      expect(config.sidebar, isNotNull);

      final context = SiteContext(docs: [], pages: []);
      expect(config.header!(context), isA<Component>());
      expect(config.footer!(context), isA<Component>());
      expect(config.sidebar!(context), isA<Component>());
    });

    test('toJson excludes function fields', () {
      final config = Config(
        title: 'Test',
        header: (context) => div([.text('header')]),
      );

      final json = config.toJson();
      expect(json['title'], equals('Test'));
      expect(json.containsKey('header'), isFalse);
      expect(json.containsKey('footer'), isFalse);
      expect(json.containsKey('sidebar'), isFalse);
    });

    test('fromJson sets functions to null', () {
      final config = Config.fromJson({'title': 'Test'});

      expect(config.title, equals('Test'));
      expect(config.header, isNull);
      expect(config.footer, isNull);
      expect(config.sidebar, isNull);
    });
  });

  group('ThemeMode', () {
    test('serializes to json', () {
      expect(ThemeMode.system.toJson(), equals('system'));
      expect(ThemeMode.light.toJson(), equals('light'));
      expect(ThemeMode.dark.toJson(), equals('dark'));
    });

    test('deserializes from json', () {
      expect(ThemeMode.fromJson('system'), equals(ThemeMode.system));
      expect(ThemeMode.fromJson('light'), equals(ThemeMode.light));
      expect(ThemeMode.fromJson('dark'), equals(ThemeMode.dark));
      expect(ThemeMode.fromJson('invalid'), equals(ThemeMode.system));
    });
  });

  group('DefaultTheme', () {
    test('has correct default values', () {
      const theme = DefaultTheme();

      expect(theme.name, equals('default'));
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

  group('NavLink', () {
    test('creates internal and external nav links', () {
      final internalLink = NavLink.internal(title: 'Docs', path: '/docs');
      final externalLink = NavLink.external(
        title: 'GitHub',
        url: 'https://github.com/example',
      );

      expect(internalLink.external, isFalse);
      expect(internalLink.path, equals('/docs'));

      expect(externalLink.external, isTrue);
      expect(externalLink.url, equals('https://github.com/example'));
    });

    test('serializes to json', () {
      final link = NavLink.internal(title: 'Docs', path: '/docs');
      final json = link.toJson();

      expect(json['title'], equals('Docs'));
      expect(json['path'], equals('/docs'));
    });
  });

  group('SiteContext', () {
    test('creates with required fields', () {
      const context = SiteContext(docs: [], pages: []);

      expect(context.docs, isEmpty);
      expect(context.pages, isEmpty);
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
