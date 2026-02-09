import 'package:docudart/docudart.dart';

/// Default header component with navigation links, and optional
/// leading/trailing component slots.
///
/// The [leading] slot is rendered before the nav links — typically a [Logo].
class DefaultHeader extends StatelessComponent {
  const DefaultHeader({this.leading, this.trailing, this.navLinks, super.key});
  final List<Link>? navLinks;
  final Component? leading;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return header(classes: 'site-header', [
      Row(crossAxisAlignment: .center, spacing: 1.5.rem, children: [?leading, Spacer(), ...?navLinks, ?trailing]),
    ]);
  }
}
