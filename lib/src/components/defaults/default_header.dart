import 'package:docudart/docudart.dart';

/// Default header component with navigation links, and optional
/// leading/trailing component slots.
///
/// The [leading] slot is rendered before the nav links — typically a [Logo].
class DefaultHeader extends StatelessComponent {
  const DefaultHeader({
    this.leading,
    this.trailing,
    List<NavLink>? navLinks,
    super.key,
  }) : _navLinks = navLinks ?? const [];
  final List<NavLink> _navLinks;
  final Component? leading;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return header(classes: 'site-header', [
      div(classes: 'header-content', [
        ?leading,
        nav(classes: 'header-nav', [..._navLinks, ?trailing]),
      ]),
    ]);
  }
}
