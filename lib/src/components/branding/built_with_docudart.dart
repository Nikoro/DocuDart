import 'package:docudart/docudart.dart';

/// A "Built with" branding link.
///
/// ```dart
/// BuiltWithDocuDart()
/// BuiltWithDocuDart(prefix: 'Powered by', label: 'DocuDart')
/// ```
class BuiltWithDocuDart extends StatelessComponent {
  const BuiltWithDocuDart({
    this.prefix = 'Built with',
    this.label = 'DocuDart',
    this.href = 'https://pub.dev/packages/docudart',
    super.key,
  });

  /// Text before the link.
  final String prefix;

  /// Link text.
  final String label;

  /// Link URL.
  final String href;

  @override
  Component build(BuildContext context) {
    return p(classes: 'built-with', [
      .text('$prefix '),
      a(href: href, target: .blank, [.text(label)]),
    ]);
  }
}
