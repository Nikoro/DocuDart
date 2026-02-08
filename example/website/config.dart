import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';
import 'icons.dart';
import 'labels.dart';
import 'pages/landing_page.dart';

final init = setup(
  (project) => Config(
    title: project.pubspec.name,
    description: project.pubspec.description,
    themeMode: ThemeMode.system,
    theme: DefaultTheme(),
    // Home page component. Set to null to redirect '/' to '/docs'.
    home: () => project.pubspec.let(
      (pubspec) =>
          LandingPage(title: pubspec.name, description: pubspec.description),
    ),
    // Header, footer, and sidebar are components.
    // Set to null to hide any section.
    header: () => Header(
      title: project.pubspec.name,
      navLinks: [
        .path('/docs', label: Labels.docs, icon: Icons.docs),
        if (project.pubspec.repository case final repo?)
          .url(repo.link, label: repo.label, icon: repo.icon)
        else
          .url('https://github.com', label: Labels.github, icon: Icons.github),
        .url('https://pub.dev', label: Labels.pubDev, icon: Icons.pubDev),
      ],
      trailing: ThemeToggle(light: Icons.lightMode, dark: Icons.darkMode),
    ),
    footer: () => project.pubspec.let((pubspec) {
      final year = DateTime.now().year;
      return Footer(
        text: '© $year ${pubspec.name}',
        leading: pubspec.topics.let(
          (topics) => Topics(
            title: Labels.topics,
            links: [
              for (final topic in topics)
                .url('https://pub.dev/packages?q=topic%3A$topic', label: '#$topic'),
            ],
          ),
        ),
        trailing: Socials(
          links: [
            .url('https://youtube.com', icon: Icons.youtube),
            .url('https://discord.com', icon: Icons.discord),
            .url('https://x.com', icon: Icons.xTwitter),
          ],
        ),
      );
    }),
    sidebar: () => Sidebar(items: project.docs),
  ),
);
