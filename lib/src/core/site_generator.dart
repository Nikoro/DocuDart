import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/config_loader.dart';
import '../config/docudart_config.dart';
import '../config/pubspec.dart';
import 'asset_path_generator.dart';
import 'content_processor.dart';
import 'package_resolver.dart';
import 'version_manager.dart';
import '../routing/sidebar_generator.dart';

/// Generates the managed Jaspr site in .dart_tool/docudart.
class SiteGenerator {
  final Config config;
  final String websiteDir;
  final String managedDir;
  final bool serveMode;

  SiteGenerator(this.config, {String? websiteDir, this.serveMode = false})
    : websiteDir = websiteDir ?? Directory.current.path,
      managedDir = p.join(
        websiteDir ?? Directory.current.path,
        '.dart_tool',
        'docudart',
      );

  /// Generate the complete Jaspr site structure.
  ///
  /// When [fullClean] is true (default), deletes and recreates the managed
  /// directory from scratch. Set to false during hot reload to update files
  /// in-place without disrupting the running Jaspr dev server.
  Future<void> generate({bool fullClean = true, Pubspec? pubspec}) async {
    print('Generating site structure...');

    // Ensure managed directory exists
    final dir = Directory(managedDir);
    if (fullClean && dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);

    // Process documentation content (with versioning support)
    print('Processing documentation...');
    final versionManager = VersionManager(config);
    final versionedDocsMap = await versionManager.processAllVersions();

    // Collect all pages from all versions
    final allPages = <DocPage>[];
    final sidebarItemsByVersion = <String, List<GeneratedSidebarItem>>{};

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
        <GeneratedSidebarItem>[];

    // Load parent pubspec if not provided
    final resolvedPubspec =
        pubspec ?? await ConfigLoader.loadParentPubspec(websiteDir);

    // Generate all required files
    await _generatePubspec();
    await _generateMain();
    await _generateAssetPaths();
    await _copyUserFiles();
    await _generatePubspecData(resolvedPubspec);
    await _generateProjectData(defaultSidebarItems);
    await _generateLayout();
    await _generateApp(allPages, versionManager);
    await _generateStyles(includeVersionSwitcher: versionManager.isEnabled);
    await _generateWebFiles();
    await _copyAssets();

    // Run pub get (skip on incremental regeneration — deps don't change)
    if (fullClean) {
      print('Installing dependencies...');
      final result = await Process.run('dart', [
        'pub',
        'get',
      ], workingDirectory: managedDir);

      if (result.exitCode != 0) {
        throw Exception('Failed to install dependencies: ${result.stderr}');
      }
    }

    print('Site structure generated successfully.');
    print('Processed ${allPages.length} documentation pages.');
    if (versionManager.isEnabled) {
      print('Versions: ${versionManager.versions.join(", ")}');
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
  jaspr_builder: ^0.22.0
  jaspr_cli: ^0.22.0

jaspr:
  mode: static
''';
    await File(p.join(managedDir, 'pubspec.yaml')).writeAsString(pubspec);
  }

  /// Copy user's config.dart and components/ into managed project's lib/.
  /// Generate `assets/assets.dart` with type-safe asset path constants.
  Future<void> _generateAssetPaths() async {
    final content = AssetPathGenerator.generate(config.assetsDir);
    final targetFile = File(p.join(config.assetsDir, 'assets.dart'));
    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsString(content);
  }

  Future<void> _copyUserFiles() async {
    final libDir = p.join(managedDir, 'lib');
    await Directory(libDir).create(recursive: true);

    // Copy config.dart (use writeAsString to trigger filesystem events for hot reload)
    final configSrc = File(p.join(websiteDir, 'config.dart'));
    if (configSrc.existsSync()) {
      await File(p.join(libDir, 'config.dart'))
          .writeAsString(await configSrc.readAsString());
    }

    // Copy components/ directory
    await _copyDirectory(
      p.join(websiteDir, 'components'),
      p.join(libDir, 'components'),
    );

    // Copy pages/ directory
    await _copyDirectory(p.join(websiteDir, 'pages'), p.join(libDir, 'pages'));

    // Copy other root-level .dart files (e.g. icons.dart)
    // Use writeAsString instead of copy to trigger filesystem events for hot reload.
    final websiteDirEntity = Directory(websiteDir);
    await for (final entity in websiteDirEntity.list()) {
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          p.basename(entity.path) != 'config.dart') {
        await File(p.join(libDir, p.basename(entity.path)))
            .writeAsString(await entity.readAsString());
      }
    }

    // Copy assets/assets.dart (auto-generated type-safe asset paths)
    final assetsDataSrc = File(p.join(config.assetsDir, 'assets.dart'));
    if (assetsDataSrc.existsSync()) {
      final assetsLibDir = p.join(libDir, 'assets');
      await Directory(assetsLibDir).create(recursive: true);
      await File(p.join(assetsLibDir, 'assets.dart'))
          .writeAsString(await assetsDataSrc.readAsString());
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
    if (pubspec.funding.isNotEmpty) {
      buffer.writeln(
        "  funding: [${pubspec.funding.map((f) => "'${_escapeForDart(f)}'").join(', ')}],",
      );
    }
    if (pubspec.topics.isNotEmpty) {
      buffer.writeln(
        "  topics: [${pubspec.topics.map((t) => "'${_escapeForDart(t)}'").join(', ')}],",
      );
    }
    if (pubspec.environment.isNotEmpty) {
      buffer.writeln('  environment: {');
      for (final entry in pubspec.environment.entries) {
        buffer.writeln(
          "    '${_escapeForDart(entry.key)}': '${_escapeForDart(entry.value)}',",
        );
      }
      buffer.writeln('  },');
    }
    buffer.writeln(');');

    await File(
      p.join(managedDir, 'lib', 'pubspec_data.dart'),
    ).writeAsString(buffer.toString());
  }

  /// Generate project_data.dart with sidebar items and custom pages.
  Future<void> _generateProjectData(
    List<GeneratedSidebarItem> sidebarItems,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln("import 'package:docudart/docudart.dart';");
    buffer.writeln("import 'pubspec_data.dart';");
    buffer.writeln();
    buffer.writeln('/// Auto-generated project data.');
    buffer.writeln('const project = Project(');
    buffer.writeln('  pubspec: projectPubspec,');
    buffer.writeln('  docs: [');

    for (final item in sidebarItems) {
      _writeSidebarItemCode(buffer, item, '    ');
    }

    buffer.writeln('  ],');
    buffer.writeln('  pages: [');

    for (final page in config.customPages) {
      buffer.writeln(
        "    CustomPage(path: '${_escapeForDart(page.path)}', filePath: '${_escapeForDart(page.filePath)}'),",
      );
    }

    buffer.writeln('  ],');
    buffer.writeln(');');

    await File(
      p.join(managedDir, 'lib', 'project_data.dart'),
    ).writeAsString(buffer.toString());
  }

  void _writeSidebarItemCode(
    StringBuffer buffer,
    GeneratedSidebarItem item,
    String indent,
  ) {
    buffer.writeln('${indent}GeneratedSidebarItem(');
    buffer.writeln("$indent  title: '${_escapeForDart(item.title)}',");

    if (item.path != null) {
      buffer.writeln("$indent  path: '${item.path}',");
    }

    buffer.writeln('$indent  isCategory: ${item.isCategory},');

    if (item.collapsed) {
      buffer.writeln('$indent  collapsed: ${item.collapsed},');
    }

    if (item.depth != 0) {
      buffer.writeln('$indent  depth: ${item.depth},');
    }

    if (item.children.isNotEmpty) {
      buffer.writeln('$indent  children: [');
      for (final child in item.children) {
        _writeSidebarItemCode(buffer, child, '$indent    ');
      }
      buffer.writeln('$indent  ],');
    }

    buffer.writeln('$indent),');
  }

  /// Generate layout.dart that delegates to config functions.
  Future<void> _generateLayout() async {
    final layout = '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:docudart/docudart.dart';
import 'config.dart';
import 'project_data.dart';

class Layout extends StatelessComponent {
  final Component child;
  final bool showSidebar;

  const Layout({
    required this.child,
    this.showSidebar = true,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    final config = configure(project);
    final headerComponent = config.header?.call();
    final sidebarComponent = showSidebar ? config.sidebar?.call() : null;
    final footerComponent = config.footer?.call();

    return div(
      classes: 'layout',
      [
        if (headerComponent != null) headerComponent,
        div(
          classes: sidebarComponent != null ? 'site-body' : 'site-body no-sidebar',
          [
            if (sidebarComponent != null) sidebarComponent,
            div(
              classes: 'site-main',
              attributes: {'role': 'main'},
              [child],
            ),
          ],
        ),
        if (footerComponent != null) footerComponent,
      ],
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
import 'app.dart';

void main() {
  Jaspr.initializeApp();

  runApp(Document(
    title: '$title',
    meta: {
      'description': '$description',
      'viewport': 'width=device-width, initial-scale=1',
    },
    head: [
$faviconLinks      link(rel: 'stylesheet', href: '/styles.css'),
      link(
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono&display=swap',
      ),
      script(src: 'main.client.dart.js', defer: true),
      script(src: '/theme.js'),
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

  Future<void> _generateApp(
    List<DocPage> pages,
    VersionManager versionManager,
  ) async {
    // Generate routes for all pages
    final routesBuffer = StringBuffer();

    // Home route: if config.home is set and returns non-null, render it; otherwise redirect to /docs
    routesBuffer.writeln('''
        if (configure(project).home?.call() case final homeComponent?)
          Route(
            path: '/',
            builder: (context, state) => Layout(
              showSidebar: false,
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
          builder: (context, state) => const Layout(
            child: DocsPageContent(
              title: '$escapedTitle',
              htmlContent: \'\'\'$escapedHtml\'\'\',
            ),
          ),
        ),''');
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

class DocuDartApp extends StatelessComponent {
  const DocuDartApp({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
${routesBuffer.toString()}
      ],
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
        .replaceAll('\n', '\\n');
  }

  Future<void> _generateStyles({bool includeVersionSwitcher = false}) async {
    final colors = config.theme.colors;
    final typography = config.theme.typography;

    // Convert colors to hex
    String toHex(int color) =>
        '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

    final styles =
        '''
/* DocuDart Generated Styles */

:root {
  /* Colors - Light Mode */
  --color-primary: ${toHex(colors.primary)};
  --color-secondary: ${toHex(colors.secondary)};
  --color-background: ${toHex(colors.background)};
  --color-surface: ${toHex(colors.surface)};
  --color-text: ${toHex(colors.text)};
  --color-text-muted: ${toHex(colors.textMuted)};
  --color-border: ${toHex(colors.border)};
  --color-code-background: ${toHex(colors.codeBackground)};

  /* Typography */
  --font-family: ${typography.fontFamily};
  --font-family-mono: ${typography.monoFontFamily};
  --font-size-base: ${typography.baseFontSize}px;
  --line-height: ${typography.lineHeight};
}

/* Dark mode via system preference */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --color-primary: ${toHex(colors.darkPrimary)};
    --color-secondary: ${toHex(colors.darkSecondary)};
    --color-background: ${toHex(colors.darkBackground)};
    --color-surface: ${toHex(colors.darkSurface)};
    --color-text: ${toHex(colors.darkText)};
    --color-text-muted: ${toHex(colors.darkTextMuted)};
    --color-border: ${toHex(colors.darkBorder)};
    --color-code-background: ${toHex(colors.darkCodeBackground)};
  }
}

/* Dark mode via toggle */
:root[data-theme="dark"] {
  --color-primary: ${toHex(colors.darkPrimary)};
  --color-secondary: ${toHex(colors.darkSecondary)};
  --color-background: ${toHex(colors.darkBackground)};
  --color-surface: ${toHex(colors.darkSurface)};
  --color-text: ${toHex(colors.darkText)};
  --color-text-muted: ${toHex(colors.darkTextMuted)};
  --color-border: ${toHex(colors.darkBorder)};
  --color-code-background: ${toHex(colors.darkCodeBackground)};
}

/* Reset */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* Base */
html {
  font-size: var(--font-size-base);
  line-height: var(--line-height);
}

body {
  font-family: var(--font-family);
  background-color: var(--color-background);
  color: var(--color-text);
  min-height: 100vh;
}

/* Layout */
.layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.site-body {
  display: flex;
  flex: 1;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
}

/* Header */
.site-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1400px;
  margin: 0 auto;
  padding: 1rem 2rem;
}

.logo,
.logo:visited {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: var(--color-text);
  line-height: 1;
}

.logo:hover,
.logo:visited:hover {
  color: var(--color-primary);
  text-decoration: none;
}

.logo-image {
  display: inline-flex;
  align-items: center;
  flex-shrink: 0;
}

.logo-image img {
  height: 1.75rem;
  width: auto;
  display: block;
}

.logo-title {
  font-size: 1.25rem;
  font-weight: 600;
  white-space: nowrap;
}

.header-nav {
  display: flex;
  gap: 1.5rem;
  align-items: center;
}

.header-nav a {
  color: var(--color-text-muted);
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s;
}

.header-nav a:hover,
.header-nav a.active {
  color: var(--color-primary);
}

.nav-link {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
}

.nav-link-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.25em;
  height: 1.25em;
  line-height: 0;
  flex-shrink: 0;
}

