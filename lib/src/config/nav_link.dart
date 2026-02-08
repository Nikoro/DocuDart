import 'package:jaspr/jaspr.dart';

/// A navigation link in the header.
@immutable
class NavLink {
  /// Display label text.
  final String? label;

  /// Component rendered before the label.
  final Component? leading;

  /// Component rendered after the label.
  final Component? trailing;

  final String? _path;
  final String? _url;

  /// Whether this is an external link.
  bool get isExternal => _url != null;

  /// The href to use (path or url).
  String get href => _url ?? _path ?? '/';

  NavLink._({this.label, this.leading, this.trailing, String? path, String? url})
    : _path = path,
      _url = url,
      assert(
        label != null || leading != null || trailing != null,
        'Either label, leading, or trailing must be set',
      ),
      assert(path != null || url != null, 'Either path or url must be set');

  /// Creates a nav link to an internal path.
  NavLink.path(String path, {this.label, this.leading, this.trailing})
    : _path = path,
      _url = null,
      assert(
        label != null || leading != null || trailing != null,
        'Either label, leading, or trailing must be set',
      );

  /// Creates a nav link to an external URL.
  NavLink.url(String url, {this.label, this.leading, this.trailing})
    : _path = null,
      _url = url,
      assert(
        label != null || leading != null || trailing != null,
        'Either label, leading, or trailing must be set',
      );

  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    if (_path != null) 'path': _path,
    if (_url != null) 'url': _url,
  };

  factory NavLink.fromJson(Map<String, dynamic> json) => NavLink._(
    label: json['label'] as String? ?? json['title'] as String?,
    path: json['path'] as String?,
    url: json['url'] as String?,
  );
}
