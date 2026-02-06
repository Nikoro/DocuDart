import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/docudart_config.dart';
import 'content_processor.dart';
import 'version_manager.dart';
import '../routing/sidebar_generator.dart';

/// Generates the managed Jaspr site in .dart_tool/docudart.
class SiteGenerator {
  final DocuDartConfig config;
  final String managedDir;

  SiteGenerator(this.config, {String? websiteDir})
      : managedDir = p.join(
            websiteDir ?? Directory.current.path,
            '.dart_tool',
            'docudart',
          );

  /// Generate the complete Jaspr site structure.
  Future<void> generate() async {
    print('Generating site structure...');

    // Ensure managed directory exists
    final dir = Directory(managedDir);
    if (dir.existsSync()) {
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
        config: config.sidebar,
      );
    }

    // Get default version's sidebar for main navigation
    final defaultVersion = versionManager.defaultVersion;
    final defaultSidebarItems = sidebarItemsByVersion[defaultVersion] ??
        sidebarItemsByVersion.values.firstOrNull ??
        <GeneratedSidebarItem>[];

    // Generate all required files
    await _generatePubspec();
    await _generateMain();
    await _generateApp(allPages, defaultSidebarItems, versionManager);
    await _generateStyles(versionManager.isEnabled);
    await _generateWebFiles();
    await _copyAssets();

    // Run pub get
    print('Installing dependencies...');
    final result = await Process.run(
      'dart',
      ['pub', 'get'],
      workingDirectory: managedDir,
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to install dependencies: ${result.stderr}');
    }

