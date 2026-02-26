import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';
import 'labels.dart';
import 'pages/landing_page.dart';

Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  description: context.project.pubspec.description,
  // siteUrl: 'https://my-project.dev', // Uncomment for SEO (canonical URLs, Open Graph, sitemap)
  themeMode: .system,
  theme: .classic(),
  // Home page component. Set to null to redirect '/' to '/docs'.
  home: () => LandingPage(),
  // Header, footer, and sidebar are components.
  // Set to null to hide any section.
  header: () => Header(
    showSidebarToggle: context.url.contains('/docs'),
    leading: Logo(
      image: context.project.assets.logo.logo_webp(
        alt: '${context.project.pubspec.name} logo',
      ),
      title: context.project.pubspec.name,
    ),
    links: [
      .path('/docs', label: Labels.docs, leading: Icon(MaterialSymbols.docs)),
      .path('/changelog', label: Labels.changelog),
      ?context.project.pubspec.repository.let(
        (repository) => .url(
          repository.link,
          label: repository.label,
          leading: repository.icon,
          trailing: Icon(MaterialIcons.open_in_new),
        ),
      ),
      .url(
        'https://pub.dev/packages/docudart',
        label: Labels.pubDev,
        leading: Icon(FontAwesomeIcons.dart_lang_brand),
        trailing: Icon(MaterialIcons.open_in_new),
      ),
    ],
    trailing: ThemeToggle(
      light: Icon(MaterialIcons.light_mode),
      dark: Icon(MaterialIcons.dark_mode),
    ),
  ),
  footer: () => context.project.pubspec.let(
    (pubspec) => Footer(
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
          Copyright(text: context.project.license?.holder ?? pubspec.name),
          BuiltWithDocuDart(),
        ],
      ),
      trailing: Socials(
        links: [
          .url(
            'https://youtube.com',
            leading: Icon(FontAwesomeIcons.youtube_brand),
          ),
          .url(
            'https://discord.com',
            leading: Icon(FontAwesomeIcons.discord_brand),
          ),
          .url(
            'https://x.com',
            leading: Icon(FontAwesomeIcons.x_twitter_brand),
          ),
        ],
      ),
    ),
  ),
  sidebar: () => context.url.contains('/docs') ? Sidebar() : null,
);
