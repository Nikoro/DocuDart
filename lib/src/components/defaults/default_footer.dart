import 'package:docudart/docudart.dart';

/// Default footer component with copyright text.
class DefaultFooter extends StatelessComponent {
  final String text;

  const DefaultFooter({required this.text, super.key});

  @override
  Component build(BuildContext context) {
    return footer(classes: 'site-footer', [
      div(classes: 'footer-content', [
        p([.text(text)]),
        p(classes: 'built-with', [
          .text('Built with '),
          a(href: 'https://pub.dev/packages/docudart', target: Target.blank, [
            .text('DocuDart'),
          ]),
        ]),
      ]),
    ]);
  }
}
