import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'helpers.dart';

class Icon extends StatelessComponent {
  const Icon(
    this.icon, {
    this.height,
    this.width,
    this.viewBox,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.strokeLineJoin,
    this.strokeLineCap,
    this.classes,
    this.id,
    this.styles,
    this.attributes,
    this.events,
  });

  /// The icon data to render.
  final IconData icon;

  /// The height of the icon.
  final Unit? height;

  /// The width of the icon.
  final Unit? width;

  /// The viewBox of the icon. If null, uses the viewBox from [IconData] root
  /// attrs, or falls back to `0 0 24 24`.
  final (double, double, double, double)? viewBox;

  /// The fill color of the icon.
  final Color? fill;

  /// The stroke color of the icon.
  final Color? stroke;

  /// The stroke width of the icon.
  final String? strokeWidth;

  /// The stroke line join of the icon.
  final StrokeLineJoin? strokeLineJoin;

  /// The stroke line cap of the icon.
  final StrokeLineCap? strokeLineCap;

  /// CSS classes to be applied to the SVG element.
  final String? classes;

  /// The HTML `id` attribute for the SVG element.
  final String? id;

  /// Inline CSS styles to be applied to the SVG element.
  final Styles? styles;

  /// Additional attributes to be applied to the SVG element.
  final Map<String, String>? attributes;

  /// Events to be applied to the SVG element.
  final Map<String, EventCallback>? events;

  @override
  Component build(BuildContext context) {
    final root = icon.content.elementAtOrNull(0);
    final hasRoot = root?['tag'] == 'root';
    final rootAttrs = hasRoot
        ? root!['attrs'] as Map<String, String>
        : <String, String>{};

    // Resolve viewBox: explicit parameter > root attrs > default 0 0 24 24
    final resolvedViewBox = viewBox != null
        ? '${viewBox!.$1} ${viewBox!.$2} ${viewBox!.$3} ${viewBox!.$4}'
        : rootAttrs['viewBox'] ?? '0 0 24 24';

    return svg(
      _parseChildren(),
      viewBox: resolvedViewBox,
      width: width,
      height: height,
      key: key,
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        // Default fill for icons without root attrs (e.g. Material Icons).
        // Root attrs or explicit parameters override this.
        if (!rootAttrs.containsKey('fill')) 'fill': 'currentColor',
        // Spread root attrs but exclude viewBox (handled as dedicated param)
        for (final e in rootAttrs.entries)
          if (e.key != 'viewBox') e.key: e.value,
        'fill': ?fill?.value,
        'stroke': ?stroke?.value,
        'stroke-width': ?strokeWidth,
        'stroke-linejoin': ?strokeLineJoin?.value,
        'stroke-linecap': ?strokeLineCap?.value,
        ...?attributes,
      },
      events: events,
    );
  }

  List<Component> _parseChildren() => [
    for (final element in icon.content)
      if (element['tag'] != 'root')
        Component.element(
          tag: element['tag'] as String,
          attributes: {...element['attrs'] as Map<String, String>},
        ),
  ];
}
