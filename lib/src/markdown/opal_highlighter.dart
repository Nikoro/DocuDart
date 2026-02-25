import 'dart:convert';

import 'package:opal/opal.dart';

import '../theme/code_theme.dart';

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

    for (var i = 0; i < tokenizedLines.length; i++) {
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
    for (var i = tags.length - 1; i >= 0; i--) {
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
      return (_rgba(lightTheme.variable), _rgba(darkTheme.variable));
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
    if (_isOperator(tag)) {
      return (_rgba(lightTheme.operator_), _rgba(darkTheme.operator_));
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
  // Each checks the tag and walks up its parent chain.

  static bool _isComment(Tag tag) =>
      tag == Tags.comment ||
      tag == Tags.lineComment ||
      tag == Tags.blockComment ||
      tag == Tags.docComment ||
      tag == Tags.commentReference;

  static bool _isString(Tag tag) =>
      tag == Tags.stringLiteral ||
      tag == Tags.quotedString ||
      tag == Tags.singleQuoteString ||
      tag == Tags.doubleQuoteString ||
      tag == Tags.tripleQuoteString ||
      tag == Tags.stringContent ||
      tag == Tags.unquotedString ||
      tag == Tags.characterLiteral ||
      tag == Tags.regexpLiteral;

  static bool _isStringEscapeOrInterpolation(Tag tag) =>
      tag == Tags.stringEscape || tag == Tags.stringInterpolation;

  static bool _isNumber(Tag tag) =>
      tag == Tags.numberLiteral ||
      tag == Tags.integerLiteral ||
      tag == Tags.floatLiteral;

  static bool _isLiteral(Tag tag) =>
      tag == Tags.literal ||
      tag == Tags.booleanLiteral ||
      tag == Tags.trueLiteral ||
      tag == Tags.falseLiteral ||
      tag == Tags.nullLiteral;

  static bool _isKeyword(Tag tag) =>
      tag == Tags.keyword ||
      tag == Tags.declarationKeyword ||
      tag == Tags.modifierKeyword ||
      tag == Tags.controlKeyword;

  static bool _isOperator(Tag tag) =>
      tag == Tags.operator || tag == Tags.customOperator;

  static bool _isFunction(Tag tag) =>
      tag == Tags.function || tag == Tags.constructor;

  static bool _isType(Tag tag) => tag == Tags.type || tag == Tags.builtInType;

  static bool _isVariable(Tag tag) =>
      tag == Tags.variable ||
      tag == Tags.parameter ||
      tag == Tags.identifier ||
      tag == Tags.privateIdentifier ||
      tag == Tags.specialIdentifier ||
      tag == Tags.property;

  static bool _isPunctuation(Tag tag) =>
      tag == Tags.punctuation || tag == Tags.separator || tag == Tags.accessor;

  static bool _isAnnotation(Tag tag) =>
      tag == Tags.annotation ||
      tag == Tags.metadata ||
      tag == Tags.preprocessor ||
      tag == Tags.preprocessorDirective;

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
