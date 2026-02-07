import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';
import 'icons.dart';
import 'pages/landing_page.dart';

Config get config => Config(
  title: 'example_project',
  description:
      'An example Dart project to demonstrate DocuDart documentation generator.',

  // Theme configuration
  themeMode: ThemeMode.system,
  theme: DefaultTheme(
    // primaryColor: 0xFF0175C2, // Uncomment to customize primary color
  ),

  // Home page component. Set to null to redirect '/' to '/docs'.
  home: (context) => LandingPage(),

  // Header, footer, and sidebar are components.
  // Set to null to hide any section.
  header: (context) => Header(
    title: 'example_project',
    navLinks: [
      .path('/docs', label: 'Docs', icon: Icons.docs),
      .url('https://github.com', label: 'GitHub', icon: Icons.github),
      .url('https://pub.dev', label: 'pub.dev', icon: Icons.dart),
    ],
    trailing: ThemeToggle(light: Icons.lightMode, dark: Icons.darkMode),
  ),
  footer: (context) => Footer(),
  sidebar: (context) => Sidebar(items: context.docs),
);
