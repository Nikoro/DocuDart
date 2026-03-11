import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import 'package:docudart/src/components/interaction/icon_button.dart';
import 'package:docudart/src/icons/icons.dart';

/// A client-side button that toggles the mobile sidebar drawer.
///
/// Uses Jaspr's `@client` annotation for client-side hydration.
/// On the client, the [onPressed] callback toggles the `sidebar-open`
/// class on `<body>`, which CSS uses to show/hide the sidebar drawer.
///
/// ```dart
/// context.screen.maybeWhen(
///   mobile: () => SidebarToggle(),
///   tablet: () => SidebarToggle(),
///   orElse: () => SizedBox.shrink(),
/// )
/// ```
@client
class SidebarToggle extends StatelessComponent {
  const SidebarToggle({super.key});

  @override
  Component build(BuildContext context) {
    return IconButton(
      icon: Icon(MaterialSymbols.menu),
      tooltip: 'Open navigation menu',
      padding: Padding.zero,
      onPressed: () {
        if (kIsWeb) {
          web.document.body?.classList.toggle('sidebar-open');
        }
      },
    );
  }
}
