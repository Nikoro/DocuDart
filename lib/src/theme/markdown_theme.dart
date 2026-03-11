import 'package:meta/meta.dart';

import 'package:docudart/src/theme/code_theme.dart';

/// Styling for markdown-rendered content.
///
/// Controls spacing, border radii, and visual treatment of markdown elements
/// (headings, blockquotes, tables, code blocks, links, etc.).
@immutable
class MarkdownTheme {
  const MarkdownTheme({
    this.linkDecoration = 'none',
    this.linkHoverDecoration = 'underline',
    this.blockquoteBorderWidth = 4,
    this.blockquotePaddingLeft = 1.0,
    this.codeInlinePaddingH = 0.4,
    this.codeInlinePaddingV = 0.2,
    this.codeInlineBorderRadius = 0.25,
    this.codeBlockPadding = 1.0,
    this.codeBlockBorderRadius = 0.5,
    this.tableCellPadding = 0.75,
    this.imageBorderRadius = 0.5,
    this.hrMarginY = 2.0,
    this.paragraphMarginBottom = 1.0,
    this.listMarginBottom = 1.0,
    this.listItemMarginBottom = 0.5,
    this.listPaddingLeft = 1.5,
    this.h1MarginBottom = 1.5,
    this.h1PaddingBottom = 0.75,
    this.h1HasBorderBottom = true,
    this.h2MarginTop = 2.5,
    this.h2MarginBottom = 1.0,
    this.h3MarginTop = 2.0,
    this.h3MarginBottom = 0.75,
    this.h4MarginTop = 1.5,
    this.h4MarginBottom = 0.5,
    this.lightCodeTheme = const CodeTheme.githubLight(),
    this.darkCodeTheme = const CodeTheme.githubDark(),
  });

  /// dart.dev / flutter.dev style markdown.
  const MarkdownTheme.classic({
    this.linkDecoration = 'none',
    this.linkHoverDecoration = 'underline',
    this.blockquoteBorderWidth = 4,
    this.blockquotePaddingLeft = 1.0,
    this.codeInlinePaddingH = 0.4,
    this.codeInlinePaddingV = 0.2,
    this.codeInlineBorderRadius = 0.25,
    this.codeBlockPadding = 1.0,
    this.codeBlockBorderRadius = 0.5,
    this.tableCellPadding = 0.75,
    this.imageBorderRadius = 0.5,
    this.hrMarginY = 2.0,
    this.paragraphMarginBottom = 1.0,
    this.listMarginBottom = 1.0,
    this.listItemMarginBottom = 0.5,
    this.listPaddingLeft = 1.5,
    this.h1MarginBottom = 1.5,
    this.h1PaddingBottom = 0.75,
    this.h1HasBorderBottom = true,
    this.h2MarginTop = 2.5,
    this.h2MarginBottom = 1.0,
    this.h3MarginTop = 2.0,
    this.h3MarginBottom = 0.75,
    this.h4MarginTop = 1.5,
    this.h4MarginBottom = 0.5,
    this.lightCodeTheme = const CodeTheme.dartDevLight(),
    this.darkCodeTheme = const CodeTheme.dartDevDark(),
  });

  /// Material Design 3 — rounder corners, more relaxed spacing.
  const MarkdownTheme.material3({
    this.linkDecoration = 'none',
    this.linkHoverDecoration = 'underline',
    this.blockquoteBorderWidth = 3,
    this.blockquotePaddingLeft = 1.0,
    this.codeInlinePaddingH = 0.4,
    this.codeInlinePaddingV = 0.2,
    this.codeInlineBorderRadius = 0.375,
    this.codeBlockPadding = 1.25,
    this.codeBlockBorderRadius = 0.75,
    this.tableCellPadding = 0.875,
    this.imageBorderRadius = 0.75,
    this.hrMarginY = 2.5,
    this.paragraphMarginBottom = 1.0,
    this.listMarginBottom = 1.0,
    this.listItemMarginBottom = 0.5,
    this.listPaddingLeft = 1.5,
    this.h1MarginBottom = 1.5,
    this.h1PaddingBottom = 0.75,
    this.h1HasBorderBottom = false,
    this.h2MarginTop = 2.5,
    this.h2MarginBottom = 1.0,
    this.h3MarginTop = 2.0,
    this.h3MarginBottom = 0.75,
    this.h4MarginTop = 1.5,
    this.h4MarginBottom = 0.5,
    this.lightCodeTheme = const CodeTheme.githubLight(),
    this.darkCodeTheme = const CodeTheme.nord(),
  });

