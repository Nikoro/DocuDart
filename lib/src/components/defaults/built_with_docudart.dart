import 'package:docudart/docudart.dart';

/// "Built with DocuDart" branding link.
class BuiltWithDocuDart extends StatelessComponent {
  const BuiltWithDocuDart({super.key});

  @override
  Component build(BuildContext context) {
    return p(classes: 'built-with', [
      .text('Built with '),
      a(href: 'https://pub.dev/packages/docudart', target: .blank, [
        .text('DocuDart'),
      ]),
    ]);
  }
}
