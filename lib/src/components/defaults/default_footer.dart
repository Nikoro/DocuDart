import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart' show footer, div, p;

/// Default footer component with copyright text.
class DefaultFooter extends StatelessComponent {
  final String text;

  const DefaultFooter({
    required this.text,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return footer(classes: 'site-footer', [
      div(classes: 'footer-content', [
        p([.text(text)]),
      ]),
    ]);
  }
}
