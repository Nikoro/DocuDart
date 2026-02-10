import 'package:meta/meta.dart';

/// A documentation navigation item in the sidebar tree.
///
/// [Doc] is a sealed class with two subtypes:
/// - [DocLink] for navigable documentation pages
/// - [DocCategory] for collapsible category groups
@immutable
sealed class Doc {
  const Doc({required this.name, required this.order});

  /// Display name shown in the sidebar.
  final String name;

  /// Sort order (from filename prefix or frontmatter sidebar_position).
  final int order;
}

/// A navigable documentation page link.
@immutable
class DocLink extends Doc {
  const DocLink({required super.name, required this.path, super.order = 0});

  /// URL path for this page (e.g., '/docs/getting-started').
  final String path;
}

/// A collapsible category group containing child [Doc] items.
@immutable
class DocCategory extends Doc {
  const DocCategory({
    required super.name,
    required this.children,
    this.expanded = false,
    super.order = 0,
  });

  /// Child navigation items.
  final List<Doc> children;

  /// Whether this category starts expanded in the sidebar.
  ///
  /// Derived from the `_expanded` suffix on folder names
  /// (e.g., `01-guides_expanded/`).
  final bool expanded;
}
