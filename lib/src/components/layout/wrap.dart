import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A widget that displays its children in a wrapping flow layout.
///
/// Mirrors Flutter's `Wrap` widget. Renders a flex container with
/// `flex-wrap: wrap`.
///
/// ```dart
/// Wrap(
///   spacing: 8,
///   runSpacing: 8,
///   children: [Chip(label: 'Dart'), Chip(label: 'Flutter')],
/// )
/// ```
class Wrap extends StatelessComponent {
  const Wrap({
    required this.children,
    this.spacing,
    this.runSpacing,
    super.key,
  });

  /// The widgets to arrange in a wrapping layout.
  final List<Component> children;

  /// Horizontal spacing between children in pixels.
  final double? spacing;

  /// Vertical spacing between runs in pixels.
  final double? runSpacing;

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: Display.flex,
        flexWrap: FlexWrap.wrap,
        gap: spacing != null || runSpacing != null
            ? Gap(
                column: spacing != null ? Unit.pixels(spacing!) : null,
                row: runSpacing != null ? Unit.pixels(runSpacing!) : null,
              )
            : null,
      ),
      children,
    );
  }
}
