import 'package:docudart/docudart.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'landing-page',
      [
        div(
          classes: 'hero',
          [
            h1([.text('example_project')]),
            p(
              classes: 'hero-description',
              [.text('An example Dart project to demonstrate DocuDart documentation generator.')],
            ),
            div(
              classes: 'hero-actions',
              [
                a(
                  href: '/docs',
                  classes: 'button button-primary',
                  [.text('Get Started')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
