import 'package:test/test.dart';
import 'package:docudart/docudart.dart';

void main() {
  group('Config', () {
    test('creates with default values', () {
      final Config(
        :docsDir,
        :outputDir,
        :assetsDir,
        :themeMode,
        :header,
        :footer,
        :sidebar,
      ) = Config();

      expect(docsDir, equals('docs'));
      expect(outputDir, equals('build/web'));
      expect(assetsDir, equals('assets'));
      expect(themeMode, equals(ThemeMode.system));
      expect(header, isNull);
      expect(footer, isNull);
      expect(sidebar, isNull);
    });

    test('accepts custom values', () {
      final Config(
        :title,
        :description,
        :docsDir,
        :outputDir,
        :themeMode,
      ) = Config(
        title: 'My Docs',
        description: 'Test description',
        docsDir: 'documentation',
        outputDir: 'dist',
        themeMode: ThemeMode.dark,
      );

      expect(title, equals('My Docs'));
      expect(description, equals('Test description'));
      expect(docsDir, equals('documentation'));
      expect(outputDir, equals('dist'));
      expect(themeMode, equals(ThemeMode.dark));
    });

    test('copyWith creates modified copy', () {
      final config = Config(title: 'Original');
      final modified = config.copyWith(title: 'Modified');

      expect(config.title, equals('Original'));
      expect(modified.title, equals('Modified'));
      expect(modified.docsDir, equals(config.docsDir));
    });

    test('header/footer/sidebar accept functions', () {
      final Config(:header, :footer, :sidebar) = Config(
        header: () => div([.text('header')]),
        footer: () => div([.text('footer')]),
        sidebar: () => div([.text('sidebar')]),
      );

      expect(header, isNotNull);
      expect(footer, isNotNull);
      expect(sidebar, isNotNull);

      expect(header!(), isA<Component>());
      expect(footer!(), isA<Component>());
      expect(sidebar!(), isA<Component>());
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
      final Config(:title, :header, :footer, :sidebar) = Config.fromJson({
        'title': 'Test',
      });

      expect(title, equals('Test'));
      expect(header, isNull);
      expect(footer, isNull);
      expect(sidebar, isNull);
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
      final Link(:isExternal, :href, :label) = Link.path(
        '/docs',
        label: 'Docs',
      );
      final urlLink = Link.url('https://github.com/example', label: 'GitHub');

      expect(isExternal, isFalse);
      expect(href, equals('/docs'));
      expect(label, equals('Docs'));

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
      final Link(:label, :leading, :href) = Link.url(
        'https://github.com',
        leading: span([.text('*')]),
      );
      expect(label, isNull);
      expect(leading, isNotNull);
      expect(href, equals('https://github.com'));
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
      final Pubspec(
        :name,
        :version,
        :description,
        :homepage,
        :repository,
        :funding,
        :topics,
        :environment,
      ) = const Pubspec(
        name: 'my_package',
        environment: Environment(sdk: '^3.10.0'),
      );
      expect(name, equals('my_package'));
      expect(version, isNull);
      expect(description, isNull);
      expect(homepage, isNull);
      expect(repository, isNull);
      expect(funding, isNull);
      expect(topics, isNull);
      expect(environment.sdk, equals('^3.10.0'));
      expect(environment.flutter, isNull);
    });

    test('creates with all fields', () {
      final Pubspec(
        :name,
        :version,
        :description,
        :homepage,
        :repository,
        :issueTracker,
        :documentation,
        :publishTo,
        :funding,
        :topics,
        :environment,
      ) = const Pubspec(
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
      expect(name, equals('my_package'));
      expect(version, equals('1.0.0'));
      expect(description, equals('A test package'));
      expect(homepage, equals('https://example.com'));
      expect(
        repository,
        equals(const Repository('https://github.com/example/my_package')),
      );
      expect(
        issueTracker,
        equals('https://github.com/example/my_package/issues'),
      );
      expect(documentation, equals('https://example.com/docs'));
      expect(publishTo, equals('none'));
      expect(funding, equals(['https://github.com/sponsors/example']));
      expect(topics, equals(['dart', 'test']));
      expect(environment.sdk, equals('^3.10.0'));
      expect(environment.flutter, isNull);
    });
  });

  group('Project', () {
    test('creates with required fields', () {
      const pubspec = Pubspec(
        name: 'test',
        environment: Environment(sdk: 'any'),
      );
      const project = Project(pubspec: pubspec, docs: [], pages: []);
      final Project(pubspec: projectPubspec, :docs, :pages) = project;

      expect(projectPubspec, equals(pubspec));
      expect(docs, isEmpty);
      expect(pages, isEmpty);
    });
  });

  group('Repository', () {
    test('detects GitHub from URL', () {
      final Repository(:link, :label, :icon) = const Repository(
        'https://github.com/user/repo',
      );
      expect(link, equals('https://github.com/user/repo'));
      expect(label, equals('GitHub'));
      expect(icon, isA<Component>());
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
      const repo3 = Repository('https://gitlab.com/user/repo');
      expect(repo1, equals(repo1));
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
      final VersioningConfig(
        :enabled,
        :versions,
        :defaultVersion,
      ) = const VersioningConfig(
        enabled: true,
        versions: ['v1', 'v2'],
        defaultVersion: 'v2',
      );

      expect(enabled, isTrue);
      expect(versions, equals(['v1', 'v2']));
      expect(defaultVersion, equals('v2'));
    });
  });
}
