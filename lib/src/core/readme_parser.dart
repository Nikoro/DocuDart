import 'dart:io';

/// Represents a section parsed from a README file.
class ReadmeSection {
  /// Section title.
  final String title;

  /// Section content (markdown).
  final String content;

  /// Heading level (1-6).
  final int level;

  /// Suggested filename for this section.
  final String filename;

  /// Order/position in the document.
  final int position;

  const ReadmeSection({
    required this.title,
    required this.content,
    required this.level,
    required this.filename,
    required this.position,
  });
}

/// Parses README.md files and extracts sections for documentation.
class ReadmeParser {
  /// Parse a README file and return a list of sections.
  ///
  /// The parser will:
  /// - Extract sections based on ## headings (level 2)
  /// - Preserve content before first heading as "Introduction"
  /// - Handle badges and shields (common at the top of READMEs)
  /// - Skip certain sections (like license, contributing, etc.)
  static List<ReadmeSection> parse(String content) {
    final sections = <ReadmeSection>[];
    final lines = content.split('\n');

    String? currentTitle;
    int currentLevel = 2;
    final buffer = StringBuffer();
    int position = 1;

    // Track if we've seen any real content (not badges/shields)
    bool hasIntroContent = false;
    final introBuffer = StringBuffer();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check for heading
      final headingMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);

      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final title = headingMatch.group(2)!.trim();

        // H3-H6 are subsections, include in current section (don't create new section)
        if (level > 2) {
          if (currentTitle != null) {
            buffer.writeln(line);
          } else {
            introBuffer.writeln(line);
          }
          continue;
        }

        // Save previous section (only for H1 and H2)
        if (currentTitle != null && buffer.isNotEmpty) {
          final sectionContent = buffer.toString().trim();
          if (sectionContent.isNotEmpty && !_shouldSkipSection(currentTitle)) {
            sections.add(
              ReadmeSection(
                title: currentTitle,
                content: sectionContent,
                level: currentLevel,
                filename: _generateFilename(currentTitle, position),
                position: position,
              ),
            );
            position++;
          }
        }

        // Start new section (only track level 2 headings as main sections)
        if (level == 2) {
          currentTitle = title;
          currentLevel = level;
          buffer.clear();
        } else if (level == 1) {
          // H1 is usually the project title - skip it but add content before it
          // to introduction if there's any
          if (introBuffer.isNotEmpty && hasIntroContent) {
            final introContent = _cleanIntroContent(introBuffer.toString());
            if (introContent.isNotEmpty) {
              sections.insert(
                0,
                ReadmeSection(
                  title: 'Introduction',
                  content: introContent,
                  level: 2,
                  filename: 'index',
                  position: 0,
                ),
              );
            }
          }
          currentTitle = null;
          buffer.clear();
        }
      } else {
        // Regular content
        if (currentTitle != null) {
          buffer.writeln(line);
        } else {
          // Before any ## heading
          if (!_isBadgeLine(line) && line.trim().isNotEmpty) {
            hasIntroContent = true;
          }
          introBuffer.writeln(line);
        }
      }
    }

    // Save last section
    if (currentTitle != null && buffer.isNotEmpty) {
      final sectionContent = buffer.toString().trim();
      if (sectionContent.isNotEmpty && !_shouldSkipSection(currentTitle)) {
        sections.add(
          ReadmeSection(
            title: currentTitle,
            content: sectionContent,
            level: currentLevel,
            filename: _generateFilename(currentTitle, position),
            position: position,
          ),
        );
      }
    }

    // If no sections found but we have intro content, use that
    if (sections.isEmpty && introBuffer.isNotEmpty) {
      final introContent = _cleanIntroContent(introBuffer.toString());
      if (introContent.isNotEmpty) {
        sections.add(
          ReadmeSection(
            title: 'Introduction',
            content: introContent,
            level: 2,
            filename: 'index',
            position: 1,
          ),
        );
      }
    }

    // Add Introduction at the start if we have content and no existing intro
    if (sections.isNotEmpty &&
        hasIntroContent &&
        !sections.any((s) => s.filename == 'index')) {
      final introContent = _cleanIntroContent(introBuffer.toString());
      if (introContent.isNotEmpty) {
        // Renumber existing sections
        final renumbered = sections
            .map(
              (s) => ReadmeSection(
                title: s.title,
                content: s.content,
                level: s.level,
                filename: s.filename,
                position: s.position + 1,
              ),
            )
            .toList();

        return [
          ReadmeSection(
            title: 'Introduction',
            content: introContent,
            level: 2,
            filename: 'index',
            position: 1,
          ),
          ...renumbered,
        ];
      }
    }

    return sections;
  }

  /// Parse a README file from a file path.
  static Future<List<ReadmeSection>> parseFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return [];
    }
    final content = await file.readAsString();
    return parse(content);
  }

  /// Check if a line contains only badges/shields.
  static bool _isBadgeLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;

    // Badge patterns: [![...](...)(...)] or ![...](...)
    final badgePattern = RegExp(
      r'^\[?\!\[[^\]]*\]\([^)]+\)(?:\([^)]*\))?\]?(\s*\[?\!\[[^\]]*\]\([^)]+\)(?:\([^)]*\))?\]?)*\s*$',
    );

    return badgePattern.hasMatch(trimmed);
  }

  /// Clean introduction content by removing badges and extra whitespace.
  static String _cleanIntroContent(String content) {
    final lines = content.split('\n');
    final cleaned = <String>[];
    bool foundContent = false;

    for (final line in lines) {
      // Skip badges at the start
      if (!foundContent && _isBadgeLine(line)) {
        continue;
      }
      // Skip H1 titles
      if (line.trim().startsWith('# ')) {
        continue;
      }

      if (line.trim().isNotEmpty) {
        foundContent = true;
      }

      if (foundContent) {
        cleaned.add(line);
      }
    }

    // Trim leading/trailing empty lines
    while (cleaned.isNotEmpty && cleaned.first.trim().isEmpty) {
      cleaned.removeAt(0);
    }
    while (cleaned.isNotEmpty && cleaned.last.trim().isEmpty) {
      cleaned.removeLast();
    }

    return cleaned.join('\n');
  }

  /// Check if a section should be skipped based on its title.
  static bool _shouldSkipSection(String title) {
    final skipTitles = [
      'license',
      'licence',
      'contributing',
      'contributors',
      'authors',
      'acknowledgements',
      'acknowledgments',
      'changelog',
      'change log',
      'support',
      'sponsors',
      'backers',
    ];

    final lowerTitle = title.toLowerCase();
    return skipTitles.any((skip) => lowerTitle.contains(skip));
  }

  /// Generate a filename from a section title.
  static String _generateFilename(String title, int position) {
    // Special case for first section
    if (position == 1 ||
        title.toLowerCase() == 'introduction' ||
        title.toLowerCase() == 'overview') {
      return 'index';
    }

    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
