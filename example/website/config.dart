import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';

Config get config => Config(
  title: 'example_project',
  description: 'An example Dart project to demonstrate DocuDart documentation generator.',

  // Theme configuration
  themeMode: ThemeMode.system,
  theme: DefaultTheme(
    // primaryColor: 0xFF0175C2, // Uncomment to customize primary color
  ),

  // Header, footer, and sidebar are components.
  // Set to null to hide any section.
  header: (context) => Header(),
  footer: (context) => Footer(),
  sidebar: (context) => Sidebar(items: context.docs),
);
