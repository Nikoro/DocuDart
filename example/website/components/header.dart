import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [DefaultHeader] provides a standard header with nav links,
/// and optional trailing component slot.
///
/// The [leading] slot is typically a [Logo].
class Header extends StatelessComponent {
  const Header({this.leading, this.navLinks, this.trailing, super.key});

  final Component? leading;
  final List<NavLink>? navLinks;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return DefaultHeader(
      leading: leading,
      navLinks: navLinks,
      trailing: trailing,
    );
  }
}
