import 'package:docudart/docudart.dart';

/// A row of social media icon links.
///
/// Renders each [NavLink] as a clickable icon link.
/// Typically used in the footer's `trailing` slot.
///
/// ```dart
/// Socials(links: [
///   NavLink.url('https://youtube.com', leading: Icons.youtube),
///   NavLink.url('https://github.com', leading: Icons.github),
/// ])
/// ```
class Socials extends StatelessComponent {
  const Socials({required this.links, super.key});
  final List<NavLink> links;

  @override
  Component build(BuildContext context) {
    return div(classes: 'socials', [...links]);
  }
}
