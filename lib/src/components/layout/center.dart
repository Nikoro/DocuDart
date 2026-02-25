import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A widget that centers its child.
///
/// Mirrors Flutter's `Center` widget. Renders a flex container with
/// centered alignment.
///
/// ```dart
/// Center(child: Text('Centered content'))
/// ```
class Center extends StatelessComponent {
  const Center({required this.child, super.key});

  /// The widget below this widget in the tree.
  final Component child;

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: Display.flex,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
      ),
      [child],
    );
  }
}
