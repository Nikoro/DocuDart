import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'box_decoration.dart';
import 'edge_insets.dart';

/// A convenience widget that combines common painting, positioning,
/// and sizing widgets.
///
/// Mirrors Flutter's `Container` widget. Renders a `<div>` with inline styles.
///
/// ```dart
/// Container(
///   width: 200,
///   height: 100,
///   padding: EdgeInsets.all(16),
///   decoration: BoxDecoration(
///     color: 0xFFF5F5F5,
///     borderRadius: BorderRadius.circular(8),
///   ),
///   child: Text('Hello'),
/// )
/// ```
class Container extends StatelessComponent {
  const Container({
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
    this.constraints,
    this.child,
    super.key,
  });

  /// Fixed width in pixels.
  final double? width;

  /// Fixed height in pixels.
  final double? height;

  /// Inner padding.
  final EdgeInsets? padding;

  /// Outer margin.
  final EdgeInsets? margin;

  /// Background color (ARGB int). Cannot be used with [decoration].
  final int? color;

  /// Box decoration (background, border, shadow, border radius).
  final BoxDecoration? decoration;

  /// Alignment of the child within the container.
  final Alignment? alignment;

  /// Additional constraints (min/max width/height).
  final BoxConstraints? constraints;

  /// The widget below this widget in the tree.
  final Component? child;

  @override
  Component build(BuildContext context) {
    final css = <String, String>{
      if (width != null) 'width': '${width}px',
      if (height != null) 'height': '${height}px',
      if (color != null)
        'background-color':
            '#${(color! & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      if (alignment != null) ...{
        'display': 'flex',
        'justify-content': alignment!.justifyContent,
        'align-items': alignment!.alignItems,
      },
      if (decoration != null) ...decoration!.toCssProperties(),
      if (constraints != null) ...constraints!.toCssProperties(),
    };

    return div(
      styles: Styles(
        padding: padding?.toSpacing(),
        margin: margin?.toSpacing(),
        raw: css.isNotEmpty ? css : null,
      ),
      [?child],
    );
  }
}
