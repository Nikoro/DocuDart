import 'package:meta/meta.dart';

/// Syntax highlighting color theme for code blocks.
///
/// Defines colors for highlight.js token classes. Each field maps to a
/// `.hljs-*` CSS selector. All colors are int values in 0xAARRGGBB format.
///
/// Use predefined factories for popular themes:
/// ```dart
/// CodeTheme.githubDark()
/// CodeTheme.githubLight()
/// CodeTheme.dracula()
/// CodeTheme.nord()
/// CodeTheme.nightOwl()
/// ```
@immutable
class CodeTheme {
  const CodeTheme({
    required this.background,
    required this.foreground,
    required this.keyword,
    required this.string,
    required this.comment,
    required this.number,
    required this.type,
    required this.function_,
    required this.variable,
    required this.literal,
    required this.operator_,
    required this.punctuation,
    required this.annotation,
    this.lineHighlight,
  });

  /// GitHub dark mode colors.
  const CodeTheme.githubDark({
    this.background = 0xFF0D1117,
    this.foreground = 0xFFE6EDF3,
    this.keyword = 0xFFFF7B72,
    this.string = 0xFFA5D6FF,
    this.comment = 0xFF8B949E,
    this.number = 0xFF79C0FF,
    this.type = 0xFFFFA657,
    this.function_ = 0xFFD2A8FF,
    this.variable = 0xFFFFA657,
    this.literal = 0xFF79C0FF,
    this.operator_ = 0xFFFF7B72,
    this.punctuation = 0xFFE6EDF3,
    this.annotation = 0xFFD2A8FF,
    this.lineHighlight = 0xFF161B22,
  });

  /// GitHub light mode colors.
  const CodeTheme.githubLight({
    this.background = 0xFFFFFFFF,
    this.foreground = 0xFF24292E,
    this.keyword = 0xFFD73A49,
    this.string = 0xFF032F62,
    this.comment = 0xFF6A737D,
    this.number = 0xFF005CC5,
    this.type = 0xFFE36209,
    this.function_ = 0xFF6F42C1,
    this.variable = 0xFFE36209,
    this.literal = 0xFF005CC5,
    this.operator_ = 0xFFD73A49,
    this.punctuation = 0xFF24292E,
    this.annotation = 0xFF6F42C1,
    this.lineHighlight = 0xFFF6F8FA,
  });

  /// Dracula theme colors.
  const CodeTheme.dracula({
    this.background = 0xFF282A36,
    this.foreground = 0xFFF8F8F2,
    this.keyword = 0xFFFF79C6,
    this.string = 0xFFF1FA8C,
    this.comment = 0xFF6272A4,
    this.number = 0xFFBD93F9,
    this.type = 0xFF8BE9FD,
    this.function_ = 0xFF50FA7B,
    this.variable = 0xFFF8F8F2,
    this.literal = 0xFFBD93F9,
    this.operator_ = 0xFFFF79C6,
    this.punctuation = 0xFFF8F8F2,
    this.annotation = 0xFF50FA7B,
    this.lineHighlight = 0xFF44475A,
  });

  /// Nord theme colors.
  const CodeTheme.nord({
    this.background = 0xFF2E3440,
    this.foreground = 0xFFD8DEE9,
    this.keyword = 0xFF81A1C1,
    this.string = 0xFFA3BE8C,
    this.comment = 0xFF616E88,
    this.number = 0xFFB48EAD,
    this.type = 0xFF8FBCBB,
    this.function_ = 0xFF88C0D0,
    this.variable = 0xFFD8DEE9,
    this.literal = 0xFF81A1C1,
    this.operator_ = 0xFF81A1C1,
    this.punctuation = 0xFFECEFF4,
    this.annotation = 0xFFD08770,
    this.lineHighlight = 0xFF3B4252,
  });

  /// Night Owl theme by Sarah Drasner.
  const CodeTheme.nightOwl({
    this.background = 0xFF011627,
    this.foreground = 0xFFD6DEEB,
    this.keyword = 0xFFC792EA,
    this.string = 0xFFECC48D,
    this.comment = 0xFF637777,
    this.number = 0xFFF78C6C,
    this.type = 0xFFFFCB8B,
    this.function_ = 0xFF82AAFF,
    this.variable = 0xFFD6DEEB,
    this.literal = 0xFFFF5874,
    this.operator_ = 0xFF7FDBCA,
    this.punctuation = 0xFFD6DEEB,
    this.annotation = 0xFF82AAFF,
    this.lineHighlight = 0xFF0B2942,
  });

