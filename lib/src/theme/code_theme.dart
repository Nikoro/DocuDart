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

  /// dart.dev light mode — extracted from dart.dev's opal highlighter.
  const CodeTheme.dartDevLight({
    this.background = 0xFFF9FAFB,
    this.foreground = 0xFF191C22,
    this.keyword = 0xFF146BCD,
    this.string = 0xFF0C7064,
    this.comment = 0xFF59616E,
    this.number = 0xFF146BCD,
    this.type = 0xFF146BCD,
    this.function_ = 0xFF6200EE,
    this.variable = 0xFFBD2314,
    this.literal = 0xFF146BCD,
    this.operator_ = 0xFF191C22,
    this.punctuation = 0xFF191C22,
    this.annotation = 0xFF6200EE,
    this.lineHighlight = 0xFFF0F1F3,
  });

  /// dart.dev dark mode — extracted from dart.dev's opal highlighter.
  const CodeTheme.dartDevDark({
    this.background = 0xFF202731,
    this.foreground = 0xFFDCDCDC,
    this.keyword = 0xFF6BB1FF,
    this.string = 0xFF1CDAC5,
    this.comment = 0xFF8B95A7,
    this.number = 0xFF6BB1FF,
    this.type = 0xFF6BB1FF,
    this.function_ = 0xFFB581FF,
    this.variable = 0xFFFF897E,
    this.literal = 0xFF6BB1FF,
    this.operator_ = 0xFFDCDCDC,
    this.punctuation = 0xFFDCDCDC,
    this.annotation = 0xFFB581FF,
    this.lineHighlight = 0xFF2A3240,
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

  /// Convert a 0xAARRGGBB color int to a CSS hex string (e.g. `#1a2b3c`).
  static String toHex(int color) =>
      '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

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
