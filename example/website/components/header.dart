import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [leading] slot is typically a [Logo].
class Header extends StatelessComponent {
  const Header({this.leading, this.links, this.trailing, super.key});

  final Component? leading;
  final List<Link>? links;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return header([
      Row(
        crossAxisAlignment: .center,
        spacing: 1.5.rem,
        children: [?leading, Spacer(), ...?links, ?trailing],
      ),
    ]);
  }
}
