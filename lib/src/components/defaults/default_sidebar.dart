import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart' show aside, nav, a, span, ul, li;

import '../../routing/sidebar_generator.dart';

/// Default sidebar component that renders doc navigation items.
class DefaultSidebar extends StatelessComponent {
  final List<GeneratedSidebarItem> items;

  const DefaultSidebar({
    required this.items,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return aside(classes: 'sidebar', [
      nav(classes: 'sidebar-nav', [
        ul(classes: 'sidebar-items', _buildItems(items)),
      ]),
    ]);
  }

  List<Component> _buildItems(List<GeneratedSidebarItem> items) {
    return items.map<Component>((item) {
      if (item.isCategory) {
        return li(classes: 'sidebar-category', [
          span(classes: 'sidebar-category-title', [.text(item.title)]),
          ul(classes: 'sidebar-category-items', _buildItems(item.children)),
        ]);
      } else {
        return li([
          a(
            href: item.path ?? '#',
            classes: 'sidebar-link',
            [.text(item.title)],
          ),
        ]);
      }
    }).toList();
  }
}
