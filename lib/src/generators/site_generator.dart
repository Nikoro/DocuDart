import 'dart:io';

import 'package:path/path.dart' as p;

import '../cli/errors.dart';
import '../config/config_loader.dart';
import '../config/docudart_config.dart';
import '../models/doc.dart';
import '../models/license.dart';
import '../models/pubspec.dart';
import 'asset_path_generator.dart';
import '../processing/content_processor.dart';
import '../services/package_resolver.dart';
import '../processing/version_manager.dart';
import 'sidebar_generator.dart';
import 'styles_generator.dart';
import 'theme_script_generator.dart';

/// Generates the managed Jaspr site in .dart_tool/docudart.
class SiteGenerator {
  SiteGenerator(this.config, {String? websiteDir, this.serveMode = false})
    : websiteDir = websiteDir ?? Directory.current.path,
      managedDir = p.join(
        websiteDir ?? Directory.current.path,
        '.dart_tool',
        'docudart',
      );
  final Config config;
  final String websiteDir;
  final String managedDir;
  final bool serveMode;

  late final _stylesGenerator = StylesGenerator(config);
  late final _themeScriptGenerator = ThemeScriptGenerator(config, managedDir);

  /// Generate the complete Jaspr site structure.
  ///
  /// When [fullClean] is true (default), deletes and recreates the managed
  /// directory from scratch. Set to false during hot reload to update files
  /// in-place without disrupting the running Jaspr dev server.
  Future<void> generate({
    bool fullClean = true,
    Pubspec? pubspec,
    String? changelog,
    License? license,
  }) async {
    CliPrinter.step('Generating site structure...');

    // Ensure managed directory exists
    final dir = Directory(managedDir);
    if (fullClean && dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);

    // Process documentation content (with versioning support)
    CliPrinter.step('Processing documentation...');
    final versionManager = VersionManager(config);
    final versionedDocsMap = await versionManager.processAllVersions();

    // Collect all pages from all versions
    final allPages = <DocPage>[];
    final sidebarItemsByVersion = <String, List<Doc>>{};

    for (final entry in versionedDocsMap.entries) {
      final version = entry.key;
      final versionedDocs = entry.value;

      allPages.addAll(versionedDocs.pages);

      // Generate sidebar for this version
      sidebarItemsByVersion[version] = SidebarGenerator.generate(
        rootFolder: versionedDocs.rootFolder,
      );
    }

    // Get default version's sidebar for main navigation
    final defaultVersion = versionManager.defaultVersion;
    final defaultSidebarItems =
        sidebarItemsByVersion[defaultVersion] ??
        sidebarItemsByVersion.values.firstOrNull ??
        <Doc>[];

    // Load parent pubspec if not provided
    final resolvedPubspec =
        pubspec ?? await ConfigLoader.loadParentPubspec(websiteDir);

    // Discover custom pages from pages/ directory
    final discoveredPages = await _discoverPages();

    // Generate all required files
    await _generatePubspec();
    await _generateMain();
    await _copyUserFiles();
    await _generatePubspecData(resolvedPubspec);
    await _generateProjectData(
      defaultSidebarItems,
      changelog,
      license,
      discoveredPages,
    );
    await _generateLayout();
    await _generateApp(allPages, versionManager, discoveredPages);
    await _generateStyles(includeVersionSwitcher: versionManager.isEnabled);
    await _generateWebFiles();
    await _copyAssets();

    // Run pub get (skip on incremental regeneration — deps don't change)
    if (fullClean) {
      CliPrinter.step('Installing dependencies...');
      final result = await Process.run('dart', [
        'pub',
        'get',
      ], workingDirectory: managedDir);

      if (result.exitCode != 0) {
        throw Exception('Failed to install dependencies: ${result.stderr}');
      }
    }

    CliPrinter.success('Site structure generated successfully.');
    CliPrinter.info('Processed ${allPages.length} documentation pages.');
    if (versionManager.isEnabled) {
      CliPrinter.info('Versions: ${versionManager.versions.join(", ")}');
    }
  }

