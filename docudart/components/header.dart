import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [leading] slot is typically a [Logo].
///
/// Uses [context.screen] to show a [SidebarToggle] on mobile/tablet
/// when [showSidebarToggle] is true (e.g., on pages with a sidebar).
///
/// On desktop, nav links appear inline in the main row.
/// On mobile/tablet, they appear in a second scrollable row below.
class Header extends StatelessComponent {
  const Header({
    this.leading,
    this.links,
    this.trailing,
    this.showSidebarToggle = false,
    super.key,
  });

  final Component? leading;
  final List<Link>? links;
  final Component? trailing;

  /// Whether to show the sidebar toggle button on mobile/tablet.
  final bool showSidebarToggle;

  @override
  Component build(BuildContext context) {
    return header([
      Column(
        crossAxisAlignment: .stretch,
        children: [
          // Main row: hamburger + logo + spacer + desktop links + trailing
          Row(
            crossAxisAlignment: .center,
            spacing: 1.5.rem,
            children: [
              // Show hamburger menu on mobile/tablet when sidebar is present
              if (showSidebarToggle)
                ?context.screen.maybeWhen(
                  mobile: () => SidebarToggle(),
                  tablet: () => SidebarToggle(),
                ),
              ?leading,
              Spacer(),
              // Nav links only on desktop — inline in main row
              ?context.screen.maybeWhen(
                desktop: () => Row(
                  spacing: 1.5.rem,
                  mainAxisSize: MainAxisSize.min,
                  children: [...?links],
                ),
              ),
              ?trailing,
            ],
          ).apply(classes: 'header-main-row'),
          // Mobile/tablet nav row — below the main header row
          if (links != null && links!.isNotEmpty)
            ?context.screen.maybeWhen(
              mobile: () => Row(spacing: 1.rem, children: [...?links]).apply(
                styles: Styles(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ).toSpacing(),
                  overflow: .only(x: .auto),
                ),
              ),
              tablet: () => Row(spacing: 1.rem, children: [...?links]).apply(
                styles: Styles(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ).toSpacing(),
                  overflow: .only(x: .auto),
                ),
              ),
            ),
        ],
      ),
    ]);
  }
}
