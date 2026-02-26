import 'package:docudart/docudart.dart';

/// Site sidebar component.
///
/// Customize this component to change the sidebar layout.
/// The [DefaultSidebar] renders a navigation tree from the docs structure.
/// The [items] are auto-generated from your docs/ folder.
class Sidebar extends StatelessComponent {
  const Sidebar({super.key});

  @override
  Component build(BuildContext context) {
    return DefaultSidebar(items: context.project.docs);
  }
}
