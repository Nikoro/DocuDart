import 'package:docudart/docudart.dart';

/// The default page layout component for DocuDart.
///
/// Arranges [header], [sidebar], [body], and [footer] in the standard
/// DocuDart page structure. All parameters are optional — omitted sections
/// are simply not rendered.
///
/// When no [sidebar] is provided, the body content expands to full width
/// and is centered.
class Layout extends StatelessComponent {
  const Layout({this.header, this.sidebar, this.body, this.footer, super.key});

  /// Optional header component rendered at the top.
  final Component? header;

  /// Optional sidebar component rendered alongside the body.
  final Component? sidebar;

  /// The main content component.
  final Component? body;

  /// Optional footer component rendered at the bottom.
  final Component? footer;

  @override
  Component build(BuildContext context) {
    final hasSidebar = sidebar != null;

    return Column(
      children: [
        ?header,
        Expanded(
          child:
              Row(
                mainAxisAlignment: hasSidebar ? .start : .center,
                crossAxisAlignment: hasSidebar ? .start : .center,
                children: [
                  ?sidebar,
                  ?body?.apply(
                    classes: 'site-main',
                    styles: hasSidebar
                        ? null
                        : Styles(maxWidth: 100.percent, padding: .zero),
                    attributes: {'role': 'main'},
                  ),
                ],
              ).apply(
                styles: Styles(
                  maxWidth: hasSidebar ? 1400.px : 100.percent,
                  margin: .symmetric(horizontal: .auto),
                ),
              ),
        ),
        ?footer,
      ],
    ).apply(styles: Styles(minHeight: 100.vh));
  }
}