.nav-link-icon svg {
  width: 100%;
  height: 100%;
  fill: currentColor;
}

/* Sidebar */
.sidebar {
  width: 280px;
  flex-shrink: 0;
  padding: 2rem 1rem;
  border-right: 1px solid var(--color-border);
  background-color: var(--color-surface);
  height: calc(100vh - 65px);
  position: sticky;
  top: 65px;
  overflow-y: auto;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sidebar-items {
  list-style: none;
  padding: 0;
  margin: 0;
}

.sidebar-category {
  margin-bottom: 0.5rem;
}

.sidebar-category-title {
  display: flex;
  align-items: center;
  cursor: pointer;
  user-select: none;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-muted);
  margin-bottom: 0.25rem;
  padding: 0.375rem 0.75rem;
  border-radius: 0.375rem;
  transition: color 0.15s;
}

.sidebar-category-title:hover {
  color: var(--color-text);
}

.sidebar-category-title::before {
  content: '';
  display: inline-block;
  width: 0;
  height: 0;
  border-left: 5px solid currentColor;
  border-top: 4px solid transparent;
  border-bottom: 4px solid transparent;
  margin-right: 0.5rem;
  flex-shrink: 0;
  transition: transform 0.2s ease;
}

.sidebar-category[data-collapsed="false"] > .sidebar-category-title::before {
  transform: rotate(90deg);
}

