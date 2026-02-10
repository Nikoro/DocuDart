import '../models/doc.dart';
import '../processing/content_processor.dart';

/// Generates sidebar structure from documentation pages.
class SidebarGenerator {
  /// Generate [Doc] items from the docs folder structure.
  static List<Doc> generate({required DocFolder rootFolder}) {
    return _generateFromFolder(rootFolder);
  }

  static List<Doc> _generateFromFolder(DocFolder folder) {
    final items = <Doc>[];

    // Add pages from this folder
    for (final page in folder.pages) {
      // Skip pages that shouldn't be in sidebar
      if (!page.meta.showInSidebar) continue;

      items.add(
        DocLink(name: page.sidebarTitle, path: page.urlPath, order: page.order),
      );
    }

    // Add subfolders as categories
    for (final subfolder in folder.folders) {
      final children = _generateFromFolder(subfolder);
      if (children.isNotEmpty) {
        items.add(
          DocCategory(
            name: subfolder.name,
            children: children,
            expanded: subfolder.expanded,
            order: subfolder.order,
          ),
        );
      }
    }

    return items;
  }
}
