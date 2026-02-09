import 'package:docudart/docudart.dart';

/// A clickable logo component with an optional image and/or title.
///
/// At least one of [image] or [title] must be provided.
/// Links to [href] (defaults to `"/"`).
///
/// ```dart
/// Logo(title: 'My Project')
/// Logo(image: img(src: '/assets/logo.svg', alt: 'Logo'))
/// Logo(image: img(src: '/assets/logo.svg', alt: 'Logo'), title: 'My Project')
/// ```
class Logo extends StatelessComponent {
  const Logo({this.image, this.title, this.href = '/', super.key})
    : assert(image != null || title != null);
  final Component? image;
  final String? title;
  final String href;

  @override
  Component build(BuildContext context) {
    return a(href: href, classes: 'logo', [
      ?image.let((it) => span(classes: 'logo-image', [it])),
      ?title.let((it) => span(classes: 'logo-title', [.text(it)])),
    ]);
  }
}
