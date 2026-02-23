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
      crossAxisAlignment: .stretch,
      children: [
        a(classes: 'skip-to-content', href: '#main-content', [
          .text('Skip to content'),
        ]),
        ?header,
        if (hasSidebar)
          button(
            classes: 'mobile-menu-btn',
            attributes: {
              'aria-label': 'Open navigation menu',
              'title': 'Open navigation menu',
            },
            [
              RawText(
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" '
                'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
                '<line x1="3" y1="6" x2="21" y2="6"/>'
                '<line x1="3" y1="12" x2="21" y2="12"/>'
                '<line x1="3" y1="18" x2="21" y2="18"/>'
                '</svg>',
              ),
            ],
          ),
        Expanded(
          child:
              Row(
                mainAxisAlignment: hasSidebar ? .start : .center,
                crossAxisAlignment: hasSidebar ? .start : .center,
                children: [
                  ?sidebar,
                  ?body?.apply(
                    id: 'main-content',
                    classes: 'site-main',
                    styles: Styles(
                      flex: Flex(grow: 1, shrink: 1, basis: Unit.zero),
                    ),
                    attributes: {'role': 'main'},
                  ),
                ],
              ).apply(
                styles: Styles(
                  height: 100.percent,
                  maxWidth: hasSidebar ? 1400.px : 100.percent,
                  margin: .symmetric(horizontal: .auto),
                ),
              ),
        ),
        ?footer,
        if (hasSidebar) div(classes: 'sidebar-backdrop', []),
      ],
    ).apply(styles: Styles(minHeight: 100.vh));
  }
}
