import 'package:docudart/docudart.dart';

import '../components/button.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    final title = context.project.pubspec.name;
    final description = context.project.pubspec.description;
    return Column(
      mainAxisAlignment: .center,
      spacing: 1.5.rem,
      children: [
        Logo(image: context.project.assets.logo.logo_webp()),
        ?title.let((t) => h1([.text(t)])),
        ?description.let((d) => p(classes: 'description', [.text(d)])),
        Button.primary(text: 'Get Started', href: '/docs'),
      ],
    ).apply(classes: 'landing-page');
  }
}
