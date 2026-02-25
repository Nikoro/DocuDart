import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A small status indicator badge.
///
/// ```dart
/// Badge(label: 'New')
/// Badge(label: 'v2.0', color: 0xFF28A745)
/// ```
class Badge extends StatelessComponent {
  const Badge({required this.label, this.color, this.textColor, super.key});

  /// Badge text.
  final String label;

  /// Background color (ARGB int). Null uses primary color.
  final int? color;

  /// Text color (ARGB int). Null uses white.
  final int? textColor;

  @override
  Component build(BuildContext context) {
    final bg = color != null
        ? '#${(color! & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        : 'var(--color-primary)';
    final fg = textColor != null
        ? '#${(textColor! & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        : '#fff';

    return span(
      styles: Styles(
        raw: {
          'display': 'inline-flex',
          'align-items': 'center',
          'padding': '0.125rem 0.5rem',
          'font-size': '0.75rem',
          'font-weight': '500',
          'border-radius': '9999px',
          'background-color': bg,
          'color': fg,
          'line-height': '1.5',
        },
      ),
      [.text(label)],
    );
  }
}
