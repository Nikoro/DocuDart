import 'package:docudart/docudart.dart';

/// A clickable button component.
class Button extends StatelessComponent {
  const Button({
    required this.text,
    required this.href,
    this.classes = 'button',
    super.key,
  });

  const Button.primary({required this.text, required this.href, super.key})
    : classes = 'button button-primary';

  final String text;
  final String href;
  final String classes;

  @override
  Component build(BuildContext context) {
    return a(href: href, classes: classes, [.text(text)]);
  }
}