.sidebar-category-items {
  list-style: none;
  padding: 0 0 0 0.75rem;
  margin: 0;
  overflow: hidden;
  max-height: 2000px;
  opacity: 1;
  transition: max-height 0.3s ease, opacity 0.2s ease;
}

.sidebar-category[data-collapsed="true"] > .sidebar-category-items {
  max-height: 0;
  opacity: 0;
}

.sidebar-category-items li {
  margin: 0;
}

.sidebar-link {
  display: block;
  padding: 0.5rem 0.75rem;
  color: var(--color-text);
  text-decoration: none;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  transition: all 0.15s;
}

.sidebar-link:hover {
  background-color: var(--color-background);
  color: var(--color-primary);
}

.sidebar-link.active {
  background-color: var(--color-primary);
  color: white;
}

/* No sidebar layout (landing page) */
.site-body.no-sidebar {
  max-width: 100%;
  justify-content: center;
  align-items: center;
}

.site-body.no-sidebar .site-main {
  max-width: 100%;
  padding: 0;
}

/* Main */
.site-main {
  flex: 1;
  padding: 2rem 3rem;
  max-width: 900px;
}

/* Footer */
.site-footer {
  background-color: var(--color-surface);
  border-top: 1px solid var(--color-border);
  padding: 2rem;
}

