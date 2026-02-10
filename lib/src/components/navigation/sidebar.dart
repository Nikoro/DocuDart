import 'package:docudart/docudart.dart';

/// Default sidebar component that renders doc navigation items.
class DefaultSidebar extends StatelessComponent {
  const DefaultSidebar({required this.items, super.key});
  final List<GeneratedSidebarItem> items;

  @override
  Component build(BuildContext context) {
    return aside(classes: 'sidebar', [
      nav(classes: 'sidebar-nav', [
        ul(classes: 'sidebar-items', _buildItems(items)),
      ]),
    ]);
  }

  List<Component> _buildItems(
    List<GeneratedSidebarItem> items, [
    String parentSlug = '',
  ]) {
    return items.map<Component>((item) {
      if (item.isCategory) {
        final slug = parentSlug.isEmpty
            ? _slugify(item.title)
            : '$parentSlug/${_slugify(item.title)}';
        return li(
          classes: 'sidebar-category',
          attributes: {
            'data-category': slug,
            'data-collapsed': item.collapsed.toString(),
          },
          [
            span(
              classes: 'sidebar-category-title',
              attributes: {'role': 'button', 'tabindex': '0'},
              [.text(item.title)],
            ),
            ul(
              classes: 'sidebar-category-items',
              _buildItems(item.children, slug),
            ),
          ],
        );
      } else {
        return li([
          a(
            href: item.path ?? '#',
            classes: 'sidebar-link',
            attributes: {'data-path': item.path ?? ''},
            [.text(item.title)],
          ),
        ]);
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
