import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A horizontal line divider.
///
/// Mirrors Flutter's `Divider` widget. Renders an `<hr>` element.
///
/// ```dart
/// Divider()
/// Divider(thickness: 2, color: Colors.grey)
/// Divider(indent: 16, endIndent: 16)
/// ```
class Divider extends StatelessComponent {
  const Divider({
    this.height,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
    super.key,
  });

  /// Total height of the divider space (not the line thickness).
  final double? height;

  /// Thickness of the line in pixels.
  final double? thickness;

  /// Color of the line (ARGB int).
  final int? color;

  /// Left indent in pixels.
  final double? indent;

  /// Right indent in pixels.
  final double? endIndent;

  @override
  Component build(BuildContext context) {
    final borderColor = color != null
        ? '#${(color! & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        : 'var(--color-border)';

    return hr(
      styles: Styles(
        raw: {
          'border': 'none',
          'border-top': '${thickness ?? 1}px solid $borderColor',
          if (height != null) 'margin': '${height! / 2}px 0',
          if (indent != null) 'margin-left': '${indent}px',
          if (endIndent != null) 'margin-right': '${endIndent}px',
        },
      ),
    );
  }
}