.footer-content {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: var(--color-text-muted);
}

.footer-leading,
.footer-trailing {
  flex: 1;
  display: flex;
  align-items: center;
}

.footer-leading {
  justify-content: flex-start;
}

.footer-trailing {
  justify-content: flex-end;
}

.footer-center {
  text-align: center;
}

.built-with {
  font-size: 0.85rem;
  margin-top: 0.5rem;
  opacity: 0.8;
}

.built-with a {
  color: var(--color-primary);
  text-decoration: none;
  font-weight: 500;
}

.built-with a:hover {
  text-decoration: underline;
}

/* Socials */
.socials {
  display: flex;
  gap: 0.75rem;
}

.social-link {
  display: inline-flex;
  align-items: center;
  color: var(--color-text-muted);
  transition: color 0.2s;
}

.social-link:hover {
  color: var(--color-primary);
}

.social-link-icon {
  display: inline-flex;
  align-items: center;
  width: 1.5em;
  height: 1.5em;
}

.social-link-icon svg {
  width: 100%;
  height: 100%;
  fill: currentColor;
}

/* Topics */
.topics {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.topics-title {
  font-size: 0.7rem;
  font-weight: 500;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  opacity: 0.7;
}

.topics-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
}

.topic-link {
  display: inline-flex;
  align-items: center;
  padding: 0.2rem 0.55rem;
  border-radius: 1rem;
  font-size: 0.72rem;
  color: var(--color-text-muted);
  border: 1px solid var(--color-border, rgba(128, 128, 128, 0.25));
  transition: color 0.2s, border-color 0.2s;
  text-decoration: none;
  white-space: nowrap;
}