  Future<void> _generatePubspec() async {
    final docudartRelPath = await PackageResolver.relativePathTo(managedDir);

    final pubspec =
        '''
name: docudart_site
description: Generated DocuDart site
version: 0.0.1
publish_to: none

environment:
  sdk: ^3.10.0

dependencies:
  jaspr: ^0.22.0
  jaspr_router: ^0.8.0
  docudart:
    path: $docudartRelPath

dev_dependencies:
  build_runner: ^2.4.0
  build_web_compilers: ^4.0.0
  jaspr_builder: ^0.22.0
  jaspr_cli: ^0.22.0

jaspr:
  mode: static
''';
    await File(p.join(managedDir, 'pubspec.yaml')).writeAsString(pubspec);
  }

  Future<void> _copyUserFiles() async {
    final libDir = p.join(managedDir, 'lib');
    await Directory(libDir).create(recursive: true);

    // Copy config.dart (use writeAsString to trigger filesystem events for hot reload)
    final configSrc = File(p.join(websiteDir, 'config.dart'));
    if (configSrc.existsSync()) {
      await File(
        p.join(libDir, 'config.dart'),
      ).writeAsString(await configSrc.readAsString());
    }

    // Copy components/ directory
    await _copyDirectory(
      p.join(websiteDir, 'components'),
      p.join(libDir, 'components'),
    );

    // Copy pages/ directory
    await _copyDirectory(p.join(websiteDir, 'pages'), p.join(libDir, 'pages'));

    // Copy other root-level .dart files (e.g. labels.dart)
    // Use writeAsString instead of copy to trigger filesystem events for hot reload.
    final websiteDirEntity = Directory(websiteDir);
    await for (final entity in websiteDirEntity.list()) {
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          p.basename(entity.path) != 'config.dart') {
        await File(
          p.join(libDir, p.basename(entity.path)),
        ).writeAsString(await entity.readAsString());
      }
    }
  }

  /// Copy a directory recursively, creating target dirs as needed.
  /// Uses writeAsString instead of copy to trigger filesystem events for hot reload.
  Future<void> _copyDirectory(String srcPath, String targetPath) async {
    final srcDir = Directory(srcPath);
    if (!srcDir.existsSync()) return;

    final targetDir = Directory(targetPath);
    await targetDir.create(recursive: true);

    await for (final entity in srcDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: srcPath);
        final dest = p.join(targetPath, relativePath);
        await File(dest).parent.create(recursive: true);
        await File(dest).writeAsString(await entity.readAsString());
      }
    }
  }

  /// Generate pubspec_data.dart with const Pubspec from the parent project.
  Future<void> _generatePubspecData(Pubspec pubspec) async {
    final buffer = StringBuffer();
    buffer.writeln("import 'package:docudart/docudart.dart';");
    buffer.writeln();
    buffer.writeln('/// Auto-generated from the parent project pubspec.yaml.');
    buffer.writeln('const projectPubspec = Pubspec(');
    buffer.writeln("  name: '${_escapeForDart(pubspec.name)}',");
    if (pubspec.version != null) {
      buffer.writeln("  version: '${_escapeForDart(pubspec.version!)}',");
    }
    if (pubspec.description != null) {
      buffer.writeln(
        "  description: '${_escapeForDart(pubspec.description!)}',",
      );
    }
    if (pubspec.homepage != null) {
      buffer.writeln("  homepage: '${_escapeForDart(pubspec.homepage!)}',");
    }
    if (pubspec.repository != null) {
      buffer.writeln(
        "  repository: Repository('${_escapeForDart(pubspec.repository!.link)}'),",
      );
    }
    if (pubspec.issueTracker != null) {
      buffer.writeln(
        "  issueTracker: '${_escapeForDart(pubspec.issueTracker!)}',",
      );
    }
    if (pubspec.documentation != null) {
      buffer.writeln(
        "  documentation: '${_escapeForDart(pubspec.documentation!)}',",
      );
    }
    if (pubspec.publishTo != null) {
      buffer.writeln("  publishTo: '${_escapeForDart(pubspec.publishTo!)}',");
    }
    if (pubspec.funding?.isNotEmpty == true) {
      buffer.writeln(
        "  funding: [${pubspec.funding!.map((f) => "'${_escapeForDart(f)}'").join(', ')}],",
      );
    }
    if (pubspec.topics?.isNotEmpty == true) {
      buffer.writeln(
        "  topics: [${pubspec.topics!.map((t) => "'${_escapeForDart(t)}'").join(', ')}],",
      );
    }
    final env = pubspec.environment;
    buffer.writeln('  environment: Environment(');
    buffer.writeln("    sdk: '${_escapeForDart(env.sdk)}',");
    if (env.flutter != null) {
      buffer.writeln("    flutter: '${_escapeForDart(env.flutter!)}',");
    }
    buffer.writeln('  ),');
    buffer.writeln(');');

    await File(
      p.join(managedDir, 'lib', 'pubspec_data.dart'),
    ).writeAsString(buffer.toString());
  }

  /// Generate project_data.dart with sidebar items and discovered pages.
  Future<void> _generateProjectData(
    List<Doc> sidebarItems,
    String? changelog,
    License? license,
    List<_DiscoveredPage> discoveredPages,
  ) async {
    // Generate asset tree classes.
    final assetCode = AssetPathGenerator.generateProjectAssets(
      config.assetsDir,
    );

    final buffer = StringBuffer();
    buffer.writeln("import 'package:docudart/docudart.dart';");
    buffer.writeln("import 'pubspec_data.dart';");
    buffer.writeln();
    buffer.writeln('// ignore_for_file: non_constant_identifier_names');
    buffer.writeln();

    // Embed asset tree classes before the project constant.
    buffer.write(assetCode);

    buffer.writeln('/// Auto-generated project data.');
    buffer.writeln('final project = Project(');
    buffer.writeln('  pubspec: projectPubspec,');
    buffer.writeln('  assets: _ProjectAssets(),');
    buffer.writeln('  docs: [');

    for (final item in sidebarItems) {
      _writeDocCode(buffer, item, '    ');
    }

    buffer.writeln('  ],');
    buffer.writeln('  pages: [');

    for (final page in discoveredPages) {
      buffer.writeln(
        "    Page(path: '${_escapeForDart(page.routePath)}', name: '${_escapeForDart(page.name)}'),",
      );
    }

    buffer.writeln('  ],');

    if (license != null) {
      buffer.write('  license: License(type: LicenseType.${license.type.name}');
      if (license.year != null) {
        buffer.write(", year: '${_escapeForDart(license.year!)}'");
      }
      if (license.holder != null) {
        buffer.write(", holder: '${_escapeForDart(license.holder!)}'");
      }
      buffer.writeln('),');
    }

    if (changelog != null) {
      buffer.writeln("  changelog: '${_escapeForDart(changelog)}',");
    }

    buffer.writeln(');');

    await File(
      p.join(managedDir, 'lib', 'project_data.dart'),
    ).writeAsString(buffer.toString());
  }

  void _writeDocCode(StringBuffer buffer, Doc item, String indent) {
    switch (item) {
      case DocLink(:final name, :final path, :final order):
        buffer.writeln(
          "${indent}DocLink(name: '${_escapeForDart(name)}', path: '$path', order: $order),",
        );
      case DocCategory(
        :final name,
        :final children,
        :final expanded,
        :final order,
      ):
        buffer.writeln('${indent}DocCategory(');
        buffer.writeln("$indent  name: '${_escapeForDart(name)}',");
        if (expanded) buffer.writeln('$indent  expanded: true,');
        buffer.writeln('$indent  order: $order,');
        buffer.writeln('$indent  children: [');
        for (final child in children) {
          _writeDocCode(buffer, child, '$indent    ');
        }
        buffer.writeln('$indent  ],');
        buffer.writeln('$indent),');
    }
  }

  /// Generate layout.dart that delegates to config functions.
  Future<void> _generateLayout() async {
    final layout = '''
import 'package:jaspr/jaspr.dart';
import 'package:docudart/docudart.dart';
import 'config.dart';

class LayoutDelegate extends StatelessComponent {
  const LayoutDelegate({required this.child, super.key});

  final Component child;

  @override
  Component build(BuildContext context) {
    final config = configure(context);
    final headerComponent = config.header?.call();
    final sidebarComponent = config.sidebar?.call();
    final footerComponent = config.footer?.call();

    return config.layoutBuilder.let((builder) => builder(
      header: headerComponent,
      sidebar: sidebarComponent,
      body: child,
      footer: footerComponent,
    )) ?? Layout(
      header: headerComponent,
      sidebar: sidebarComponent,
      body: child,
      footer: footerComponent,
    );
  }
}
''';
    await File(p.join(managedDir, 'lib', 'layout.dart')).writeAsString(layout);
  }

  Future<void> _generateMain() async {
    final title = config.title ?? 'Documentation';
    final description = config.description ?? '';

    await Directory(p.join(managedDir, 'lib')).create(recursive: true);

    // Check for favicon files in assets/favicon/
    final faviconLinks = _buildFaviconLinks();

    // Server entry point (lib/main.server.dart)
    final serverMain =
        '''
import 'package:jaspr/server.dart';
import 'package:jaspr/dom.dart' show link, script;
import 'main.server.options.dart';
import 'app.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  runApp(Document(
    title: '$title',
    meta: {
      'description': '$description',
      'viewport': 'width=device-width, initial-scale=1',
    },
    head: [
$faviconLinks      link(rel: 'stylesheet', href: '/styles.css'),
${_fontImportLink()}      script(src: '/theme.js'),
      script(src: 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js', defer: true),
      script(src: 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/dart.min.js', defer: true),
${serveMode ? "      script(src: '/live-reload.js', defer: true),\n" : ''}    ],
    body: DocuDartApp(),
  ));
}
''';
    await File(
      p.join(managedDir, 'lib', 'main.server.dart'),
    ).writeAsString(serverMain);

    // Client entry point (lib/main.client.dart)
    final clientMain = '''
library;

import 'package:jaspr/client.dart';
import 'main.client.options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultClientOptions,
  );

  runApp(const ClientApp());
}
''';
    await File(
      p.join(managedDir, 'lib', 'main.client.dart'),
    ).writeAsString(clientMain);

    // Server options placeholder (lib/main.server.options.dart)
    final serverOptions = '''
// ignore_for_file: type=lint
import 'package:jaspr/server.dart';

ServerOptions get defaultServerOptions => ServerOptions();
''';
    await File(
      p.join(managedDir, 'lib', 'main.server.options.dart'),
    ).writeAsString(serverOptions);

    // Client options placeholder (lib/main.client.options.dart)
    final clientOptions = '''
// ignore_for_file: type=lint
import 'package:jaspr/client.dart';

ClientOptions get defaultClientOptions => ClientOptions();
''';
    await File(
      p.join(managedDir, 'lib', 'main.client.options.dart'),
    ).writeAsString(clientOptions);
  }

  /// Discover page components from the pages/ directory.
  ///
  /// Recursively scans .dart files for a class extending StatelessComponent or
  /// StatefulComponent, extracts the class name, and derives a URL path
  /// from the filename (e.g., `changelog_page.dart` → `/changelog`).
  /// Supports subdirectories (e.g., `pages/foo/bar_page.dart` → `/foo/bar`).
  Future<List<_DiscoveredPage>> _discoverPages() async {
    final pagesDir = Directory(p.join(websiteDir, 'pages'));
    if (!pagesDir.existsSync()) return [];

    final discovered = <_DiscoveredPage>[];
    final classPattern = RegExp(
      r'class\s+(\w+)\s+extends\s+(?:Stateless|Stateful)Component',
    );

    await for (final entity in pagesDir.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final content = await entity.readAsString();
      final match = classPattern.firstMatch(content);
      if (match == null) continue;

      final className = match.group(1)!;

      // Compute relative path from pages/ directory
      final relativePath = p.relative(entity.path, from: pagesDir.path);
      final relativeWithoutExt = p.withoutExtension(relativePath);

      // Split into path segments and normalize
      final parts = p.split(relativeWithoutExt);

      // Strip _page suffix from the filename (last segment)
      var filename = parts.last;
      if (filename.endsWith('_page')) {
        filename = filename.substring(0, filename.length - '_page'.length);
      }
      parts[parts.length - 1] = filename;

      // Replace underscores with hyphens in all segments
      final normalizedParts = parts
          .map((part) => part.replaceAll('_', '-'))
          .toList();
      final routePath = '/${normalizedParts.join('/')}';

      // Derive display name from the leaf segment
      final name = _titleCase(normalizedParts.last.replaceAll('-', ' '));

      discovered.add(
        _DiscoveredPage(
          className: className,
          filePath: 'pages/$relativePath',
          routePath: routePath,
          name: name,
        ),
      );
    }

    // Sort for deterministic output
    discovered.sort((a, b) => a.routePath.compareTo(b.routePath));

    return discovered;
  }

  static String _titleCase(String input) => input
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .join(' ');

  Future<void> _generateApp(
    List<DocPage> pages,
    VersionManager versionManager,
    List<_DiscoveredPage> discoveredPages,
  ) async {
    // Generate routes for all pages
    final routesBuffer = StringBuffer();

    // Home route: if config.home is set and returns non-null, render it; otherwise redirect to /docs
    routesBuffer.writeln('''
        if (configure(context).home?.call() case final homeComponent?)
          Route(
            path: '/',
            builder: (context, state) => LayoutDelegate(
              child: homeComponent,
            ),
          )
        else
          Route(
            path: '/',
            redirect: (_, _) => '/docs',
          ),''');

    // Generate a route for each doc page
    for (final page in pages) {
      final escapedHtml = _escapeForDart(page.html);
      final escapedTitle = _escapeForDart(page.title);

      routesBuffer.writeln('''
        Route(
          path: '${page.urlPath}',
          builder: (context, state) => const LayoutDelegate(
            child: DocsPageContent(
              title: '$escapedTitle',
              htmlContent: \'\'\'$escapedHtml\'\'\',
            ),
          ),
        ),''');
    }

    // Generate routes for discovered custom pages
    for (final page in discoveredPages) {
      routesBuffer.writeln('''
        Route(
          path: '${page.routePath}',
          builder: (context, state) => LayoutDelegate(
            child: const ${page.className}(),
          ),
        ),''');
    }

    // Generate imports for discovered pages
    final pageImports = StringBuffer();
    for (final page in discoveredPages) {
      pageImports.writeln("import '${page.filePath}';");
    }

    final app =
        '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:docudart/docudart.dart';
import 'config.dart';
import 'project_data.dart';
import 'layout.dart';
import 'docs_page_content.dart';
${pageImports.toString()}
class DocuDartApp extends StatelessComponent {
  const DocuDartApp({super.key});

  @override
  Component build(BuildContext context) {
    return ProjectProvider(
      project: project,
      child: Builder(builder: (context) => Router(
        routes: [
${routesBuffer.toString()}
        ],
      )),
    );
  }
}
''';
    await File(p.join(managedDir, 'lib', 'app.dart')).writeAsString(app);

    // Generate pages
    await _generatePages();

    // Generate docs page content component
    await _generateDocsPageContent();

    // Generate version switcher if needed
    if (versionManager.isEnabled) {
      final componentsDir = p.join(managedDir, 'lib', 'components');
      await Directory(componentsDir).create(recursive: true);
      await _generateVersionSwitcher(componentsDir, versionManager);
    }
  }

  Future<void> _generatePages() async {
    final pagesDir = p.join(managedDir, 'lib', 'pages');
    await Directory(pagesDir).create(recursive: true);
    // User pages (landing_page.dart, etc.) are copied by _copyUserFiles()
  }

  Future<void> _generateDocsPageContent() async {
    final docsPageContent = '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class DocsPageContent extends StatelessComponent {
  final String title;
  final String htmlContent;

  const DocsPageContent({
    required this.title,
    required this.htmlContent,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return article(
      classes: 'docs-page',
      [
        div(
          classes: 'docs-content',
          [
            RawText(htmlContent),
          ],
        ),
      ],
    );
  }
}
''';
    await File(
      p.join(managedDir, 'lib', 'docs_page_content.dart'),
    ).writeAsString(docsPageContent);
  }

  String _escapeForDart(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\$', '\\\$')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t')
        .replaceAll('\x00', '\\x00');
  }

  Future<void> _generateStyles({bool includeVersionSwitcher = false}) async {
    final webDir = p.join(managedDir, 'web');
    await _stylesGenerator.generate(
      webDir,
      includeVersionSwitcher: includeVersionSwitcher,
    );

    // Always generate theme toggle script
    await _themeScriptGenerator.generateThemeScript(webDir);

    // Generate live-reload script during serve mode
    if (serveMode) {
      await _themeScriptGenerator.generateLiveReload(webDir);
    }
  }

  /// Writes a new version timestamp to the live-reload version file.
  /// Called after each regeneration during serve mode.
  Future<void> bumpLiveReloadVersion() =>
      _themeScriptGenerator.bumpLiveReloadVersion();

  Future<void> _generateWebFiles() async {
    // No custom index.html needed — Jaspr generates it from the Document
    // component in main.server.dart. Only web/styles.css is needed, which
    // is already handled by _generateStyles().
  }

  static const _faviconFiles = {
    'favicon.ico',
    'favicon-16x16.png',
    'favicon-32x32.png',
    'apple-touch-icon.png',
    'android-chrome-192x192.png',
    'android-chrome-512x512.png',
  };

  bool _hasFavicon(String fileName) {
    final faviconDir = Directory(p.join(config.assetsDir, 'favicon'));
    if (!faviconDir.existsSync()) return false;
    return File(p.join(faviconDir.path, fileName)).existsSync();
  }

  String _buildFaviconLinks() {
    final buffer = StringBuffer();
    if (_hasFavicon('favicon.ico')) {
      buffer.writeln("      link(rel: 'icon', href: '/favicon.ico'),");
    }
    if (_hasFavicon('favicon-32x32.png')) {
      buffer.writeln(
        "      link(rel: 'icon', type: 'image/png', href: '/favicon-32x32.png', attributes: {'sizes': '32x32'}),",
      );
    }
    if (_hasFavicon('favicon-16x16.png')) {
      buffer.writeln(
        "      link(rel: 'icon', type: 'image/png', href: '/favicon-16x16.png', attributes: {'sizes': '16x16'}),",
      );
    }
    if (_hasFavicon('apple-touch-icon.png')) {
      buffer.writeln(
        "      link(rel: 'apple-touch-icon', href: '/apple-touch-icon.png', attributes: {'sizes': '180x180'}),",
      );
    }
    return buffer.toString();
  }

  String _fontImportLink() {
    final url = config.theme.textTheme.fontImportUrl;
    if (url == null) return '';
    return "      link(\n        rel: 'stylesheet',\n        href: '$url',\n      ),\n";
  }

  Future<void> _copyAssets() async {
    final sourceDir = Directory(config.assetsDir);
    if (!sourceDir.existsSync()) return;

    final targetDir = Directory(p.join(managedDir, 'web', 'assets'));
    await targetDir.create(recursive: true);

    await for (final entity in sourceDir.list(recursive: true)) {
      if (entity is File) {
        // Skip generated .dart files (e.g. assets.dart) — they are not web assets.
        if (entity.path.endsWith('.dart')) continue;

        final relativePath = p.relative(entity.path, from: sourceDir.path);

        // Copy favicon files to web root for browser discovery
        if (relativePath.startsWith('favicon${p.separator}') ||
            relativePath.startsWith('favicon/')) {
          final fileName = p.basename(entity.path);
          if (_faviconFiles.contains(fileName)) {
            final targetPath = p.join(managedDir, 'web', fileName);
            await entity.copy(targetPath);
            continue;
          }
        }

        final targetPath = p.join(targetDir.path, relativePath);
        await File(targetPath).parent.create(recursive: true);
        await entity.copy(targetPath);
      }
    }
  }

  Future<void> _generateVersionSwitcher(
    String componentsDir,
    VersionManager versionManager,
  ) async {
    final versions = versionManager.versions;
    final defaultVersion = versionManager.defaultVersion;

    // Generate version data
    final versionDataBuffer = StringBuffer();
    versionDataBuffer.writeln('const versionData = <VersionData>[');
    for (final version in versions) {
      final isDefault = version == defaultVersion;
      final isLatest = version == versionManager.latestVersion;
      final label = _escapeForDart(version);
      final badgeList = <String>[];
      if (isLatest) badgeList.add('latest');
      if (isDefault && !isLatest) badgeList.add('default');
      final badge = badgeList.isEmpty ? '' : ' (${badgeList.join(', ')})';

      versionDataBuffer.writeln("  VersionData(");
      versionDataBuffer.writeln("    id: '$label',");
      versionDataBuffer.writeln("    label: '$label$badge',");
      versionDataBuffer.writeln(
        "    urlPrefix: ${isDefault ? "'/docs'" : "'/$label/docs'"},",
      );
      versionDataBuffer.writeln("    isDefault: $isDefault,");
      versionDataBuffer.writeln("    isLatest: $isLatest,");
      versionDataBuffer.writeln("  ),");
    }
    versionDataBuffer.writeln('];');

    final versionSwitcher =
        '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class VersionData {
  final String id;
  final String label;
  final String urlPrefix;
  final bool isDefault;
  final bool isLatest;

  const VersionData({
    required this.id,
    required this.label,
    required this.urlPrefix,
    this.isDefault = false,
    this.isLatest = false,
  });
}

${versionDataBuffer.toString()}

class VersionSwitcher extends StatelessComponent {
  const VersionSwitcher({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'version-switcher',
      [
        select(
          classes: 'version-select',
          events: {
            'change': (event) {
              // JavaScript will handle the navigation
            },
          },
          [
            for (final version in versionData)
              option(
                value: version.urlPrefix,
                attributes: version.isDefault ? {'selected': 'selected'} : {},
                [.text(version.label)],
              ),
          ],
        ),
      ],
    );
  }
}
''';

    await File(
      p.join(componentsDir, 'version_switcher.dart'),
    ).writeAsString(versionSwitcher);
  }
}

/// A page component discovered from the pages/ directory.
class _DiscoveredPage {
  const _DiscoveredPage({
    required this.className,
    required this.filePath,
    required this.routePath,
    required this.name,
  });

  /// The Dart class name (e.g., `ChangelogPage`).
  final String className;

  /// Relative file path from website root (e.g., `pages/changelog_page.dart`).
  final String filePath;

  /// URL route path (e.g., `/changelog`).
  final String routePath;

  /// Human-readable display name (e.g., `Changelog`).
  final String name;
}
