import 'package:docudart/docudart.dart';

import '../config.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
/// The [DefaultFooter] provides a simple centered text footer
/// with optional leading/trailing slots.
class Footer extends StatelessComponent {
  final List<NavLink>? socialLinks;

  const Footer({this.socialLinks, super.key});

  @override
  Component build(BuildContext context) {
    final year = DateTime.now().year;
    return DefaultFooter(
      text: '© $year ${config.title}',
      trailing: socialLinks != null ? Socials(links: socialLinks!) : null,
    );
  }
}
