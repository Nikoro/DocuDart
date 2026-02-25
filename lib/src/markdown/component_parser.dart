/// Represents an embedded component found in markdown.
class EmbeddedComponent {
  const EmbeddedComponent({
    required this.name,
    required this.props,
    this.children,
    required this.placeholderId,
    required this.position,
  });

  /// Component name (e.g., 'Callout', 'Tabs').
  final String name;

  /// Component properties as key-value pairs.
  final Map<String, dynamic> props;

  /// Child content (for components with children).
  final String? children;

  /// Placeholder ID used in the processed content.
  final String placeholderId;

  /// Original position in the content.
  final int position;
}

/// Result of parsing components from markdown content.
class ComponentParseResult {
  const ComponentParseResult({required this.content, required this.components});

  /// Content with components replaced by placeholders.
  final String content;

  /// List of extracted components.
  final List<EmbeddedComponent> components;
}

/// Parses MDX-like component syntax from markdown content.
///
/// Supports:
/// - Self-closing: `<Component prop="value" />`
/// - With children: `<Component prop="value">children</Component>`
/// - Nested components
abstract final class ComponentParser {
  /// Pattern for self-closing components: `<Component prop="value" />`
  static final _selfClosingPattern = RegExp(
    r'<([A-Z][a-zA-Z0-9]*)\s*([^>]*?)\s*/>',
    multiLine: true,
  );

  /// Pattern for components with children: `<Component>...</Component>`
  static final _withChildrenPattern = RegExp(
    r'<([A-Z][a-zA-Z0-9]*)\s*([^>]*)>([\s\S]*?)</\1>',
    multiLine: true,
  );

  /// Pattern for parsing props: prop="value" or prop={value}
  ///
  /// **Limitation**: Does not support escaped quotes in string props
  /// (e.g. `prop="value with \" quote"`) or nested braces (`prop={{nested}}`).
  /// Built-in components don't use these patterns, but custom components
  /// should avoid them.
  static final _propPattern = RegExp(r'(\w+)=(?:"([^"]*)"|{([^}]*)}|(\S+))');

  /// Parse components from markdown content.
  ///
  /// Returns content with placeholders and a list of extracted components.
  static ComponentParseResult parse(String content) {
    final components = <EmbeddedComponent>[];
    String processedContent = content;
    int placeholderIndex = 0;

    // First pass: extract components with children (to handle nesting)
    processedContent = processedContent.replaceAllMapped(_withChildrenPattern, (
      match,
    ) {
      final name = match.group(1)!;
      final propsString = match.group(2) ?? '';
      final children = match.group(3);
      final placeholderId = '___COMPONENT_${placeholderIndex}___';

      components.add(
        EmbeddedComponent(
          name: name,
          props: _parseProps(propsString),
          children: children?.trim(),
          placeholderId: placeholderId,
          position: match.start,
        ),
      );

      placeholderIndex++;
      return '\n\n<div data-component="$placeholderId"></div>\n\n';
    });

    // Second pass: extract self-closing components
    processedContent = processedContent.replaceAllMapped(_selfClosingPattern, (
      match,
    ) {
      final name = match.group(1)!;
      final propsString = match.group(2) ?? '';
      final placeholderId = '___COMPONENT_${placeholderIndex}___';

      components.add(
        EmbeddedComponent(
          name: name,
          props: _parseProps(propsString),
          children: null,
          placeholderId: placeholderId,
          position: match.start,
        ),
      );

      placeholderIndex++;
      return '\n\n<div data-component="$placeholderId"></div>\n\n';
    });

    return ComponentParseResult(
      content: processedContent,
      components: components,
    );
  }

  /// Parse props string into a map.
  static Map<String, dynamic> _parseProps(String propsString) {
    final props = <String, dynamic>{};

    for (final match in _propPattern.allMatches(propsString)) {
      final key = match.group(1)!;
      final stringValue = match.group(2); // quoted value
      final expressionValue = match.group(3); // braced expression
      final plainValue = match.group(4); // unquoted plain value

      if (stringValue != null) {
        props[key] = stringValue;
      } else if (expressionValue != null) {
        props[key] = _parseExpression(expressionValue);
      } else if (plainValue != null) {
        props[key] = _parseExpression(plainValue);
      }
    }

    return props;
  }

  /// Parse a prop expression value.
  static dynamic _parseExpression(String expression) {
    final trimmed = expression.trim();

    // Boolean
    if (trimmed == 'true') return true;
    if (trimmed == 'false') return false;

    // Number
    final intValue = int.tryParse(trimmed);
    if (intValue != null) return intValue;

    final doubleValue = double.tryParse(trimmed);
    if (doubleValue != null) return doubleValue;

    // Bracket-delimited list
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      final inner = trimmed.substring(1, trimmed.length - 1);
      return inner
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map(_parseExpression)
          .toList();
    }

    // Quoted text — strip surrounding quotes
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      return trimmed.substring(1, trimmed.length - 1);
    }

    // Return as string
    return trimmed;
  }

  /// Check if a component name is a built-in component.
  static bool isBuiltIn(String name) {
    return const {
      'Callout',
      'Tabs',
      'Tab',
      'CodeBlock',
      'Card',
      'CardGrid',
    }.contains(name);
  }
}
