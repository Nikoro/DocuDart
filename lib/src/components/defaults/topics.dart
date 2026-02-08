import 'package:docudart/docudart.dart';

/// A compact grid of topic tag links with an optional title.
///
/// Renders each [NavLink] as a clickable tag link (e.g. `#flutter`).
/// Displays at most 2 items per row. Typically used in the footer's
/// `leading` slot.
///
/// ```dart
/// Topics(
///   title: Labels.topics,
///   links: [
///     NavLink.url('https://pub.dev/packages?q=topic%3Aflutter', label: '#flutter'),
///     NavLink.url('https://pub.dev/packages?q=topic%3Adart', label: '#dart'),
///   ],
/// )
/// ```
class Topics extends StatelessComponent {
  final String? title;
  final List<NavLink> links;

  const Topics({this.title, required this.links, super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'topics', [
      if (title != null) span(classes: 'topics-title', [.text(title!)]),
      div(classes: 'topics-grid', [
        for (final link in links)
          a(
            href: link.href,
            classes: 'topic-link',
            attributes: link.isExternal
                ? {'target': '_blank', 'rel': 'noopener noreferrer'}
                : {},
            [if (link.label != null) .text(link.label!)],
          ),
      ]),
    ]);
  }
}
