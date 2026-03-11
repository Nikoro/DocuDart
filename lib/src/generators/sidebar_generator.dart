import 'package:docudart/src/models/doc.dart';
import 'package:docudart/src/processing/content_processor.dart';

/// Generates sidebar structure from documentation pages.
abstract final class SidebarGenerator {
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

      final DocPage(:sidebarTitle, :urlPath, :order) = page;
      items.add(DocLink(name: sidebarTitle, path: urlPath, order: order));
    }

    // Add subfolders as categories
    for (final subfolder in folder.folders) {
      final children = _generateFromFolder(subfolder);
      if (children.isNotEmpty) {
        final DocFolder(:name, :expanded, :order) = subfolder;
        items.add(
          DocCategory(
            name: name,
            children: children,
            expanded: expanded,
            order: order,
          ),
        );
      }
    }

    return items;
  }
}
