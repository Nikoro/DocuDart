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
  final Component? image;
  final String? title;
  final String href;

  const Logo({this.image, this.title, this.href = '/', super.key})
    : assert(image != null || title != null);

  @override
  Component build(BuildContext context) {
    return a(
      href: href,
      classes: 'logo',
      [
        if (image != null) span(classes: 'logo-image', [image!]),
        if (title != null) span(classes: 'logo-title', [.text(title!)]),
      ],
    );
  }
}