.topic-link:hover {
  color: var(--color-primary);
  border-color: var(--color-primary);
}

/* Hero */
.home-page {
  max-width: 800px;
  margin: 0 auto;
}

.hero {
  text-align: center;
  padding: 4rem 2rem;
}

.hero h1 {
  font-size: 3rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: var(--color-text);
}

.hero-description {
  font-size: 1.25rem;
  color: var(--color-text-muted);
  margin-bottom: 2rem;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.hero-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
}

/* Buttons */
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  font-weight: 500;
  border-radius: 0.5rem;
  text-decoration: none;
  transition: all 0.2s;
  cursor: pointer;
  border: none;
}

.button-primary {
  background-color: var(--color-primary);
  color: white;
}

.button-primary:hover {
  filter: brightness(1.1);
}

/* Docs Content */
.docs-page {
  width: 100%;
}

.docs-content {
  max-width: 100%;
}

.docs-content h1 {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid var(--color-border);
}

.docs-content h2 {
  font-size: 1.75rem;
  font-weight: 600;
  margin-top: 2.5rem;
  margin-bottom: 1rem;
}

.docs-content h3 {
  font-size: 1.25rem;
  font-weight: 600;
  margin-top: 2rem;
  margin-bottom: 0.75rem;
}

.docs-content h4 {
  font-size: 1rem;
  font-weight: 600;
  margin-top: 1.5rem;
  margin-bottom: 0.5rem;
}

.docs-content p {
  margin-bottom: 1rem;
}

.docs-content ul, .docs-content ol {
  margin-bottom: 1rem;
  padding-left: 1.5rem;
}

.docs-content li {
  margin-bottom: 0.5rem;
}

.docs-content a {
  color: var(--color-primary);
  text-decoration: none;
}

.docs-content a:hover {
  text-decoration: underline;
}

.docs-content code {
  font-family: var(--font-family-mono);
  font-size: 0.875em;
  background-color: var(--color-code-background);
  padding: 0.2em 0.4em;
  border-radius: 0.25rem;
}

.docs-content pre {
  background-color: var(--color-code-background);
  padding: 1rem;
  border-radius: 0.5rem;
  overflow-x: auto;
  margin-bottom: 1rem;
}

.docs-content pre code {
  background: none;
  padding: 0;
  font-size: 0.875rem;
}

.docs-content blockquote {
  border-left: 4px solid var(--color-primary);
  padding-left: 1rem;
  margin: 1rem 0;
  color: var(--color-text-muted);
}

.docs-content table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}

.docs-content th, .docs-content td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid var(--color-border);
}

.docs-content th {
  font-weight: 600;
  background-color: var(--color-surface);
}

.docs-content img {
  max-width: 100%;
  height: auto;
  border-radius: 0.5rem;
}

.docs-content hr {
  border: none;
  border-top: 1px solid var(--color-border);
  margin: 2rem 0;
}

/* Responsive */
@media (max-width: 1024px) {
  .sidebar {
    display: none;
  }

  .site-main {
    padding: 1.5rem;
  }
}

@media (max-width: 768px) {
  .header-content {
    padding: 1rem;
  }

  .hero h1 {
    font-size: 2rem;
  }

  .hero-description {
    font-size: 1rem;
  }

  .docs-content h1 {
    font-size: 1.75rem;
  }

  .docs-content h2 {
    font-size: 1.5rem;
  }
}

