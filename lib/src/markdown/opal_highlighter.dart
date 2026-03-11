import 'dart:convert';

import 'package:opal/opal.dart';

import 'package:docudart/src/theme/code_theme.dart';

/// Build-time syntax highlighter using the opal package.
///
/// Tokenizes code blocks during site generation and produces inline-styled
/// `<span>` elements with dual light/dark color values — the same approach
/// used by dart.dev. Dark mode is toggled via a single CSS rule that reads
/// the `--dd-dark-color` custom property from each span's inline style.
class OpalHighlighter {
  OpalHighlighter({required this.lightTheme, required this.darkTheme});

  final CodeTheme lightTheme;
  final CodeTheme darkTheme;

  final LanguageRegistry _registry = LanguageRegistry.withDefaults();

  static final _codeBlockPattern = RegExp(
    r'<pre><code class="language-(\S+?)">([\s\S]*?)</code></pre>',
  );

  /// Process all code blocks in the given HTML string.
  String highlightHtml(String html) {
    return html.replaceAllMapped(_codeBlockPattern, (match) {
      final lang = match.group(1)!;
      final rawCode = _unescapeHtml(match.group(2)!);
      return highlightCodeBlock(rawCode, lang);
    });
  }

  /// Highlight a single code block.
  ///
  /// Returns the full `<pre class="opal"><code>...</code></pre>` HTML.
  String highlightCodeBlock(String code, String language) {
    final lang = _registry[language];

    if (lang == null) {
      // Unsupported language: emit as plain text with opal structure.
      return '<pre class="opal"><code class="language-$language">'
          '${_escapeHtml(code)}'
          '</code></pre>';
    }

    final lines = const LineSplitter().convert(code);
    final tokenizedLines = lang.tokenize(lines);

    final buffer = StringBuffer()
      ..write('<pre class="opal"><code class="language-$language">');

    for (int i = 0; i < tokenizedLines.length; i++) {
      for (final token in tokenizedLines[i]) {
        if (token.content.isEmpty) continue;

        final pair = _resolveColorPair(token.tags);
        if (pair != null) {
          buffer
            ..write('<span style="color: ')
            ..write(pair.$1)
            ..write('; --dd-dark-color: ')
            ..write(pair.$2)
            ..write(';">')
            ..write(_escapeHtml(token.content))
            ..write('</span>');
        } else {
          buffer.write(_escapeHtml(token.content));
        }
      }
      if (i < tokenizedLines.length - 1) buffer.write('\n');
    }

    buffer.write('</code></pre>');
    return buffer.toString();
  }

  /// Resolve a tag list to a (lightColor, darkColor) pair.
  ///
  /// Tags are ordered least-to-most specific. Walk from the most specific
  /// end so the best match wins.
  (String, String)? _resolveColorPair(List<Tag> tags) {
    for (int i = tags.length - 1; i >= 0; i--) {
      final pair = _tagToColorPair(tags[i]);
      if (pair != null) return pair;
    }
    return null;
  }

  (String, String)? _tagToColorPair(Tag tag) {
    if (_isComment(tag)) {
      return (_rgba(lightTheme.comment), _rgba(darkTheme.comment));
    }
    if (_isStringEscapeOrInterpolation(tag)) {
      return (_rgba(lightTheme.string), _rgba(darkTheme.string));
    }
    if (_isString(tag)) {
      return (_rgba(lightTheme.string), _rgba(darkTheme.string));
    }
    if (_isAnnotation(tag)) {
      return (_rgba(lightTheme.annotation), _rgba(darkTheme.annotation));
    }
    if (_isNumber(tag)) {
      return (_rgba(lightTheme.number), _rgba(darkTheme.number));
    }
    if (_isLiteral(tag)) {
      return (_rgba(lightTheme.literal), _rgba(darkTheme.literal));
    }
    if (_isKeyword(tag)) {
      return (_rgba(lightTheme.keyword), _rgba(darkTheme.keyword));
    }
    if (_isFunction(tag)) {
      return (_rgba(lightTheme.function_), _rgba(darkTheme.function_));
    }
    if (_isType(tag)) {
      return (_rgba(lightTheme.type), _rgba(darkTheme.type));
    }
    if (_isPunctuation(tag)) {
      return (_rgba(lightTheme.punctuation), _rgba(darkTheme.punctuation));
    }
    if (_isVariable(tag)) {
      return (_rgba(lightTheme.variable), _rgba(darkTheme.variable));
    }
    return null;
  }

  // --- Tag matchers ---
  //
  // Opal uses hierarchical tags: e.g. `var` is tagged as
  // `Tag('var', parent: Tags.keyword)`, not `Tags.declarationKeyword`.
  // We must walk the parent chain to match correctly.

  static bool _matchesRoot(Tag tag, Tag root) {
    Tag? current = tag;
    while (current != null) {
      if (current == root) return true;
      current = current.parent;
    }
    return false;
  }

  static bool _isComment(Tag tag) => _matchesRoot(tag, Tags.comment);

  static bool _isString(Tag tag) => _matchesRoot(tag, Tags.stringLiteral);

  static bool _isStringEscapeOrInterpolation(Tag tag) =>
      tag == Tags.stringEscape || tag == Tags.stringInterpolation;

  static bool _isNumber(Tag tag) => _matchesRoot(tag, Tags.numberLiteral);

  static bool _isLiteral(Tag tag) => _matchesRoot(tag, Tags.literal);

  static bool _isKeyword(Tag tag) => _matchesRoot(tag, Tags.keyword);

  static bool _isFunction(Tag tag) =>
      tag == Tags.function || _matchesRoot(tag, Tags.function);

  static bool _isType(Tag tag) => _matchesRoot(tag, Tags.type);

  static bool _isVariable(Tag tag) => _matchesRoot(tag, Tags.variable);

  static bool _isPunctuation(Tag tag) => _matchesRoot(tag, Tags.punctuation);

  static bool _isAnnotation(Tag tag) => _matchesRoot(tag, Tags.metadata);

  // --- Helpers ---

  static String _rgba(int color) {
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    return 'rgba($r, $g, $b, 1.0)';
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  static String _unescapeHtml(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}
