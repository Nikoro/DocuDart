import 'package:docudart/docudart.dart';

import '../components/button.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  final String? title;
  final String? description;

  const LandingPage({this.title, this.description, super.key});

  @override
  Component build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 1.5.rem,
      children: [
        ?title.let((t) => h1([.text(t)])),
        ?description.let((d) => p(classes: 'description', [.text(d)])),
        Button.primary(text: 'Get Started', href: '/docs'),
      ],
    ).apply(classes: 'landing-page');
  }
}
