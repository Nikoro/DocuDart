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
        header: () => div([.text('header')]),
        footer: () => div([.text('footer')]),
        sidebar: () => div([.text('sidebar')]),
      );

      expect(config.header, isNotNull);
      expect(config.footer, isNotNull);
      expect(config.sidebar, isNotNull);

      expect(config.header!(), isA<Component>());
      expect(config.footer!(), isA<Component>());
      expect(config.sidebar!(), isA<Component>());
    });

    test('toJson excludes function fields', () {
      final config = Config(
        title: 'Test',
        header: () => div([.text('header')]),
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

  group('Theme', () {
    test('classic factory has correct defaults', () {
      final theme = Theme.classic();

      expect(theme.name, equals('classic'));
      expect(theme.lightColorScheme.primary, equals(0xFF0175C2));
      expect(theme.darkColorScheme.primary, equals(0xFF54C5F8));
    });

    test('classic factory accepts custom primary color', () {
      final theme = Theme.classic(seedColor: Color.value(0xFF6366F1));

      expect(theme.lightColorScheme.primary, equals(0xFF6366F1));
    });

    test('material3 factory creates theme', () {
      final theme = Theme.material3();
      expect(theme.name, equals('material3'));
    });

    test('shadcn factory creates theme', () {
      final theme = Theme.shadcn();
      expect(theme.name, equals('shadcn'));
    });
  });

  group('ColorScheme', () {
    test('toHex converts color correctly', () {
      expect(ColorScheme.toHex(0xFF0175C2), equals('#0175c2'));
      expect(ColorScheme.toHex(0xFFFFFFFF), equals('#ffffff'));
      expect(ColorScheme.toHex(0xFF000000), equals('#000000'));
    });

    test('fromSeed generates light palette', () {
      final scheme = ColorScheme.fromSeed(seedColor: 0xFF0175C2);
      expect(scheme.primary, equals(0xFF0175C2));
      expect(scheme.error, equals(0xFFDC3545));
    });

    test('fromSeed generates dark palette', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: 0xFF0175C2,
        brightness: Brightness.dark,
      );
      expect(scheme.error, equals(0xFFFF6B6B));
    });
  });

  group('Link', () {
    test('creates path and url nav links', () {
      final pathLink = Link.path('/docs', label: 'Docs');
      final urlLink = Link.url('https://github.com/example', label: 'GitHub');

      expect(pathLink.isExternal, isFalse);
      expect(pathLink.href, equals('/docs'));
      expect(pathLink.label, equals('Docs'));

      expect(urlLink.isExternal, isTrue);
      expect(urlLink.href, equals('https://github.com/example'));
    });

    test('serializes to json with label key', () {
      final link = Link.path('/docs', label: 'Docs');
      final json = link.toJson();

      expect(json['label'], equals('Docs'));
      expect(json['path'], equals('/docs'));
    });

    test('deserializes from json with legacy title key', () {
      final link = Link.fromJson({'title': 'Docs', 'path': '/docs'});
      expect(link.label, equals('Docs'));
      expect(link.href, equals('/docs'));
    });

    test('supports leading-only link', () {
      final link = Link.url('https://github.com', leading: span([.text('*')]));
      expect(link.label, isNull);
      expect(link.leading, isNotNull);
      expect(link.href, equals('https://github.com'));
    });

    test('supports leading and label together', () {
      final link = Link.url(
        'https://github.com',
        label: 'GitHub',
        leading: span([.text('*')]),
      );
      expect(link.label, equals('GitHub'));
      expect(link.leading, isNotNull);
    });

    test('toJson skips leading and trailing fields', () {
      final link = Link.url(
        'https://example.com',
        label: 'Test',
        leading: span([.text('*')]),
        trailing: span([.text('>')]),
      );
      final json = link.toJson();
      expect(json.containsKey('leading'), isFalse);
      expect(json.containsKey('trailing'), isFalse);
      expect(json['label'], equals('Test'));
    });
  });

  group('Pubspec', () {
    test('creates with required name', () {
      const pubspec = Pubspec(
        name: 'my_package',
        environment: Environment(sdk: '^3.10.0'),
      );
      expect(pubspec.name, equals('my_package'));
      expect(pubspec.version, isNull);
      expect(pubspec.description, isNull);
      expect(pubspec.homepage, isNull);
      expect(pubspec.repository, isNull);
      expect(pubspec.funding, isNull);
      expect(pubspec.topics, isNull);
      expect(pubspec.environment.sdk, equals('^3.10.0'));
      expect(pubspec.environment.flutter, isNull);
    });

    test('creates with all fields', () {
      const pubspec = Pubspec(
        name: 'my_package',
        version: '1.0.0',
        description: 'A test package',
        homepage: 'https://example.com',
        repository: Repository('https://github.com/example/my_package'),
        issueTracker: 'https://github.com/example/my_package/issues',
        documentation: 'https://example.com/docs',
        publishTo: 'none',
        funding: ['https://github.com/sponsors/example'],
        topics: ['dart', 'test'],
        environment: Environment(sdk: '^3.10.0'),
      );
      expect(pubspec.name, equals('my_package'));
      expect(pubspec.version, equals('1.0.0'));
      expect(pubspec.description, equals('A test package'));
      expect(pubspec.homepage, equals('https://example.com'));
      expect(
        pubspec.repository,
        equals(const Repository('https://github.com/example/my_package')),
      );
      expect(
        pubspec.issueTracker,
        equals('https://github.com/example/my_package/issues'),
      );
      expect(pubspec.documentation, equals('https://example.com/docs'));
      expect(pubspec.publishTo, equals('none'));
      expect(pubspec.funding, equals(['https://github.com/sponsors/example']));
      expect(pubspec.topics, equals(['dart', 'test']));
      expect(pubspec.environment.sdk, equals('^3.10.0'));
      expect(pubspec.environment.flutter, isNull);
    });
  });

  group('Project', () {
    test('creates with required fields', () {
      const project = Project(
        pubspec: Pubspec(
          name: 'test',
          environment: Environment(sdk: 'any'),
        ),
        docs: [],
        pages: [],
      );

      expect(project.pubspec.name, equals('test'));
      expect(project.docs, isEmpty);
      expect(project.pages, isEmpty);
    });
  });

  group('Repository', () {
    test('detects GitHub from URL', () {
      const repo = Repository('https://github.com/user/repo');
      expect(repo.link, equals('https://github.com/user/repo'));
      expect(repo.label, equals('GitHub'));
      expect(repo.icon, isA<Component>());
    });

    test('detects GitHub from subdomain', () {
      const repo = Repository('https://enterprise.github.com/user/repo');
      expect(repo.label, equals('GitHub'));
    });

    test('detects GitLab from URL', () {
      const repo = Repository('https://gitlab.com/user/repo');
      expect(repo.label, equals('GitLab'));
    });

    test('detects Bitbucket from URL', () {
      const repo = Repository('https://bitbucket.org/user/repo');
      expect(repo.label, equals('Bitbucket'));
    });

    test('returns generic label for unknown host', () {
      const repo = Repository('https://example.com/user/repo');
      expect(repo.label, equals('Repository'));
      expect(repo.icon, isA<Component>());
    });

    test('equality based on link', () {
      const repo1 = Repository('https://github.com/user/repo');
      const repo2 = Repository('https://github.com/user/repo');
      const repo3 = Repository('https://gitlab.com/user/repo');
      expect(repo1, equals(repo2));
      expect(repo1, isNot(equals(repo3)));
    });

    test('toString returns readable format', () {
      const repo = Repository('https://github.com/user/repo');
      expect(
        repo.toString(),
        equals('Repository(https://github.com/user/repo)'),
      );
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
