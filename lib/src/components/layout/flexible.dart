import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'package:docudart/src/extensions/component_extensions.dart';

/// Whether a [Flexible] child should fill available space tightly or loosely.
enum FlexFit {
  /// The child is forced to fill its share of available space.
  tight,

  /// The child can be at most as large as the available space but may be smaller.
  loose,
}

/// A component that controls how a child of a [Row] or [Column] flexes.
///
/// Uses `.apply()` to merge flex styles directly onto the child — no wrapper div.
///
/// When [fit] is [FlexFit.tight], the child is forced to fill available
/// space proportional to [flex] (equivalent to [Expanded]).
/// When [fit] is [FlexFit.loose], the child can use up to the available
/// space but is not forced to fill it.
///
/// **Note**: Do not chain `.apply()` on a `Flexible` or `Expanded` instance.
/// Instead, combine flex and other styles in a single `.apply()` call.
class Flexible extends StatelessComponent {
  const Flexible({
    this.flex = 1,
    this.fit = FlexFit.loose,
    required this.child,
    super.key,
  });

  /// The flex factor. Determines how much remaining space this child
  /// receives relative to other flex children.
  final int flex;

  /// Whether the child fills available space tightly or loosely.
  final FlexFit fit;

  /// The child component to wrap.
  final Component child;

  @override
  Component build(BuildContext context) {
    return child.apply(
      styles: Styles(
        flex: fit == .tight
            ? Flex(grow: flex.toDouble(), shrink: 0, basis: Unit.zero)
            : Flex.grow(flex.toDouble()),
      ),
    );
  }
}
