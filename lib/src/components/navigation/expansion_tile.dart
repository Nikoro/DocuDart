import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

/// A collapsible tile with an animated chevron header and expandable content.
///
/// Renders a clickable header with a rotation-animated chevron indicator
/// and a content area that expands/collapses with a smooth CSS transition.
/// Interactivity is handled by vanilla JS targeting `data-collapsed` and
/// `data-category` attributes.
///
/// ```dart
/// ExpansionTile(
///   id: 'guides',
///   title: 'Guides',
///   expanded: true,
///   children: [
///     a(href: '/docs/components', [.text('Components')]),
///   ],
/// )
/// ```
class ExpansionTile extends StatelessComponent {
  const ExpansionTile({
    required this.id,
    required this.title,
    required this.children,
    this.expanded = false,
    super.key,
  });

  /// Unique identifier for collapse state persistence (maps to localStorage).
  final String id;

  /// Display text for the header.
  final String title;

  /// Child components shown when expanded.
  final List<Component> children;

  /// Whether this tile starts expanded.
  final bool expanded;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'expansion-tile',
      attributes: {
        'data-category': id,
        'data-collapsed': (!expanded).toString(),
      },
      [
        div(
          classes: 'expansion-tile-header',
          attributes: {'role': 'button', 'tabindex': '0'},
          [.text(title)],
        ),
        div(classes: 'expansion-tile-content', children),
      ],
    );
  }
}
