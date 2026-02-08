import 'package:docudart/docudart.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
/// The [DefaultFooter] provides a simple centered text footer
/// with optional leading/trailing slots.
class Footer extends StatelessComponent {
  const Footer({required this.text, this.leading, this.trailing, super.key});

  final String text;
  final Component? leading;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return DefaultFooter(text: text, leading: leading, trailing: trailing);
  }
}
