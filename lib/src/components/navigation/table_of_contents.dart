import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../../models/toc_entry.dart';

/// A table of contents component that renders a sticky navigation panel
/// from heading entries, similar to dart.dev's "On this page" sidebar.
///
/// ```dart
/// TableOfContents(entries: context.project.changelog?.toc ?? [])
/// ```
///
/// Typically placed alongside content in a row layout. Hidden on screens
/// narrower than 1024px via CSS.
class TableOfContents extends StatelessComponent {
  const TableOfContents({
    required this.entries,
    this.title = 'On this page',
    this.minLevel = 2,
    this.maxLevel = 3,
    super.key,
  });

  /// TOC entries to display.
  final List<TocEntry> entries;

  /// Title text shown above the TOC list.
  final String title;

  /// Minimum heading level to include (default: 2, skips h1).
  final int minLevel;

  /// Maximum heading level to include (default: 3, shows h2 and h3).
  final int maxLevel;

  @override
  Component build(BuildContext context) {
    final filtered = entries
        .where((e) => e.level >= minLevel && e.level <= maxLevel)
        .toList();

    if (filtered.isEmpty) return Component.fragment([]);

    return aside(classes: 'toc', [
      nav(
        classes: 'toc-nav',
        attributes: {'aria-label': 'Table of contents'},
        [
          div(classes: 'toc-title', [.text(title)]),
          ul(classes: 'toc-list', [
            for (final entry in filtered)
              li(classes: 'toc-item toc-level-${entry.level}', [
                a(
                  href: '#${entry.id}',
                  classes: 'toc-link',
                  attributes: {'data-toc-id': entry.id},
                  [.text(entry.text)],
                ),
              ]),
          ]),
        ],
      ),
    ]);
  }
}
