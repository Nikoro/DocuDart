import 'package:test/test.dart';
import 'package:docudart/docudart.dart';

void main() {
  group('Config', () {
    test('creates with default values', () {
      final config = Config();

      expect(config.docsDir, equals('docs'));
      expect(config.outputDir, equals('build/web'));
      expect(config.assetsDir, equals('assets'));
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
    test('creates path and url nav links', () {
      final pathLink = NavLink.path('/docs', label: 'Docs');
      final urlLink = NavLink.url(
        'https://github.com/example',
        label: 'GitHub',
      );

      expect(pathLink.isExternal, isFalse);
      expect(pathLink.href, equals('/docs'));
      expect(pathLink.label, equals('Docs'));

      expect(urlLink.isExternal, isTrue);
      expect(urlLink.href, equals('https://github.com/example'));
    });

    test('serializes to json with label key', () {
      final link = NavLink.path('/docs', label: 'Docs');
      final json = link.toJson();

      expect(json['label'], equals('Docs'));
      expect(json['path'], equals('/docs'));
    });

    test('deserializes from json with legacy title key', () {
      final link = NavLink.fromJson({'title': 'Docs', 'path': '/docs'});
      expect(link.label, equals('Docs'));
      expect(link.href, equals('/docs'));
    });

    test('supports icon-only link', () {
      final link = NavLink.url('https://github.com', icon: span([.text('*')]));
      expect(link.label, isNull);
      expect(link.icon, isNotNull);
      expect(link.href, equals('https://github.com'));
    });

    test('supports icon and label together', () {
      final link = NavLink.url(
        'https://github.com',
        label: 'GitHub',
        icon: span([.text('*')]),
      );
      expect(link.label, equals('GitHub'));
      expect(link.icon, isNotNull);
    });

    test('toJson skips icon field', () {
      final link = NavLink.url(
        'https://example.com',
        label: 'Test',
        icon: span([.text('*')]),
      );
      final json = link.toJson();
      expect(json.containsKey('icon'), isFalse);
      expect(json['label'], equals('Test'));
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
