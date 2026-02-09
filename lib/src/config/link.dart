import 'package:docudart/docudart.dart';

/// A navigation link that renders itself as an `<a>` tag.
///
/// Supports optional [leading] and [trailing] icon components
/// and a text [label], laid out horizontally with [Row].
///
/// Use [classes] to apply context-specific CSS (e.g. `'nav-link'`,
/// `'social-link'`, `'topic-link'`). Icon wrappers automatically
/// use `'{classes}-icon'` for consistent styling.
///
/// ```dart
/// Link.path('/docs', label: 'Docs', leading: Icons.docs)
/// Link.url('https://github.com', label: 'GitHub', trailing: Icons.openInNew)
/// ```
class Link extends StatelessComponent {
  Link._({
    this.label,
    this.leading,
    this.trailing,
    String? path,
    String? url,
  }) : classes = 'nav-link',
       _path = path,
       _url = url,
       assert(
         label != null || leading != null || trailing != null,
         'Either label, leading, or trailing must be set',
       ),
       assert(path != null || url != null, 'Either path or url must be set');

  /// Creates a nav link to an internal path.
  Link.path(
    String path, {
    this.label,
    this.leading,
    this.trailing,
    this.classes = 'nav-link',
    super.key,
  }) : _path = path,
       _url = null,
       assert(
         label != null || leading != null || trailing != null,
         'Either label, leading, or trailing must be set',
       );

  /// Creates a nav link to an external URL.
  Link.url(
    String url, {
    this.label,
    this.leading,
    this.trailing,
    this.classes = 'nav-link',
    super.key,
  }) : _path = null,
       _url = url,
       assert(
         label != null || leading != null || trailing != null,
         'Either label, leading, or trailing must be set',
       );

  factory Link.fromJson(Map<String, dynamic> json) => Link._(
    label: json['label'] as String? ?? json['title'] as String?,
    path: json['path'] as String?,
    url: json['url'] as String?,
  );

  /// Display label text.
  final String? label;

  /// Component rendered before the label.
  final Component? leading;

  /// Component rendered after the label.
  final Component? trailing;

  /// CSS class(es) applied to the `<a>` element.
  ///
  /// Icon wrappers use `'{classes}-icon'` automatically.
  /// Defaults to `'nav-link'`.
  final String classes;

  final String? _path;
  final String? _url;

  /// Whether this is an external link.
  bool get isExternal => _url != null;

  /// The href to use (path or url).
  String get href => _url ?? _path ?? '/';

  @override
  Component build(BuildContext context) {
    final iconClass = '$classes-icon';
    return a(
      href: href,
      classes: classes,
      attributes: {
        if (isExternal) ...{'target': '_blank', 'rel': 'noopener noreferrer'},
        if (!isExternal) 'data-path': href,
      },
      [
        Row(
          mainAxisSize: .min,
          spacing: 0.375.em,
          children: [
            if (leading != null) span(classes: iconClass, [leading!]),
            if (label != null) .text(label!),
            if (trailing != null) span(classes: iconClass, [trailing!]),
          ],
        ),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    if (_path != null) 'path': _path,
    if (_url != null) 'url': _url,
  };
}
