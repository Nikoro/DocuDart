import 'package:docudart/docudart.dart';

/// A clickable button component.
class Button extends StatelessComponent {
  final String text;
  final String href;
  final String classes;

  const Button({
    required this.text,
    required this.href,
    this.classes = 'button',
    super.key,
  });

  const Button.primary({required this.text, required this.href, super.key})
    : classes = 'button button-primary';

  @override
  Component build(BuildContext context) {
    return a(href: href, classes: classes, [.text(text)]);
  }
}
