import 'package:docudart/docudart.dart';

/// Default header component with site title, navigation links, and optional
/// leading/trailing component slots.
class DefaultHeader extends StatelessComponent {
  final String title;
  final List<NavLink> _navLinks;
  final Component? leading;
  final Component? trailing;

  const DefaultHeader({
    required this.title,
    this.leading,
    this.trailing,
    List<NavLink>? navLinks,
    super.key,
  }) : _navLinks = navLinks ?? const [];

  @override
  Component build(BuildContext context) {
    return header(classes: 'site-header', [
      div(classes: 'header-content', [
        ?leading,
        a(href: '/', classes: 'site-title', [.text(title)]),
        nav(classes: 'header-nav', [
          for (final link in _navLinks)
            a(
              href: link.href,
              classes: 'nav-link',
              attributes: link.isExternal
                  ? {'target': '_blank', 'rel': 'noopener noreferrer'}
                  : {},
              [
                if (link.leading != null)
                  span(classes: 'nav-link-icon', [link.leading!]),
                if (link.label != null) .text(link.label!),
                if (link.trailing != null)
                  span(classes: 'nav-link-icon', [link.trailing!]),
              ],
            ),
          ?trailing,
        ]),
      ]),
    ]);
  }
}
