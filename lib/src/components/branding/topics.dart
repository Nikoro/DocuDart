import 'package:docudart/docudart.dart';

/// A compact grid of topic tag links with an optional title.
///
/// Renders each [Link] as a clickable tag link (e.g. `#flutter`).
/// Displays at most 2 items per row. Typically used in the footer's
/// `leading` slot.
///
/// ```dart
/// Topics(
///   title: Labels.topics,
///   links: [
///     Link.url('https://pub.dev/packages?q=topic%3Aflutter', label: '#flutter'),
///     Link.url('https://pub.dev/packages?q=topic%3Adart', label: '#dart'),
///   ],
/// )
/// ```
class Topics extends StatelessComponent {
  const Topics({this.title, required this.links, super.key});
  final String? title;
  final List<Link> links;

  @override
  Component build(BuildContext context) {
    return div(classes: 'topics', [
      ?title.let((it) => span(classes: 'topics-title', [.text(it)])),
      div(classes: 'topics-grid', [...links]),
    ]);
  }
}
