import 'package:docudart/docudart.dart';

import '../config.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    final title = config.title;
    final description = config.description;
    return div(classes: 'landing-page', [
      div(classes: 'hero', [
        if (title != null) h1([.text(title)]),
        if (description != null) p(classes: 'hero-description', [.text(description)]),
        div(classes: 'hero-actions', [
          a(href: '/docs', classes: 'button button-primary', [.text('Get Started')]),
        ]),
      ]),
    ]);
  }
}
