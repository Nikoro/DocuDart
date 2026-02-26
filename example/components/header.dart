import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [leading] slot is typically a [Logo].
///
/// Uses [context.screen] to show a [SidebarToggle] on mobile/tablet
/// when [showSidebarToggle] is true (e.g., on pages with a sidebar).
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
          ...?links,
          ?trailing,
        ],
      ),
    ]);
  }
}
