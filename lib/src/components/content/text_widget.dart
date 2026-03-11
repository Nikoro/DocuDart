import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'package:docudart/src/theme/text_style.dart' as dd;

/// A run of text with optional style.
///
/// Mirrors Flutter's `Text` widget. Renders a `<span>` with optional
/// inline styles from [TextStyle].
///
/// ```dart
/// Text('Hello, world!')
/// Text('Bold text', style: TextStyle(fontWeight: 700))
/// Text('Large', style: TextStyle(fontSize: 2.0))
/// ```
class Text extends StatelessComponent {
  const Text(this.data, {this.style, super.key});

  /// The text to display.
  final String data;

  /// Optional text style.
  final dd.TextStyle? style;

  @override
  Component build(BuildContext context) {
    if (style == null) {
      return span([.text(data)]);
    }

    final cssProps = style!.toCssProperties();
    return span(styles: Styles(raw: cssProps), [.text(data)]);
  }
}
