import 'package:docudart/docudart.dart';

/// Default footer component with copyright text and optional
/// leading/trailing component slots.
class DefaultFooter extends StatelessComponent {
  const DefaultFooter({
    required this.text,
    this.leading,
    this.trailing,
    super.key,
  });
  final String text;
  final Component? leading;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return footer([
      Row(
        mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .center,
        children: [
          ?leading,
          Column(
            mainAxisSize: .min,
            children: [
              p([.text(text)]),
              p(classes: 'built-with', [
                .text('Built with '),
                a(href: 'https://pub.dev/packages/docudart', target: .blank, [
                  .text('DocuDart'),
                ]),
              ]),
            ],
          ),
          ?trailing,
        ],
      ),
    ]);
  }
}
