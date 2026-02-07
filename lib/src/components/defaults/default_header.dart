import 'package:docudart/docudart.dart';

/// Default header component with site title, navigation links, and theme toggle.
class DefaultHeader extends StatelessComponent {
  final String title;
  final List<NavLink> navLinks;
  final bool showThemeToggle;

  const DefaultHeader({
    required this.title,
    this.navLinks = const [],
    this.showThemeToggle = true,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return header(classes: 'site-header', [
      div(classes: 'header-content', [
        a(href: '/', classes: 'site-title', [.text(title)]),
        nav(classes: 'header-nav', [
          for (final link in navLinks)
            a(
              href: link.href,
              classes: 'nav-link',
              attributes: link.isExternal
                  ? {'target': '_blank', 'rel': 'noopener noreferrer'}
                  : {},
              [
                if (link.icon != null)
                  span(classes: 'nav-link-icon', [link.icon!]),
                if (link.label != null) .text(link.label!),
              ],
            ),
          if (showThemeToggle)
            button(
              classes: 'theme-toggle',
              attributes: {
                'aria-label': 'Toggle dark mode',
                'title': 'Toggle dark mode',
              },
              [span(classes: 'theme-toggle-icon', [.text('\u263E')])],
            ),
        ]),
      ]),
    ]);
  }
}
