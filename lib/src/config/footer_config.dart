import 'package:meta/meta.dart';

/// Configuration for the site footer.
@immutable
class FooterConfig {
  /// Copyright text displayed in the footer.
  final String? copyright;

  /// Footer links organized in columns.
  final List<FooterColumn> columns;

  const FooterConfig({this.copyright, this.columns = const []});

  Map<String, dynamic> toJson() => {
    if (copyright != null) 'copyright': copyright,
    'columns': columns.map((c) => c.toJson()).toList(),
  };

  factory FooterConfig.fromJson(Map<String, dynamic> json) => FooterConfig(
    copyright: json['copyright'] as String?,
    columns: (json['columns'] as List<dynamic>?)
            ?.map((e) => FooterColumn.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

/// A column of links in the footer.
@immutable
class FooterColumn {
  /// Column title.
  final String title;

  /// Links in this column.
  final List<FooterLink> links;

  const FooterColumn({required this.title, required this.links});

  Map<String, dynamic> toJson() => {
    'title': title,
    'links': links.map((l) => l.toJson()).toList(),
  };

  factory FooterColumn.fromJson(Map<String, dynamic> json) => FooterColumn(
    title: json['title'] as String,
    links: (json['links'] as List<dynamic>)
        .map((e) => FooterLink.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
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

  const FooterLink({required this.title, this.path, this.url})
    : assert(path != null || url != null, 'Either path or url must be set');

  const FooterLink.internal({required this.title, required String this.path})
    : url = null;

  const FooterLink.external({required this.title, required String this.url})
    : path = null;

  Map<String, dynamic> toJson() => {
    'title': title,
    if (path != null) 'path': path,
    if (url != null) 'url': url,
  };

  factory FooterLink.fromJson(Map<String, dynamic> json) => FooterLink(
    title: json['title'] as String,
    path: json['path'] as String?,
    url: json['url'] as String?,
  );
}
