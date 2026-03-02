import 'package:meta/meta.dart';

/// An entry in a table of contents, extracted from document headings.
@immutable
class TocEntry {
  const TocEntry({required this.text, required this.level, required this.id});

  /// Heading text content.
  final String text;

  /// Heading level (1-6).
  final int level;

  /// Anchor ID for linking (URL-safe slug).
  final String id;
}
