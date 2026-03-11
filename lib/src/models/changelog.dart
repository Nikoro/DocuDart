import 'package:meta/meta.dart';

import 'package:docudart/src/models/toc_entry.dart';

/// Parsed changelog data from the parent project's CHANGELOG.md.
///
/// Access via `context.project.changelog`:
/// ```dart
/// final html = context.project.changelog?.raw;
/// final entries = context.project.changelog?.toc;
/// ```
@immutable
class Changelog {
  const Changelog({required this.raw, this.toc = const []});

  /// Pre-processed HTML content of the changelog.
  final String raw;

  /// Table of contents entries extracted from changelog headings.
  final List<TocEntry> toc;
}
