import 'package:meta/meta.dart';

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
