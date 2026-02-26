import 'package:docudart/docudart.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
///
/// Uses [context.screen] to switch between horizontal (desktop) and
/// vertical (mobile/tablet) layout.
class Footer extends StatelessComponent {
  const Footer({this.leading, this.center, this.trailing, super.key});

  final Component? leading;
  final Component? center;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return footer([
      context.screen.when(
        desktop: () => Row(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .center,
          children: [?leading, ?center, ?trailing],
        ).apply(styles: Styles(raw: {'color': 'var(--color-text-muted)'})),
        tablet: () => Column(
          spacing: 1.5.rem,
          children: [?center, ?leading, ?trailing],
        ).apply(styles: Styles(raw: {'text-align': 'center'})),
        mobile: () => Column(
          spacing: 1.5.rem,
          children: [?center, ?leading, ?trailing],
        ).apply(styles: Styles(raw: {'text-align': 'center'})),
      ),
    ]);
  }
}
