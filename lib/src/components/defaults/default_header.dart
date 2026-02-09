import 'package:docudart/docudart.dart';

/// Default header component with navigation links, and optional
/// leading/trailing component slots.
///
/// The [leading] slot is rendered before the nav links — typically a [Logo].
class DefaultHeader extends StatelessComponent {
  final List<NavLink> _navLinks;
  final Component? leading;
  final Component? trailing;

  const DefaultHeader({this.leading, this.trailing, List<NavLink>? navLinks, super.key})
    : _navLinks = navLinks ?? const [];

  @override
  Component build(BuildContext context) {
    return header(classes: 'site-header', [
      div(classes: 'header-content', [
        ?leading,
        nav(classes: 'header-nav', [
          for (final link in _navLinks)
            a(
              href: link.href,
              classes: 'nav-link',
              attributes: {
                if (link.isExternal) ...{'target': '_blank', 'rel': 'noopener noreferrer'},
                if (!link.isExternal) 'data-path': link.href,
              },
              [
                if (link.leading != null) span(classes: 'nav-link-icon', [link.leading!]),
                if (link.label != null) .text(link.label!),
                if (link.trailing != null) span(classes: 'nav-link-icon', [link.trailing!]),
              ],
            ),
          ?trailing,
        ]),
      ]),
    ]);
  }
}
