import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [DefaultHeader] provides a standard header with title, nav links,
/// and optional leading/trailing component slots.
class Header extends StatelessComponent {
  const Header({required this.title, this.navLinks, this.trailing, super.key});

  final String title;
  final List<NavLink>? navLinks;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return DefaultHeader(
      title: title,
      navLinks: navLinks,
      trailing: trailing,
    );
  }
}
