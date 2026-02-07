import 'package:jaspr/jaspr.dart';

/// A navigation link in the header.
@immutable
class NavLink {
  /// Display label text. Optional if [icon] is set.
  final String? label;

  /// Icon component rendered to the left of the label. Optional if [label] is set.
  final Component? icon;

  final String? _path;
  final String? _url;

  /// Whether this is an external link.
  bool get isExternal => _url != null;

  /// The href to use (path or url).
  String get href => _url ?? _path ?? '/';

  NavLink._({this.label, this.icon, String? path, String? url})
      : _path = path,
        _url = url,
        assert(
          label != null || icon != null,
          'Either label or icon must be set',
        ),
        assert(
          path != null || url != null,
          'Either path or url must be set',
        );

  /// Creates a nav link to an internal path.
  NavLink.path(String path, {this.label, this.icon})
      : _path = path,
        _url = null,
        assert(
          label != null || icon != null,
          'Either label or icon must be set',
        );

  /// Creates a nav link to an external URL.
  NavLink.url(String url, {this.label, this.icon})
      : _path = null,
        _url = url,
        assert(
          label != null || icon != null,
          'Either label or icon must be set',
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
