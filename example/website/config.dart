import 'package:docudart/docudart.dart';

final config = DocuDartConfig(
  title: 'example_project',
  description:
      'An example Dart project to demonstrate DocuDart documentation generator.',

  // Theme configuration
  theme: DefaultTheme(
    // primaryColor: 0xFF0175C2, // Uncomment to customize primary color
    darkMode: DarkModeConfig.system,
  ),

  // Sidebar configuration
  sidebar: SidebarConfig(
    autoGenerate: true,
    // Add manual sidebar items here if needed
    items: [],
  ),

  // Header configuration
  header: HeaderConfig(
    showThemeToggle: true,
    navLinks: [
      NavLink.internal(title: 'Docs', path: '/docs'),
      // NavLink.external(title: 'GitHub', url: 'https://github.com/...'),
    ],
  ),

  // Footer configuration
  footer: FooterConfig(copyright: '© 2026 example_project'),
);