/* ========== Component Styles ========== */

/* Callout Component */
.callout {
  padding: 1rem 1.25rem;
  margin: 1rem 0;
  border-radius: 0.5rem;
  border-left: 4px solid;
}

.callout-icon {
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
}

.callout-title {
  font-weight: 600;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.callout-content p:last-child {
  margin-bottom: 0;
}

.callout-info {
  background-color: rgba(59, 130, 246, 0.1);
  border-color: #3b82f6;
}

.callout-tip {
  background-color: rgba(34, 197, 94, 0.1);
  border-color: #22c55e;
}

.callout-warning {
  background-color: rgba(234, 179, 8, 0.1);
  border-color: #eab308;
}

.callout-danger {
  background-color: rgba(239, 68, 68, 0.1);
  border-color: #ef4444;
}

.callout-note {
  background-color: rgba(107, 114, 128, 0.1);
  border-color: #6b7280;
}

/* Tabs Component */
.tabs-container {
  margin: 1.5rem 0;
  border: 1px solid var(--color-border);
  border-radius: 0.5rem;
  overflow: hidden;
}

.tabs-list {
  display: flex;
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  overflow-x: auto;
}

.tab-button {
  padding: 0.75rem 1.25rem;
  border: none;
  background: none;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text-muted);
  cursor: pointer;
  border-bottom: 2px solid transparent;
  white-space: nowrap;
  transition: all 0.15s;
}

.tab-button:hover {
  color: var(--color-text);
  background-color: var(--color-background);
}

.tab-button.active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
}

.tabs-content {
  padding: 1rem;
}

.tab-panel {
  display: none;
}

.tab-panel.active {
  display: block;
}

/* Card Component */
.card {
  padding: 1.5rem;
  border: 1px solid var(--color-border);
  border-radius: 0.5rem;
  background-color: var(--color-surface);
  transition: all 0.15s;
}

.card:hover {
  border-color: var(--color-primary);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card-icon {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.card-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.card-content {
  color: var(--color-text-muted);
  font-size: 0.875rem;
}

.card-link {
  text-decoration: none;
  color: inherit;
  display: block;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(var(--card-grid-cols, 2), 1fr);
  gap: 1rem;
  margin: 1.5rem 0;
}

/* Unknown Component */
.component-unknown {
  padding: 1rem;
  margin: 1rem 0;
  background-color: rgba(239, 68, 68, 0.1);
  border: 1px dashed #ef4444;
  border-radius: 0.5rem;
  color: #ef4444;
  font-size: 0.875rem;
}

/* Dark Mode for Components */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) .callout-info {
    background-color: rgba(59, 130, 246, 0.15);
  }

  :root:not([data-theme="light"]) .callout-tip {
    background-color: rgba(34, 197, 94, 0.15);
  }

  :root:not([data-theme="light"]) .callout-warning {
    background-color: rgba(234, 179, 8, 0.15);
  }

  :root:not([data-theme="light"]) .callout-danger {
    background-color: rgba(239, 68, 68, 0.15);
  }

  :root:not([data-theme="light"]) .callout-note {
    background-color: rgba(107, 114, 128, 0.2);
  }

  :root:not([data-theme="light"]) .card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  }
}

:root[data-theme="dark"] .callout-info {
  background-color: rgba(59, 130, 246, 0.15);
}

:root[data-theme="dark"] .callout-tip {
  background-color: rgba(34, 197, 94, 0.15);
}

:root[data-theme="dark"] .callout-warning {
  background-color: rgba(234, 179, 8, 0.15);
}

:root[data-theme="dark"] .callout-danger {
  background-color: rgba(239, 68, 68, 0.15);
}

:root[data-theme="dark"] .callout-note {
  background-color: rgba(107, 114, 128, 0.2);
}

:root[data-theme="dark"] .card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

/* ========== Theme Toggle ========== */

.theme-toggle {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  border: none;
  background: none;
  color: var(--color-text-muted);
  cursor: pointer;
  transition: color 0.2s;
  font-size: 1em;
}

.theme-toggle:hover {
  color: var(--color-primary);
}

