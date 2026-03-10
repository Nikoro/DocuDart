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
    this.href = 'https://docudart.dev',
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
    return p([
      .text('$prefix '),
      Link.url(href, label: label).apply(styles: Styles(fontWeight: .w500)),
    ]).apply(
      styles: Styles(
        fontSize: 0.85.rem,
        margin: .only(top: 0.5.rem),
        opacity: 0.8,
      ),
    );
  }
}
