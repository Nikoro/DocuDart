import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [DefaultHeader] provides a standard header with title, nav links,
/// and optional theme toggle.
class Header extends StatelessComponent {
  const Header(this.navLinks, {required this.title, super.key});

  final String title;
  final List<NavLink> navLinks;

  @override
  Component build(BuildContext context) {
    return DefaultHeader(
      title: title,
      navLinks: navLinks,
    );
  }
}
