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
    return footer(classes: 'site-footer', [
      div(classes: 'footer-content', [
        Row(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .center,
          children: [
            div(classes: 'footer-leading', [?leading]),
            div(classes: 'footer-center', [
              p([.text(text)]),
              p(classes: 'built-with', [
                .text('Built with '),
                a(href: 'https://pub.dev/packages/docudart', target: .blank, [
                  .text('DocuDart'),
                ]),
              ]),
            ]),
            div(classes: 'footer-trailing', [?trailing]),
          ],
        ),
      ]),
    ]);
  }
}
