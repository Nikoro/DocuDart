import 'package:docudart/docudart.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  final String? title;
  final String? description;

  const LandingPage({this.title, this.description, super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'landing-page', [
      div(classes: 'hero', [
        if (title != null) h1([.text(title!)]),
        if (description != null) p(classes: 'hero-description', [.text(description!)]),
        div(classes: 'hero-actions', [
          a(href: '/docs', classes: 'button button-primary', [.text('Get Started')]),
        ]),
      ]),
    ]);
  }
}
