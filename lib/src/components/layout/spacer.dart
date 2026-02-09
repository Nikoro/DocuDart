import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

/// A component that occupies flexible empty space in a [Row] or [Column].
///
/// Takes up available space proportional to its [flex] factor.
class Spacer extends StatelessComponent {
  /// The flex factor. Higher values take proportionally more space.
  final int flex;

  const Spacer({this.flex = 1, super.key});

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        flex: Flex(grow: flex.toDouble(), shrink: 0, basis: Unit.zero),
      ),
      [],
    );
  }
}
