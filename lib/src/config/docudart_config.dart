import 'package:docudart/docudart.dart';

/// Main configuration class for DocuDart.
class Config {
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

  /// Theme mode (light, dark, or system).
  final ThemeMode themeMode;

  /// Component registration configuration.
  final ComponentConfig components;

  /// Documentation versioning configuration.
  final VersioningConfig? versioning;

  /// Custom Dart/Jaspr pages.
  final List<CustomPage> customPages;

  /// Header builder function. If null, no header is rendered.
  final Component Function(SiteContext context)? header;

  /// Footer builder function. If null, no footer is rendered.
  final Component Function(SiteContext context)? footer;

  /// Sidebar builder function. If null, no sidebar is rendered.
  final Component Function(SiteContext context)? sidebar;

  Config({
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
    this.themeMode = ThemeMode.system,
    this.components = const ComponentConfig(),
    this.versioning,
    this.customPages = const [],
    this.header,
    this.footer,
    this.sidebar,
  }) : theme = theme ?? const DefaultTheme();

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (logo != null) 'logo': logo,
    'docsDir': docsDir,
    'pagesDir': pagesDir,
    'assetsDir': assetsDir,
    'outputDir': outputDir,
    'baseUrl': baseUrl,
    'cleanUrls': cleanUrls,
    'theme': theme.toJson(),
    'themeMode': themeMode.toJson(),
    'components': components.toJson(),
    if (versioning != null) 'versioning': versioning!.toJson(),
    'customPages': customPages.map((page) => page.toJson()).toList(),
  };

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      title: json['title'] as String?,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      docsDir: json['docsDir'] as String? ?? 'docs',
      pagesDir: json['pagesDir'] as String? ?? 'pages',
      assetsDir: json['assetsDir'] as String? ?? 'assets',
      outputDir: json['outputDir'] as String? ?? 'build/web',
      baseUrl: json['baseUrl'] as String? ?? '/',
      cleanUrls: json['cleanUrls'] as bool? ?? true,
      theme: _themeFromJson(json['theme'] as Map<String, dynamic>?),
      themeMode: json['themeMode'] != null
          ? ThemeMode.fromJson(json['themeMode'] as String)
          : ThemeMode.system,
      components: json['components'] != null
          ? ComponentConfig.fromJson(
              json['components'] as Map<String, dynamic>)
          : const ComponentConfig(),
      versioning: json['versioning'] != null
          ? VersioningConfig.fromJson(
              json['versioning'] as Map<String, dynamic>)
          : null,
      customPages: (json['customPages'] as List<dynamic>?)
              ?.map((e) => CustomPage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static BaseTheme _themeFromJson(Map<String, dynamic>? json) {
    if (json == null) return const DefaultTheme();

    final type = json['type'] as String?;
    if (type == 'default') {
      return DefaultTheme(
        primaryColor: json['primaryColor'] as int?,
      );
    }

    // Reconstruct as CustomTheme for any other type
    return CustomTheme(
      name: json['name'] as String? ?? 'custom',
      colors: json['colors'] != null
          ? ThemeColors.fromJson(json['colors'] as Map<String, dynamic>)
          : const DefaultTheme().colors,
      typography: json['typography'] != null
          ? ThemeTypography.fromJson(
              json['typography'] as Map<String, dynamic>)
          : const ThemeTypography(),
    );
  }

  /// Creates a copy with the given fields replaced.
  Config copyWith({
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
    ThemeMode? themeMode,
    ComponentConfig? components,
    VersioningConfig? versioning,
    List<CustomPage>? customPages,
    Component Function(SiteContext context)? header,
    Component Function(SiteContext context)? footer,
    Component Function(SiteContext context)? sidebar,
  }) {
    return Config(
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
      themeMode: themeMode ?? this.themeMode,
      components: components ?? this.components,
      versioning: versioning ?? this.versioning,
      customPages: customPages ?? this.customPages,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      sidebar: sidebar ?? this.sidebar,
    );
  }
}
