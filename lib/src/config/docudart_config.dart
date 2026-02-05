import 'package:meta/meta.dart';

import 'sidebar_config.dart';
import 'header_config.dart';
import 'footer_config.dart';
import 'component_config.dart';
import 'versioning_config.dart';
import 'custom_page.dart';
import '../theme/base_theme.dart';
import '../theme/default_theme.dart';

/// Main configuration class for DocuDart.
@immutable
class DocuDartConfig {
  /// Site title. Defaults to name from pubspec.yaml.
  final String? title;

  /// Site description. Defaults to description from pubspec.yaml.
  final String? description;

  /// Path to logo image.
  final String? logo;

  /// Directory containing documentation markdown files.
  final String docsDir;

  /// Directory containing custom Dart/Jaspr pages.
  final String pagesDir;

  /// Directory containing static assets.
  final String assetsDir;

  /// Output directory for built site.
  final String outputDir;

  /// Base URL for deployment (e.g., '/my-project/' for subdirectory).
  final String baseUrl;

  /// Whether to use clean URLs (/docs/intro/ vs /docs/intro.html).
  final bool cleanUrls;

  /// Theme configuration.
  final BaseTheme theme;

  /// Sidebar configuration.
  final SidebarConfig sidebar;

  /// Component registration configuration.
  final ComponentConfig components;

  /// Documentation versioning configuration.
  final VersioningConfig? versioning;

  /// Custom Dart/Jaspr pages.
  final List<CustomPage> customPages;

  /// Header configuration.
  final HeaderConfig header;

  /// Footer configuration.
  final FooterConfig footer;

  const DocuDartConfig({
    this.title,
    this.description,
    this.logo,
    this.docsDir = 'docs',
    this.pagesDir = 'pages',
    this.assetsDir = 'assets',
    this.outputDir = 'build/web',
    this.baseUrl = '/',
    this.cleanUrls = true,
    BaseTheme? theme,
    this.sidebar = const SidebarConfig(),
    this.components = const ComponentConfig(),
    this.versioning,
    this.customPages = const [],
    this.header = const HeaderConfig(),
    this.footer = const FooterConfig(),
  }) : theme = theme ?? const DefaultTheme();

  /// Creates a copy with the given fields replaced.
  DocuDartConfig copyWith({
    String? title,
    String? description,
    String? logo,
    String? docsDir,
    String? pagesDir,
    String? assetsDir,
    String? outputDir,
    String? baseUrl,
    bool? cleanUrls,
    BaseTheme? theme,
    SidebarConfig? sidebar,
    ComponentConfig? components,
    VersioningConfig? versioning,
    List<CustomPage>? customPages,
    HeaderConfig? header,
    FooterConfig? footer,
  }) {
    return DocuDartConfig(
      title: title ?? this.title,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      docsDir: docsDir ?? this.docsDir,
      pagesDir: pagesDir ?? this.pagesDir,
      assetsDir: assetsDir ?? this.assetsDir,
      outputDir: outputDir ?? this.outputDir,
      baseUrl: baseUrl ?? this.baseUrl,
      cleanUrls: cleanUrls ?? this.cleanUrls,
      theme: theme ?? this.theme,
      sidebar: sidebar ?? this.sidebar,
      components: components ?? this.components,
      versioning: versioning ?? this.versioning,
      customPages: customPages ?? this.customPages,
      header: header ?? this.header,
      footer: footer ?? this.footer,
    );
  }
}