.theme-toggle-light,
.theme-toggle-dark {
  display: inline-flex;
  align-items: center;
  width: 1.375em;
  height: 1.375em;
}

.theme-toggle-light svg,
.theme-toggle-dark svg {
  width: 100%;
  height: 100%;
  fill: currentColor;
}

/* Default: light icon visible, dark icon hidden */
.theme-toggle-dark { display: none; }

/* Dark mode via attribute */
:root[data-theme="dark"] .theme-toggle-dark { display: inline-flex; }
:root[data-theme="dark"] .theme-toggle-light { display: none; }

/* Dark mode via system preference (no explicit toggle yet) */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) .theme-toggle-dark { display: inline-flex; }
  :root:not([data-theme="light"]) .theme-toggle-light { display: none; }
}
''';

    // Add version switcher styles if enabled
    final versionSwitcherStyles = includeVersionSwitcher
        ? '''

/* ========== Version Switcher ========== */

.version-switcher {
  display: flex;
  align-items: center;
}

.version-select {
  appearance: none;
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 0.375rem;
  padding: 0.5rem 2rem 0.5rem 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text);
  cursor: pointer;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M2.5 4.5L6 8l3.5-3.5'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.5rem center;
  transition: all 0.15s;
}

.version-select:hover {
  border-color: var(--color-primary);
}

.version-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(1, 117, 194, 0.1);
}

.version-select option {
  background-color: var(--color-surface);
  color: var(--color-text);
}

@media (prefers-color-scheme: dark) {
  .version-select {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%239ca3af' d='M2.5 4.5L6 8l3.5-3.5'/%3E%3C/svg%3E");
  }

  .version-select:focus {
    box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.2);
  }
}
'''
        : '';

    final webDir = p.join(managedDir, 'web');
    await Directory(webDir).create(recursive: true);
    await File(
      p.join(webDir, 'styles.css'),
    ).writeAsString(styles + versionSwitcherStyles);

    // Always generate theme toggle script
    await _generateThemeScript(webDir);

    // Generate live-reload script during serve mode
    if (serveMode) {
      await _generateLiveReload(webDir);
    }
  }

  Future<void> _generateThemeScript(String webDir) async {
    final mode = config.themeMode.name; // 'system', 'light', or 'dark'

    final themeScript =
        '''
(function() {
  var forcedMode = '$mode'; // from config.themeMode

  // Apply initial theme: forced mode overrides localStorage
  if (forcedMode === 'light' || forcedMode === 'dark') {
    document.documentElement.setAttribute('data-theme', forcedMode);
  } else {
    var stored = localStorage.getItem('docudart-theme');
    if (stored) {
      document.documentElement.setAttribute('data-theme', stored);
    }
  }

  document.addEventListener('click', function(e) {
    var btn = e.target.closest('.theme-toggle');
    if (!btn) return;

    var current = document.documentElement.getAttribute('data-theme');
    var isDark;
    if (current === 'dark') {
      isDark = false;
    } else if (current === 'light') {
      isDark = true;
    } else {
      isDark = !window.matchMedia('(prefers-color-scheme: dark)').matches;
    }

    var next = isDark ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('docudart-theme', next);
  });
})();

