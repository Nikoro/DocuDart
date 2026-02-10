import 'package:docudart/docudart.dart';

/// A component that occupies flexible empty space in a [Row] or [Column].
///
/// Takes up available space proportional to its [flex] factor.
class Spacer extends StatelessComponent {
  const Spacer({this.flex = 1, super.key});

  /// The flex factor. Higher values take proportionally more space.
  final int flex;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'spacer',
      styles: flex != 1
          ? Styles(
              flex: Flex(grow: flex.toDouble(), shrink: 0, basis: Unit.zero),
            )
          : null,
      [],
    );
  }
}
