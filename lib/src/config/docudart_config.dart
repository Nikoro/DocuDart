import 'package:docudart/docudart.dart';

import '../theme/theme_loader.dart';

/// Main configuration class for DocuDart.
///
/// The file is named `docudart_config.dart` (not `config.dart`) to avoid
/// conflicts with the user's `config.dart` in generated projects.
class Config {
  Config({
    this.title,
    this.description,
    this.docsDir = 'docs',
    this.assetsDir = 'assets',
    this.outputDir = 'build/web',
    BaseTheme? theme,
    this.themeMode = ThemeMode.system,
    this.versioning,
    this.header,
    this.footer,
    this.sidebar,
    this.home,
    this.layoutBuilder,
  }) : theme = theme ?? const DefaultTheme();

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      title: json['title'] as String?,
      description: json['description'] as String?,
      docsDir: json['docsDir'] as String? ?? 'docs',
      assetsDir: json['assetsDir'] as String? ?? 'assets',
      outputDir: json['outputDir'] as String? ?? 'build/web',
      theme: _themeFromJson(json['theme'] as Map<String, dynamic>?),
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

  /// Directory containing documentation markdown files.
  final String docsDir;

  /// Directory containing static assets.
  final String assetsDir;

  /// Output directory for built site.
  final String outputDir;

  /// Theme configuration.
  final BaseTheme theme;

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

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    'docsDir': docsDir,
    'assetsDir': assetsDir,
    'outputDir': outputDir,
    'theme': theme.toJson(),
    'themeMode': themeMode.toJson(),
    if (versioning != null) 'versioning': versioning!.toJson(),
  };

  static BaseTheme _themeFromJson(Map<String, dynamic>? json) {
    if (json == null) return const DefaultTheme();

    final type = json['type'] as String?;
    if (type == 'default') {
      return DefaultTheme(primaryColor: json['primaryColor'] as int?);
    }

    // Reconstruct as LoadedTheme for any other type
    return LoadedTheme(
      name: json['name'] as String? ?? 'custom',
      colors: json['colors'] != null
          ? ThemeColors.fromJson(json['colors'] as Map<String, dynamic>)
          : const DefaultTheme().colors,
      typography: json['typography'] != null
          ? ThemeTypography.fromJson(json['typography'] as Map<String, dynamic>)
          : const ThemeTypography(),
    );
  }

  /// Creates a copy with the given fields replaced.
  Config copyWith({
    String? title,
    String? description,
    String? docsDir,
    String? assetsDir,
    String? outputDir,
    BaseTheme? theme,
    ThemeMode? themeMode,
    VersioningConfig? versioning,
    Component? Function()? header,
    Component? Function()? footer,
    Component? Function()? sidebar,
    Component? Function()? home,
    LayoutBuilder? layoutBuilder,
  }) {
    return Config(
      title: title ?? this.title,
      description: description ?? this.description,
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
    );
  }
}
