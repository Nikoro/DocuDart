import 'package:docudart/docudart.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
class Footer extends StatelessComponent {
  const Footer({this.leading, this.center, this.trailing, super.key});

  final Component? leading;
  final Component? center;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return footer([
      Row(
        mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .center,
        children: [?leading, ?center, ?trailing],
      ),
    ]);
  }
}
