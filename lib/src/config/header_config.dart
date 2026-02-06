import 'package:meta/meta.dart';

/// Configuration for the site header.
@immutable
class HeaderConfig {
  /// Whether to show the site title in the header.
  final bool showTitle;

  /// Whether to show the logo in the header.
  final bool showLogo;

  /// Navigation links in the header.
  final List<NavLink> navLinks;

  /// Whether to show the theme toggle button.
  final bool showThemeToggle;

  /// Whether to show the version switcher dropdown.
  final bool showVersionSwitcher;

  const HeaderConfig({
    this.showTitle = true,
    this.showLogo = true,
    this.navLinks = const [],
    this.showThemeToggle = true,
    this.showVersionSwitcher = true,
  });

  Map<String, dynamic> toJson() => {
    'showTitle': showTitle,
    'showLogo': showLogo,
    'navLinks': navLinks.map((l) => l.toJson()).toList(),
    'showThemeToggle': showThemeToggle,
    'showVersionSwitcher': showVersionSwitcher,
  };

  factory HeaderConfig.fromJson(Map<String, dynamic> json) => HeaderConfig(
    showTitle: json['showTitle'] as bool? ?? true,
    showLogo: json['showLogo'] as bool? ?? true,
    navLinks: (json['navLinks'] as List<dynamic>?)
            ?.map((e) => NavLink.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    showThemeToggle: json['showThemeToggle'] as bool? ?? true,
    showVersionSwitcher: json['showVersionSwitcher'] as bool? ?? true,
  );
}

/// A navigation link in the header.
@immutable
class NavLink {
  /// Display title.
  final String title;

  /// Internal path (mutually exclusive with url).
  final String? path;

  /// External URL (mutually exclusive with path).
  final String? url;

  /// Whether this is an external link.
  bool get external => url != null;

  /// The href to use (path or url).
  String get href => url ?? path ?? '/';

  const NavLink({required this.title, this.path, this.url})
    : assert(path != null || url != null, 'Either path or url must be set');

  const NavLink.internal({required this.title, required String this.path})
    : url = null;

  const NavLink.external({required this.title, required String this.url})
    : path = null;

  Map<String, dynamic> toJson() => {
    'title': title,
    if (path != null) 'path': path,
    if (url != null) 'url': url,
  };

  factory NavLink.fromJson(Map<String, dynamic> json) => NavLink(
    title: json['title'] as String,
    path: json['path'] as String?,
    url: json['url'] as String?,
  );
}
