import 'package:docudart/docudart.dart';

/// Main configuration class for DocuDart.
///
/// The file is named `docudart_config.dart` (not `config.dart`) to avoid
/// conflicts with the user's `config.dart` in generated projects.
class Config {
  Config({
    this.title,
    this.description,
    this.siteUrl,
    this.docsDir = 'docs',
    this.assetsDir = 'assets',
    this.outputDir = 'build/web',
    Theme? theme,
    this.themeMode = ThemeMode.system,
    this.versioning,
    this.header,
    this.footer,
    this.sidebar,
    this.home,
    this.layoutBuilder,
    this.docsBuilder,
  }) : theme = theme ?? Theme.classic();

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      title: json['title'] as String?,
      description: json['description'] as String?,
      siteUrl: json['siteUrl'] as String?,
      docsDir: json['docsDir'] as String? ?? 'docs',
      assetsDir: json['assetsDir'] as String? ?? 'assets',
      outputDir: json['outputDir'] as String? ?? 'build/web',
      theme: json['theme'] != null
          ? Theme.fromJson(json['theme'] as Map<String, dynamic>)
          : null,
      themeMode: json['themeMode'] != null
          ? ThemeMode.fromJson(json['themeMode'] as String)
          : ThemeMode.system,
      versioning: json['versioning'] != null
          ? VersioningConfig.fromJson(
              json['versioning'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Site title. Defaults to name from pubspec.yaml.
  final String? title;

  /// Site description. Defaults to description from pubspec.yaml.
  final String? description;

  /// Base URL of the deployed site (e.g. 'https://docudart.dev').
  ///
  /// When set, enables canonical URLs, Open Graph tags, sitemap.xml,
  /// and robots.txt generation.
  final String? siteUrl;

  /// Directory containing documentation markdown files.
  final String docsDir;

  /// Directory containing static assets.
  final String assetsDir;

  /// Output directory for built site.
  final String outputDir;

  /// Theme configuration.
  final Theme theme;

  /// Theme mode (light, dark, or system).
  final ThemeMode themeMode;

  /// Documentation versioning configuration.
  final VersioningConfig? versioning;

  /// Header builder function. If null, no header is rendered.
  final Component? Function()? header;

  /// Footer builder function. If null, no footer is rendered.
  final Component? Function()? footer;

  /// Sidebar builder function. If null, no sidebar is rendered.
  final Component? Function()? sidebar;

  /// Home page builder function. If null, '/' redirects to '/docs'.
  final Component? Function()? home;

  /// Custom layout builder function. If null, the default [Layout] is used.
  ///
  /// Receives the resolved header, footer, sidebar, and body components,
  /// and returns a [Component] that arranges them.
  final LayoutBuilder? layoutBuilder;

  /// Custom docs page builder function. If null, a built-in default layout
  /// with [TableOfContents] and [TocScrollSpy] is used.
  ///
  /// Receives a [DocPageInfo] containing the rendered content, TOC entries,
  /// and page metadata. Returns a [Component] that arranges the doc page body.
  final DocsBuilder? docsBuilder;

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (siteUrl != null) 'siteUrl': siteUrl,
    'docsDir': docsDir,
    'assetsDir': assetsDir,
    'outputDir': outputDir,
    'theme': theme.toJson(),
    'themeMode': themeMode.toJson(),
    if (versioning != null) 'versioning': versioning!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  Config copyWith({
    String? title,
    String? description,
    String? siteUrl,
    String? docsDir,
    String? assetsDir,
    String? outputDir,
    Theme? theme,
    ThemeMode? themeMode,
    VersioningConfig? versioning,
    Component? Function()? header,
    Component? Function()? footer,
    Component? Function()? sidebar,
    Component? Function()? home,
    LayoutBuilder? layoutBuilder,
    DocsBuilder? docsBuilder,
  }) {
    return Config(
      title: title ?? this.title,
      description: description ?? this.description,
      siteUrl: siteUrl ?? this.siteUrl,
      docsDir: docsDir ?? this.docsDir,
      assetsDir: assetsDir ?? this.assetsDir,
      outputDir: outputDir ?? this.outputDir,
      theme: theme ?? this.theme,
      themeMode: themeMode ?? this.themeMode,
      versioning: versioning ?? this.versioning,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      sidebar: sidebar ?? this.sidebar,
      home: home ?? this.home,
      layoutBuilder: layoutBuilder ?? this.layoutBuilder,
      docsBuilder: docsBuilder ?? this.docsBuilder,
    );
  }
}