  /// shadcn/ui — tight spacing, sharp radii.
  const MarkdownTheme.shadcn({
    this.linkDecoration = 'underline',
    this.linkHoverDecoration = 'underline',
    this.blockquoteBorderWidth = 2,
    this.blockquotePaddingLeft = 1.0,
    this.codeInlinePaddingH = 0.4,
    this.codeInlinePaddingV = 0.2,
    this.codeInlineBorderRadius = 0.25,
    this.codeBlockPadding = 1.0,
    this.codeBlockBorderRadius = 0.375,
    this.tableCellPadding = 0.75,
    this.imageBorderRadius = 0.375,
    this.hrMarginY = 2.0,
    this.paragraphMarginBottom = 1.0,
    this.listMarginBottom = 1.0,
    this.listItemMarginBottom = 0.375,
    this.listPaddingLeft = 1.5,
    this.h1MarginBottom = 1.0,
    this.h1PaddingBottom = 0.5,
    this.h1HasBorderBottom = true,
    this.h2MarginTop = 2.5,
    this.h2MarginBottom = 0.75,
    this.h3MarginTop = 2.0,
    this.h3MarginBottom = 0.5,
    this.h4MarginTop = 1.5,
    this.h4MarginBottom = 0.5,
    this.lightCodeTheme = const CodeTheme.githubLight(),
    this.darkCodeTheme = const CodeTheme.nightOwl(),
  });

  factory MarkdownTheme.fromJson(Map<String, dynamic> json) => .new(
    linkDecoration: json['linkDecoration'] as String? ?? 'none',
    linkHoverDecoration: json['linkHoverDecoration'] as String? ?? 'underline',
    blockquoteBorderWidth:
        (json['blockquoteBorderWidth'] as num?)?.toDouble() ?? 4,
    blockquotePaddingLeft:
        (json['blockquotePaddingLeft'] as num?)?.toDouble() ?? 1.0,
    codeInlinePaddingH: (json['codeInlinePaddingH'] as num?)?.toDouble() ?? 0.4,
    codeInlinePaddingV: (json['codeInlinePaddingV'] as num?)?.toDouble() ?? 0.2,
    codeInlineBorderRadius:
        (json['codeInlineBorderRadius'] as num?)?.toDouble() ?? 0.25,
    codeBlockPadding: (json['codeBlockPadding'] as num?)?.toDouble() ?? 1.0,
    codeBlockBorderRadius:
        (json['codeBlockBorderRadius'] as num?)?.toDouble() ?? 0.5,
    tableCellPadding: (json['tableCellPadding'] as num?)?.toDouble() ?? 0.75,
    imageBorderRadius: (json['imageBorderRadius'] as num?)?.toDouble() ?? 0.5,
    hrMarginY: (json['hrMarginY'] as num?)?.toDouble() ?? 2.0,
    paragraphMarginBottom:
        (json['paragraphMarginBottom'] as num?)?.toDouble() ?? 1.0,
    listMarginBottom: (json['listMarginBottom'] as num?)?.toDouble() ?? 1.0,
    listItemMarginBottom:
        (json['listItemMarginBottom'] as num?)?.toDouble() ?? 0.5,
    listPaddingLeft: (json['listPaddingLeft'] as num?)?.toDouble() ?? 1.5,
    h1MarginBottom: (json['h1MarginBottom'] as num?)?.toDouble() ?? 1.5,
    h1PaddingBottom: (json['h1PaddingBottom'] as num?)?.toDouble() ?? 0.75,
    h1HasBorderBottom: json['h1HasBorderBottom'] as bool? ?? true,
    h2MarginTop: (json['h2MarginTop'] as num?)?.toDouble() ?? 2.5,
    h2MarginBottom: (json['h2MarginBottom'] as num?)?.toDouble() ?? 1.0,
    h3MarginTop: (json['h3MarginTop'] as num?)?.toDouble() ?? 2.0,
    h3MarginBottom: (json['h3MarginBottom'] as num?)?.toDouble() ?? 0.75,
    h4MarginTop: (json['h4MarginTop'] as num?)?.toDouble() ?? 1.5,
    h4MarginBottom: (json['h4MarginBottom'] as num?)?.toDouble() ?? 0.5,
    lightCodeTheme: json['lightCodeTheme'] != null
        ? CodeTheme.fromJson(json['lightCodeTheme'] as Map<String, dynamic>)
        : const CodeTheme.githubLight(),
    darkCodeTheme: json['darkCodeTheme'] != null
        ? CodeTheme.fromJson(json['darkCodeTheme'] as Map<String, dynamic>)
        : const CodeTheme.githubDark(),
  );

  // --- Link ---
  final String linkDecoration;
  final String linkHoverDecoration;

  // --- Blockquote ---
  final double blockquoteBorderWidth;
  final double blockquotePaddingLeft;

  // --- Code ---
  final double codeInlinePaddingH;
  final double codeInlinePaddingV;
  final double codeInlineBorderRadius;
  final double codeBlockPadding;
  final double codeBlockBorderRadius;

  // --- Table ---
  final double tableCellPadding;

  // --- Image ---
  final double imageBorderRadius;

  // --- Horizontal Rule ---
  final double hrMarginY;

  // --- Paragraph ---
  final double paragraphMarginBottom;

  // --- Lists ---
  final double listMarginBottom;
  final double listItemMarginBottom;
  final double listPaddingLeft;

  // --- Heading Spacing ---
  final double h1MarginBottom;
  final double h1PaddingBottom;
  final bool h1HasBorderBottom;
  final double h2MarginTop;
  final double h2MarginBottom;
  final double h3MarginTop;
  final double h3MarginBottom;
  final double h4MarginTop;
  final double h4MarginBottom;