  factory CodeTheme.fromJson(Map<String, dynamic> json) => CodeTheme(
    background: json['background'] as int,
    foreground: json['foreground'] as int,
    keyword: json['keyword'] as int,
    string: json['string'] as int,
    comment: json['comment'] as int,
    number: json['number'] as int,
    type: json['type'] as int,
    function_: json['function_'] as int,
    variable: json['variable'] as int,
    literal: json['literal'] as int,
    operator_: json['operator_'] as int,
    punctuation: json['punctuation'] as int,
    annotation: json['annotation'] as int,
    lineHighlight: json['lineHighlight'] as int?,
  );

  /// Code block background.
  final int background;

  /// Default text color.
  final int foreground;

  /// Language keywords (if, for, class, return, etc.).
  final int keyword;

  /// String literals.
  final int string;

  /// Comments.
  final int comment;

  /// Numeric literals.
  final int number;

  /// Type names (int, String, List, etc.).
  final int type;

  /// Function / method names.
  final int function_;

  /// Variable names.
  final int variable;

  /// Literal values (true, false, null).
  final int literal;

  /// Operators (=, +, ==, =>).
  final int operator_;

  /// Punctuation ({, }, (, ), ;).
  final int punctuation;

  /// Annotations / decorators (@override, @immutable).
  final int annotation;

  /// Highlighted line background (optional).
  final int? lineHighlight;

  static String _hex(int color) =>
      '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// Generate CSS rules for highlight.js token classes.
  ///
  /// If [selector] is provided, rules are scoped under it
  /// (e.g. `:root[data-theme="dark"]`).
  String toCss({String? selector}) {
    final prefix = selector != null ? '$selector ' : '';
    return '''
$prefix.hljs { background: ${_hex(background)}; color: ${_hex(foreground)}; }
$prefix.code-block-wrapper pre { background-color: ${_hex(background)}; }
$prefix.hljs-keyword { color: ${_hex(keyword)}; }
$prefix.hljs-string { color: ${_hex(string)}; }
$prefix.hljs-comment { color: ${_hex(comment)}; font-style: italic; }
$prefix.hljs-number { color: ${_hex(number)}; }
$prefix.hljs-type,
$prefix.hljs-built_in { color: ${_hex(type)}; }
$prefix.hljs-title.function_,
$prefix.hljs-function { color: ${_hex(function_)}; }
$prefix.hljs-variable { color: ${_hex(variable)}; }
$prefix.hljs-literal { color: ${_hex(literal)}; }
$prefix.hljs-operator { color: ${_hex(operator_)}; }
$prefix.hljs-punctuation { color: ${_hex(punctuation)}; }
$prefix.hljs-meta,
$prefix.hljs-doctag { color: ${_hex(annotation)}; }
$prefix.hljs-attr { color: ${_hex(type)}; }
$prefix.hljs-params { color: ${_hex(foreground)}; }
$prefix.hljs-section,
$prefix.hljs-title { color: ${_hex(keyword)}; font-weight: 600; }
$prefix.hljs-symbol { color: ${_hex(literal)}; }
$prefix.hljs-addition { color: ${_hex(string)}; }
$prefix.hljs-deletion { color: ${_hex(keyword)}; }''';
  }

  CodeTheme copyWith({
    int? background,
    int? foreground,
    int? keyword,
    int? string,
    int? comment,
    int? number,
    int? type,
    int? function_,
    int? variable,
    int? literal,
    int? operator_,
    int? punctuation,
    int? annotation,
    int? lineHighlight,
  }) => CodeTheme(
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    keyword: keyword ?? this.keyword,
    string: string ?? this.string,
    comment: comment ?? this.comment,
    number: number ?? this.number,
    type: type ?? this.type,
    function_: function_ ?? this.function_,
    variable: variable ?? this.variable,
    literal: literal ?? this.literal,
    operator_: operator_ ?? this.operator_,
    punctuation: punctuation ?? this.punctuation,
    annotation: annotation ?? this.annotation,
    lineHighlight: lineHighlight ?? this.lineHighlight,
  );

  Map<String, dynamic> toJson() => {
    'background': background,
    'foreground': foreground,
    'keyword': keyword,
    'string': string,
    'comment': comment,
    'number': number,
    'type': type,
    'function_': function_,
    'variable': variable,
    'literal': literal,
    'operator_': operator_,
    'punctuation': punctuation,
    'annotation': annotation,
    'lineHighlight': ?lineHighlight,
  };
}