// Sidebar: collapsible categories + active link highlighting
(function() {
  var STORAGE_KEY = 'docudart-sidebar-state';

  function loadState() {
    try {
      var stored = localStorage.getItem(STORAGE_KEY);
      return stored ? JSON.parse(stored) : {};
    } catch(e) { return {}; }
  }

  function saveState(state) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch(e) {}
  }

  function initCollapse() {
    var state = loadState();
    var categories = document.querySelectorAll('.sidebar-category[data-category]');

    categories.forEach(function(cat) {
      var id = cat.getAttribute('data-category');
      if (state.hasOwnProperty(id)) {
        cat.setAttribute('data-collapsed', state[id] ? 'true' : 'false');
      }
    });
  }

  // Click handler for category titles
  document.addEventListener('click', function(e) {
    var title = e.target.closest('.sidebar-category-title');
    if (!title) return;

    var cat = title.closest('.sidebar-category');
    if (!cat) return;

    var id = cat.getAttribute('data-category');
    var isCollapsed = cat.getAttribute('data-collapsed') === 'true';

    cat.setAttribute('data-collapsed', isCollapsed ? 'false' : 'true');

    var currentState = loadState();
    currentState[id] = !isCollapsed;
    saveState(currentState);
  });

  // Keyboard accessibility for category titles
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' || e.key === ' ') {
      var title = e.target.closest('.sidebar-category-title');
      if (title) {
        e.preventDefault();
        title.click();
      }
    }
  });

  // Active link highlighting
  function expandParents(element) {
    var state = loadState();
    var parent = element.closest('.sidebar-category');
    while (parent) {
      parent.setAttribute('data-collapsed', 'false');
      var id = parent.getAttribute('data-category');
      if (id) state[id] = false;
      var grandparent = parent.parentElement;
      parent = grandparent ? grandparent.closest('.sidebar-category') : null;
    }
    saveState(state);
  }

  function updateActiveLink() {
    var path = window.location.pathname;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.slice(0, -1);
    }

    var links = document.querySelectorAll('.sidebar-link[data-path]');
    var found = false;
    links.forEach(function(link) {
      var linkPath = link.getAttribute('data-path');
      if (linkPath && linkPath.length > 1 && linkPath.endsWith('/')) {
        linkPath = linkPath.slice(0, -1);
      }

      if (linkPath === path) {
        link.classList.add('active');
        expandParents(link);
        found = true;
      } else {
        link.classList.remove('active');
      }
    });

    // Header nav links: prefix matching (e.g. /docs matches /docs/getting-started)
    var navLinks = document.querySelectorAll('.header-nav .nav-link[data-path]');
    navLinks.forEach(function(link) {
      var linkPath = link.getAttribute('data-path');
      if (linkPath && linkPath.length > 1 && linkPath.endsWith('/')) {
        linkPath = linkPath.slice(0, -1);
      }

      if (path === linkPath || path.startsWith(linkPath + '/')) {
        link.classList.add('active');
      } else {
        link.classList.remove('active');
      }
    });
  }

  // SPA navigation detection
  var _pushState = history.pushState;
  var _replaceState = history.replaceState;

  history.pushState = function() {
    _pushState.apply(history, arguments);
    window.dispatchEvent(new Event('docudart-navigate'));
  };

  history.replaceState = function() {
    _replaceState.apply(history, arguments);
    window.dispatchEvent(new Event('docudart-navigate'));
  };

  window.addEventListener('popstate', function() {
    setTimeout(updateActiveLink, 50);
  });

  window.addEventListener('docudart-navigate', function() {
    setTimeout(updateActiveLink, 50);
  });

  // MutationObserver: re-apply if Jaspr re-renders sidebar
  function startObserver() {
    var sidebar = document.querySelector('.sidebar');
    if (!sidebar) return;
    var observer = new MutationObserver(function() {
      updateActiveLink();
    });
    observer.observe(sidebar, { childList: true, subtree: true });
  }

  function init() {
    initCollapse();
    updateActiveLink();
    startObserver();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
''';
    await File(p.join(webDir, 'theme.js')).writeAsString(themeScript);
  }

  Future<void> _generateLiveReload(String webDir) async {
    // Write initial version file
    await bumpLiveReloadVersion();

    final script = '''
(function() {
  var currentVersion = null;
  var url = '/live-reload-version.txt';

  function poll() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url + '?t=' + Date.now(), true);
    xhr.timeout = 2000;
    xhr.onload = function() {
      if (xhr.status === 200) {
        var version = xhr.responseText.trim();
        if (currentVersion === null) {
          currentVersion = version;
        } else if (version !== currentVersion) {
          console.log('[docudart] Reloading...');
          location.reload();
        }
      }
    };
    xhr.send();
  }

  setInterval(poll, 1000);
})();
''';
    await File(p.join(webDir, 'live-reload.js')).writeAsString(script);
  }

  /// Writes a new version timestamp to the live-reload version file.
  /// Called after each regeneration during serve mode.
  Future<void> bumpLiveReloadVersion() async {
    final webDir = p.join(managedDir, 'web');
    await Directory(webDir).create(recursive: true);
    await File(p.join(webDir, 'live-reload-version.txt'))
        .writeAsString(DateTime.now().millisecondsSinceEpoch.toString());
  }

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
