import 'package:docudart/docudart.dart';

import '../components/button.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 1.5.rem,
      children: [
        Logo(image: context.project.assets.logo.logo_webp()),
        h1([.text('DocuDart')]),
        p(classes: 'description', [
          .text('A static documentation generator for Dart, powered by '),
          Link.url('https://pub.dev/packages/jaspr', label: 'Jaspr'),
          .text('.'),
        ]),
        Button.primary(text: 'Get Started', href: '/docs'),
      ],
    ).apply(classes: 'landing-page');
  }
}
