import 'package:docudart/docudart.dart';

import '../config.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
/// The [DefaultFooter] provides a simple centered text footer.
class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    final year = DateTime.now().year;
    return DefaultFooter(text: '© $year ${config.title}');
  }
}
