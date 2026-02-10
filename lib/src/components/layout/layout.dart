import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

/// The default page layout component for DocuDart.
///
/// Arranges [header], [sidebar], [body], and [footer] in the standard
/// DocuDart page structure. All parameters are optional — omitted sections
/// are simply not rendered.
///
/// When no [sidebar] is provided, the `.no-sidebar` class is added to
/// `.site-body` so CSS can adjust the main content area.
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
    return div(classes: 'layout', [
      ?header,
      div(classes: sidebar != null ? 'site-body' : 'site-body no-sidebar', [
        ?sidebar,
        div(classes: 'site-main', attributes: {'role': 'main'}, [?body]),
      ]),
      ?footer,
    ]);
  }
}
