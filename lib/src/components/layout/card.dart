import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A material design card.
///
/// Mirrors Flutter's `Card` widget. Uses theme defaults from [CardTheme].
///
/// ```dart
/// Card(child: Text('Card content'))
/// Card(
///   elevation: 4,
///   borderRadius: 12,
///   child: Column(children: [
///     Text('Title'),
///     Text('Description'),
///   ]),
/// )
/// ```
class Card extends StatelessComponent {
  const Card({
    required this.child,
    this.elevation,
    this.borderRadius,
    this.color,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Component child;

  /// Elevation (shadow depth). Null uses theme default.
  final double? elevation;

  /// Border radius in pixels. Null uses theme default.
  final double? borderRadius;

  /// Background color (ARGB int). Null uses theme default.
  final int? color;

  @override
  Component build(BuildContext context) {
    final bgColor = color != null
        ? '#${(color! & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        : null;

    return div(
      classes: 'card',
      styles: Styles(
        raw: {
          if (borderRadius != null) 'border-radius': '${borderRadius}px',
          if (bgColor != null) 'background-color': bgColor,
          if (elevation != null && elevation! > 0)
            'box-shadow':
                '0 ${(elevation! / 2).round()}px ${elevation!.round()}px rgba(0, 0, 0, 0.1)',
        },
      ),
      [child],
    );
  }
}
