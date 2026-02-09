import 'package:docudart/docudart.dart';
import 'assets/assets.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';
import 'icons.dart';
import 'labels.dart';
import 'pages/landing_page.dart';

Config configure(Project project) => Config(
  title: project.pubspec.name,
  description: project.pubspec.description,
  themeMode: .system,
  theme: DefaultTheme(),
  // Home page component. Set to null to redirect '/' to '/docs'.
  home: () => project.pubspec.let(
    (pubspec) =>
        LandingPage(title: pubspec.name, description: pubspec.description),
  ),
  // Header, footer, and sidebar are components.
  // Set to null to hide any section.
  header: () => Header(
    leading: Logo(
      image: img(
        src: Assets.logo.logo_webp,
        alt: '${project.pubspec.name} logo',
      ),
      title: project.pubspec.name,
    ),
    links: [
      .path('/docs', label: Labels.docs, leading: Icons.docs),
      .path('/changelog', label: Labels.changelog),
      ?project.pubspec.repository.let(
        (repository) => .url(
          repository.link,
          label: repository.label,
          leading: repository.icon,
          trailing: Icons.openInNew,
        ),
      ),
      .url(
        'https://pub.dev',
        label: Labels.pubDev,
        leading: Icons.pubDev,
        trailing: Icons.openInNew,
      ),
    ],
    trailing: ThemeToggle(light: Icons.lightMode, dark: Icons.darkMode),
  ),
  footer: () => project.pubspec.let((pubspec) {
    return Footer(
      leading: pubspec.topics.let(
        (topics) => Topics(
          title: Labels.topics,
          links: [
            for (final topic in topics)
              .url(
                'https://pub.dev/packages?q=topic%3A$topic',
                label: '#$topic',
              ),
          ],
        ),
      ),
      center: Column(
        children: [
          Copyright(text: pubspec.name),
          BuiltWithDocuDart(),
        ],
      ),
      trailing: Socials(
        links: [
          .url('https://youtube.com', leading: Icons.youtube),
          .url('https://discord.com', leading: Icons.discord),
          .url('https://x.com', leading: Icons.xTwitter),
        ],
      ),
    );
  }),
  sidebar: () => Sidebar(items: project.docs),
);
