import 'package:yaml/yaml.dart';

/// Result of parsing frontmatter from markdown content.
class FrontmatterResult {
  const FrontmatterResult({required this.data, required this.content});

  /// Parsed frontmatter data as a map.
  final Map<String, dynamic> data;

  /// Markdown content without the frontmatter.
  final String content;
}

/// Metadata extracted from frontmatter.
class PageMeta {
  const PageMeta({
    this.title,
    this.description,
    this.sidebarPosition,
    this.sidebarTitle,
    this.showInSidebar = true,
    this.tags = const [],
    this.slug,
  });

  /// Parse PageMeta from frontmatter data map.
  factory PageMeta.fromMap(Map<String, dynamic> map) {
    return PageMeta(
      title: map['title'] as String?,
      description: map['description'] as String?,
      sidebarPosition: map['sidebar_position'] as int?,
      sidebarTitle: map['sidebar_title'] as String?,
      showInSidebar: map['sidebar'] as bool? ?? true,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      slug: map['slug'] as String?,
    );
  }

  /// Page title (used in sidebar and browser title).
  final String? title;

  /// Page description (used for SEO).
  final String? description;

  /// Position in sidebar (lower = higher).
  final int? sidebarPosition;

  /// Override title shown in sidebar.
  final String? sidebarTitle;

  /// Whether to show in sidebar.
  final bool showInSidebar;

  /// Tags for categorization.
  final List<String> tags;

  /// Custom slug override.
  final String? slug;

  /// Convert to map for serialization.
  Map<String, dynamic> toMap() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (sidebarPosition != null) 'sidebar_position': sidebarPosition,
    if (sidebarTitle != null) 'sidebar_title': sidebarTitle,
    if (!showInSidebar) 'sidebar': showInSidebar,
    if (tags.isNotEmpty) 'tags': tags,
    if (slug != null) 'slug': slug,
  };
}

/// Handles parsing YAML frontmatter from markdown files.
class FrontmatterHandler {
  /// Regular expression to match frontmatter block.
  /// Matches content between --- delimiters at the start of the file.
  static final _frontmatterRegex = RegExp(
    r'^---\s*\n([\s\S]*?)\n---\s*\n([\s\S]*)$',
    multiLine: true,
  );

  /// Parse frontmatter from markdown content.
  ///
  /// Returns a [FrontmatterResult] with the parsed data and remaining content.
  /// If no frontmatter is found, returns empty data and original content.
  static FrontmatterResult parse(String content) {
    // Normalize line endings (Windows CRLF → LF) before parsing.
    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final match = _frontmatterRegex.firstMatch(content);

    if (match == null) {
      return FrontmatterResult(data: {}, content: content);
    }

    final yamlContent = match.group(1)!;
    final markdownContent = match.group(2)!;

    try {
      final yaml = loadYaml(yamlContent);
      final data = yaml is YamlMap
          ? Map<String, dynamic>.from(yaml)
          : <String, dynamic>{};

      return FrontmatterResult(data: data, content: markdownContent);
    } catch (e) {
      // If YAML parsing fails, return empty data and original content
      return FrontmatterResult(data: {}, content: content);
    }
  }

  /// Parse frontmatter and return PageMeta.
  static (PageMeta, String) parseWithMeta(String content) {
    final result = parse(content);
    final meta = PageMeta.fromMap(result.data);
    return (meta, result.content);
  }

  /// Generate frontmatter string from a map.
  static String generate(Map<String, dynamic> data) {
    if (data.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('---');

    for (final entry in data.entries) {
      final value = entry.value;
      if (value is List) {
        buffer.writeln('${entry.key}: [${value.join(', ')}]');
      } else if (value is String && value.contains('\n')) {
        buffer.writeln('${entry.key}: |');
        for (final line in value.split('\n')) {
          buffer.writeln('  $line');
        }
      } else {
        buffer.writeln('${entry.key}: $value');
      }
    }

    buffer.writeln('---');
    return buffer.toString();
  }
}