  // --- Syntax Highlighting ---

  /// Code theme for light mode.
  final CodeTheme lightCodeTheme;

  /// Code theme for dark mode.
  final CodeTheme darkCodeTheme;

  MarkdownTheme copyWith({
    String? linkDecoration,
    String? linkHoverDecoration,
    double? blockquoteBorderWidth,
    double? blockquotePaddingLeft,
    double? codeInlinePaddingH,
    double? codeInlinePaddingV,
    double? codeInlineBorderRadius,
    double? codeBlockPadding,
    double? codeBlockBorderRadius,
    double? tableCellPadding,
    double? imageBorderRadius,
    double? hrMarginY,
    double? paragraphMarginBottom,
    double? listMarginBottom,
    double? listItemMarginBottom,
    double? listPaddingLeft,
    double? h1MarginBottom,
    double? h1PaddingBottom,
    bool? h1HasBorderBottom,
    double? h2MarginTop,
    double? h2MarginBottom,
    double? h3MarginTop,
    double? h3MarginBottom,
    double? h4MarginTop,
    double? h4MarginBottom,
    CodeTheme? lightCodeTheme,
    CodeTheme? darkCodeTheme,
  }) => .new(
    linkDecoration: linkDecoration ?? this.linkDecoration,
    linkHoverDecoration: linkHoverDecoration ?? this.linkHoverDecoration,
    blockquoteBorderWidth: blockquoteBorderWidth ?? this.blockquoteBorderWidth,
    blockquotePaddingLeft: blockquotePaddingLeft ?? this.blockquotePaddingLeft,
    codeInlinePaddingH: codeInlinePaddingH ?? this.codeInlinePaddingH,
    codeInlinePaddingV: codeInlinePaddingV ?? this.codeInlinePaddingV,
    codeInlineBorderRadius:
        codeInlineBorderRadius ?? this.codeInlineBorderRadius,
    codeBlockPadding: codeBlockPadding ?? this.codeBlockPadding,
    codeBlockBorderRadius: codeBlockBorderRadius ?? this.codeBlockBorderRadius,
    tableCellPadding: tableCellPadding ?? this.tableCellPadding,
    imageBorderRadius: imageBorderRadius ?? this.imageBorderRadius,
    hrMarginY: hrMarginY ?? this.hrMarginY,
    paragraphMarginBottom: paragraphMarginBottom ?? this.paragraphMarginBottom,
    listMarginBottom: listMarginBottom ?? this.listMarginBottom,
    listItemMarginBottom: listItemMarginBottom ?? this.listItemMarginBottom,
    listPaddingLeft: listPaddingLeft ?? this.listPaddingLeft,
    h1MarginBottom: h1MarginBottom ?? this.h1MarginBottom,
    h1PaddingBottom: h1PaddingBottom ?? this.h1PaddingBottom,
    h1HasBorderBottom: h1HasBorderBottom ?? this.h1HasBorderBottom,
    h2MarginTop: h2MarginTop ?? this.h2MarginTop,
    h2MarginBottom: h2MarginBottom ?? this.h2MarginBottom,
    h3MarginTop: h3MarginTop ?? this.h3MarginTop,
    h3MarginBottom: h3MarginBottom ?? this.h3MarginBottom,
    h4MarginTop: h4MarginTop ?? this.h4MarginTop,
    h4MarginBottom: h4MarginBottom ?? this.h4MarginBottom,
    lightCodeTheme: lightCodeTheme ?? this.lightCodeTheme,
    darkCodeTheme: darkCodeTheme ?? this.darkCodeTheme,
  );

  Map<String, dynamic> toJson() => {
    'linkDecoration': linkDecoration,
    'linkHoverDecoration': linkHoverDecoration,
    'blockquoteBorderWidth': blockquoteBorderWidth,
    'blockquotePaddingLeft': blockquotePaddingLeft,
    'codeInlinePaddingH': codeInlinePaddingH,
    'codeInlinePaddingV': codeInlinePaddingV,
    'codeInlineBorderRadius': codeInlineBorderRadius,
    'codeBlockPadding': codeBlockPadding,
    'codeBlockBorderRadius': codeBlockBorderRadius,
    'tableCellPadding': tableCellPadding,
    'imageBorderRadius': imageBorderRadius,
    'hrMarginY': hrMarginY,
    'paragraphMarginBottom': paragraphMarginBottom,
    'listMarginBottom': listMarginBottom,
    'listItemMarginBottom': listItemMarginBottom,
    'listPaddingLeft': listPaddingLeft,
    'h1MarginBottom': h1MarginBottom,
    'h1PaddingBottom': h1PaddingBottom,
    'h1HasBorderBottom': h1HasBorderBottom,
    'h2MarginTop': h2MarginTop,
    'h2MarginBottom': h2MarginBottom,
    'h3MarginTop': h3MarginTop,
    'h3MarginBottom': h3MarginBottom,
    'h4MarginTop': h4MarginTop,
    'h4MarginBottom': h4MarginBottom,
    'lightCodeTheme': lightCodeTheme.toJson(),
    'darkCodeTheme': darkCodeTheme.toJson(),
  };
}
