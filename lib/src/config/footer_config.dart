import 'package:meta/meta.dart';

/// Configuration for the site footer.
@immutable
class FooterConfig {
  /// Copyright text displayed in the footer.
  final String? copyright;

  /// Footer links organized in columns.
  final List<FooterColumn> columns;

  const FooterConfig({
    this.copyright,
    this.columns = const [],
  });
}

/// A column of links in the footer.
@immutable
class FooterColumn {
  /// Column title.
  final String title;

  /// Links in this column.
  final List<FooterLink> links;

  const FooterColumn({
    required this.title,
    required this.links,
  });
}

/// A link in the footer.
@immutable
class FooterLink {
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

  const FooterLink({
    required this.title,
    this.path,
    this.url,
  }) : assert(path != null || url != null, 'Either path or url must be set');

  const FooterLink.internal({
    required this.title,
    required String this.path,
  }) : url = null;

  const FooterLink.external({
    required this.title,
    required String this.url,
  }) : path = null;
}