    print('Site structure generated successfully.');
    print('Processed ${allPages.length} documentation pages.');
    if (versionManager.isEnabled) {
      print('Versions: ${versionManager.versions.join(", ")}');
    }
  }

  Future<void> _generatePubspec() async {
    final pubspec = '''
name: docudart_site
description: Generated DocuDart site
version: 0.0.1
publish_to: none

environment:
  sdk: ^3.10.0

dependencies:
  jaspr: ^0.22.0
  jaspr_router: ^0.8.0

dev_dependencies:
  build_runner: ^2.4.0
  jaspr_builder: ^0.22.0
  jaspr_cli: ^0.22.0

jaspr:
  mode: static
''';
    await File(p.join(managedDir, 'pubspec.yaml')).writeAsString(pubspec);
  }

  Future<void> _generateMain() async {
    final title = config.title ?? 'Documentation';
    final description = config.description ?? '';

    await Directory(p.join(managedDir, 'lib')).create(recursive: true);

    // Server entry point (lib/main.server.dart)
    final serverMain = '''
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
      link(rel: 'stylesheet', href: '/styles.css'),
      link(
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono&display=swap',
      ),
      script(src: 'main.client.dart.js', defer: true),
    ],
    body: DocuDartApp(),
  ));
}
''';
    await File(p.join(managedDir, 'lib', 'main.server.dart'))
        .writeAsString(serverMain);

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
    await File(p.join(managedDir, 'lib', 'main.client.dart'))
        .writeAsString(clientMain);

    // Client options placeholder (lib/main.client.options.dart)
    // jaspr_builder will regenerate this with actual component registrations
    final clientOptions = '''
// ignore_for_file: type=lint
import 'package:jaspr/client.dart';

ClientOptions get defaultClientOptions => ClientOptions();
''';
    await File(p.join(managedDir, 'lib', 'main.client.options.dart'))
        .writeAsString(clientOptions);
  }

  Future<void> _generateApp(
    List<DocPage> pages,
    List<GeneratedSidebarItem> sidebarItems,
    VersionManager versionManager,
  ) async {
    // Generate routes for all pages
    final routesBuffer = StringBuffer();

    // Home route
    routesBuffer.writeln('''
        Route(
          path: '/',
          builder: (context, state) => const Layout(
            child: HomePage(),
          ),
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

    final app = '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'components/layout.dart';
import 'components/docs_page_content.dart';
import 'pages/home_page.dart';

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

    // Generate pages and components
    await _generatePages();
    await _generateComponents(sidebarItems, versionManager);
  }

  Future<void> _generatePages() async {
    final pagesDir = p.join(managedDir, 'lib', 'pages');
    await Directory(pagesDir).create(recursive: true);

    // Home page
    final title = config.title ?? 'Documentation';
    final description = config.description ?? 'Welcome to the documentation';

    final homePage = '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'home-page',
      [
        div(
          classes: 'hero',
          [
            h1([.text('$title')]),
            p(classes: 'hero-description', [.text('$description')]),
            div(
              classes: 'hero-actions',
              [
                a(
                  href: '/docs',
                  classes: 'button button-primary',
                  [.text('Get Started')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
''';
    await File(p.join(pagesDir, 'home_page.dart')).writeAsString(homePage);
  }

  Future<void> _generateComponents(
    List<GeneratedSidebarItem> sidebarItems,
    VersionManager versionManager,
  ) async {
    final componentsDir = p.join(managedDir, 'lib', 'components');
    await Directory(componentsDir).create(recursive: true);

    // Layout component with sidebar
    final title = config.title ?? 'Documentation';
    final sidebarCode = _generateSidebarCode(sidebarItems);

    // Generate version switcher import and component if versioning is enabled
    final hasVersioning = versionManager.isEnabled;
    final versionSwitcherImport = hasVersioning
        ? "import 'version_switcher.dart';"
        : '';
    final versionSwitcherComponent = hasVersioning
        ? 'const VersionSwitcher(),'
        : '';

    final layout = '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'sidebar.dart';
$versionSwitcherImport

class Layout extends StatelessComponent {
  final Component child;

  const Layout({
    required this.child,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'layout',
      [
        // Header
        header(
          classes: 'site-header',
          [
            div(
              classes: 'header-content',
              [
                a(
                  href: '/',
                  classes: 'site-title',
                  [.text('$title')],
                ),
                nav(
                  classes: 'header-nav',
                  [
                    a(href: '/docs', [.text('Docs')]),
                    $versionSwitcherComponent
                  ],
                ),
              ],
            ),
          ],
        ),
        // Main content with sidebar
        div(
          classes: 'site-body',
          [
            const Sidebar(),
            div(
              classes: 'site-main',
              attributes: {'role': 'main'},
              [child],
            ),
          ],
        ),
        // Footer
        footer(
          classes: 'site-footer',
          [
            div(
              classes: 'footer-content',
              [
                p([.text('Built with DocuDart')]),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
''';
    await File(p.join(componentsDir, 'layout.dart')).writeAsString(layout);

    // Generate version switcher component if versioning is enabled
    if (hasVersioning) {
      await _generateVersionSwitcher(componentsDir, versionManager);
    }

    // Sidebar component
    final sidebar = '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

$sidebarCode

class Sidebar extends StatelessComponent {
  const Sidebar({super.key});

  @override
  Component build(BuildContext context) {
    return aside(
      classes: 'sidebar',
      [
        nav(
          classes: 'sidebar-nav',
          _buildSidebarItems(sidebarItems),
        ),
      ],
    );
  }
}

List<Component> _buildSidebarItems(List<SidebarItemData> items) {
  return items.map<Component>((item) {
    if (item.isCategory) {
      return div(
        classes: 'sidebar-category',
        [
          span(classes: 'sidebar-category-title', [.text(item.title)]),
          ul(
            classes: 'sidebar-category-items',
            _buildSidebarItems(item.children).map((c) => li([c])).toList(),
          ),
        ],
      );
    } else {
      return a(
        href: item.path ?? '#',
        classes: 'sidebar-link',
        [.text(item.title)],
      );
    }
  }).toList();
}
''';
    await File(p.join(componentsDir, 'sidebar.dart')).writeAsString(sidebar);

    // Docs page content component (renders HTML)
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
    await File(p.join(componentsDir, 'docs_page_content.dart'))
        .writeAsString(docsPageContent);
  }

  String _generateSidebarCode(List<GeneratedSidebarItem> items) {
    final buffer = StringBuffer();

    buffer.writeln('class SidebarItemData {');
    buffer.writeln('  final String title;');
    buffer.writeln('  final String? path;');
    buffer.writeln('  final bool isCategory;');
    buffer.writeln('  final List<SidebarItemData> children;');
    buffer.writeln('');
    buffer.writeln('  const SidebarItemData({');
    buffer.writeln('    required this.title,');
    buffer.writeln('    this.path,');
    buffer.writeln('    this.isCategory = false,');
    buffer.writeln('    this.children = const [],');
    buffer.writeln('  });');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('const sidebarItems = <SidebarItemData>[');

    for (final item in items) {
      _writeSidebarItem(buffer, item, '  ');
    }

    buffer.writeln('];');

    return buffer.toString();
  }

  void _writeSidebarItem(StringBuffer buffer, GeneratedSidebarItem item, String indent) {
    buffer.writeln('${indent}SidebarItemData(');
    buffer.writeln("$indent  title: '${_escapeForDart(item.title)}',");

    if (item.path != null) {
      buffer.writeln("$indent  path: '${item.path}',");
    }

    buffer.writeln('$indent  isCategory: ${item.isCategory},');

    if (item.children.isNotEmpty) {
      buffer.writeln('$indent  children: [');
      for (final child in item.children) {
        _writeSidebarItem(buffer, child, '$indent    ');
      }
      buffer.writeln('$indent  ],');
    }

    buffer.writeln('$indent),');
  }

  String _escapeForDart(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\$', '\\\$')
        .replaceAll('\n', '\\n');
  }

  Future<void> _generateStyles([bool includeVersionSwitcher = false]) async {
    final colors = config.theme.colors;
    final typography = config.theme.typography;

    // Convert colors to hex
    String toHex(int color) =>
        '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

    final styles = '''
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

@media (prefers-color-scheme: dark) {
  :root {
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

.site-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text);
  text-decoration: none;
}

.site-title:hover {
  color: var(--color-primary);
}

.header-nav {
  display: flex;
  gap: 1.5rem;
}

.header-nav a {
  color: var(--color-text-muted);
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s;
}

.header-nav a:hover {
  color: var(--color-primary);
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

.sidebar-category {
  margin-bottom: 1rem;
}

.sidebar-category-title {
  display: block;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-muted);
  margin-bottom: 0.5rem;
  padding: 0 0.75rem;
}

.sidebar-category-items {
  list-style: none;
  padding: 0;
  margin: 0;
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
  text-align: center;
  color: var(--color-text-muted);
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
  .callout-info {
    background-color: rgba(59, 130, 246, 0.15);
  }

  .callout-tip {
    background-color: rgba(34, 197, 94, 0.15);
  }

  .callout-warning {
    background-color: rgba(234, 179, 8, 0.15);
  }

  .callout-danger {
    background-color: rgba(239, 68, 68, 0.15);
  }

  .callout-note {
    background-color: rgba(107, 114, 128, 0.2);
  }

  .card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  }
}
''';

    // Add version switcher styles if enabled
    final versionSwitcherStyles = includeVersionSwitcher ? '''

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
''' : '';

    final webDir = p.join(managedDir, 'web');
    await Directory(webDir).create(recursive: true);
    await File(p.join(webDir, 'styles.css')).writeAsString(styles + versionSwitcherStyles);
  }

  Future<void> _generateWebFiles() async {
    // No custom index.html needed — Jaspr generates it from the Document
    // component in main.server.dart. Only web/styles.css is needed, which
    // is already handled by _generateStyles().
  }

  Future<void> _copyAssets() async {
    final sourceDir = Directory(config.assetsDir);
    if (!sourceDir.existsSync()) return;

    final targetDir = Directory(p.join(managedDir, 'web', 'assets'));
    await targetDir.create(recursive: true);

    await for (final entity in sourceDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: sourceDir.path);
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
      versionDataBuffer.writeln("    urlPrefix: ${isDefault ? "'/docs'" : "'/$label/docs'"},");
      versionDataBuffer.writeln("    isDefault: $isDefault,");
      versionDataBuffer.writeln("    isLatest: $isLatest,");
      versionDataBuffer.writeln("  ),");
    }
    versionDataBuffer.writeln('];');

    final versionSwitcher = '''
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

    await File(p.join(componentsDir, 'version_switcher.dart'))
        .writeAsString(versionSwitcher);
  }
}
