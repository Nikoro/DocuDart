import 'package:docudart/docudart.dart';

/// Branding component showing copyright text and a "Built with DocuDart" link.
class Copyright extends StatelessComponent {
  const Copyright({required this.text, super.key});
  final String text;

  @override
  Component build(BuildContext context) {
    final year = DateTime.now().year;
    return p([.text('© $year $text')]);
  }
}
