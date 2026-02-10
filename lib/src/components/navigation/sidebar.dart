import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../../models/doc.dart';
import '../layout/flex_enums.dart';
import '../layout/row.dart';
import 'expansion_tile.dart';

/// Default sidebar component that renders a navigation tree from [Doc] items.
///
/// Categories render as [ExpansionTile] components with animated chevrons.
/// Links render as `<a>` elements with `data-path` attributes for active
/// link highlighting via JS.
class DefaultSidebar extends StatelessComponent {
  const DefaultSidebar({required this.items, super.key});
  final List<Doc> items;

  @override
  Component build(BuildContext context) {
    return aside(classes: 'sidebar', [
      nav(classes: 'sidebar-nav', [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _buildItems(items),
        ),
      ]),
    ]);
  }

  List<Component> _buildItems(List<Doc> items, [String parentSlug = '']) {
    return items.map<Component>((item) {
      switch (item) {
        case DocLink(:final name, :final path):
          return a(
            href: path,
            classes: 'sidebar-link',
            attributes: {'data-path': path},
            [.text(name)],
          );
        case DocCategory(:final name, :final children, :final expanded):
          final slug = parentSlug.isEmpty
              ? _slugify(name)
              : '$parentSlug/${_slugify(name)}';
          return ExpansionTile(
            id: slug,
            title: name,
            expanded: expanded,
            children: _buildItems(children, slug),
          );
      }
    }).toList();
  }

  static String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
