import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [DefaultHeader] provides a standard header with title, nav links,
/// and optional theme toggle.
class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    return DefaultHeader(
      title: 'example_project',
      navLinks: [
        NavLink.internal(title: 'Docs', path: '/docs'),
        // NavLink.external(title: 'GitHub', url: 'https://github.com/...'),
      ],
      showThemeToggle: true,
    );
  }
}
