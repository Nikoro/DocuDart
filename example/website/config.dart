import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';
import 'icons.dart';
import 'labels.dart';
import 'pages/landing_page.dart';

final init = setup((project) => Config(
  title: project.pubspec.name,
  description: project.pubspec.description,
  themeMode: ThemeMode.system,
  theme: DefaultTheme(),
  // Home page component. Set to null to redirect '/' to '/docs'.
  home: () => LandingPage(
    title: project.pubspec.name,
    description: project.pubspec.description,
  ),
  // Header, footer, and sidebar are components.
  // Set to null to hide any section.
  header: () => Header(
    title: project.pubspec.name,
    navLinks: [
      .path('/docs', label: Labels.docs, icon: Icons.docs),
      .url('https://github.com', label: Labels.github, icon: Icons.github),
      .url('https://pub.dev', label: Labels.pubDev, icon: Icons.pubDev),
    ],
    trailing: ThemeToggle(light: Icons.lightMode, dark: Icons.darkMode),
  ),
  footer: () {
    final year = DateTime.now().year;
    return Footer(
      text: '© $year ${project.pubspec.name}',
      trailing: Socials(
        links: [
          .url('https://youtube.com', icon: Icons.youtube),
          .url('https://discord.com', icon: Icons.discord),
          .url('https://x.com', icon: Icons.xTwitter),
        ],
      ),
    );
  },
  sidebar: () => Sidebar(items: project.docs),
));
