import 'package:docudart/docudart.dart';

/// A row of social media icon links.
///
/// Renders each [NavLink] as a clickable icon link.
/// Typically used in the footer's `trailing` slot.
///
/// ```dart
/// Socials(links: [
///   NavLink.url('https://youtube.com', icon: Icons.youtube),
///   NavLink.url('https://github.com', icon: Icons.github),
/// ])
/// ```
class Socials extends StatelessComponent {
  final List<NavLink> links;

  const Socials({required this.links, super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'socials', [
      for (final link in links)
        a(
          href: link.href,
          classes: 'social-link',
          attributes: link.isExternal
              ? {'target': '_blank', 'rel': 'noopener noreferrer'}
              : {},
          [
            if (link.icon != null)
              span(classes: 'social-link-icon', [link.icon!]),
            if (link.label != null) .text(link.label!),
          ],
        ),
    ]);
  }
}
