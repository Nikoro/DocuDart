import 'package:docudart/docudart.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
/// The [DefaultFooter] provides a simple centered text footer.
class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return DefaultFooter(
      text: '© 2026 example_project',
    );
  }
}
