import 'package:meta/meta.dart';

/// Theme for sidebar navigation.
///
/// Controls dimensions, spacing, and visual treatment of the sidebar.
/// Colors default to CSS variables when `null`.
@immutable
class SidebarTheme {
  const SidebarTheme({
    this.width = 280,
    this.paddingH = 1.0,
    this.paddingV = 2.0,
    this.fontSize = 0.875,
    this.linkBorderRadius = 0.375,
    this.activeBorderWidth = 3,
    this.hasBorderRight = true,
    this.backgroundColor,
    this.borderColor,
    this.linkHoverBg,
    this.linkHoverColor,
    this.activeColor,
    this.activeBg,
    this.activeOpacity = 0.08,
    this.activeFontWeight = 500,
    this.expansionTileHoverBg,
  });

  /// dart.dev / flutter.dev style — left-border active indicator.
  const SidebarTheme.classic({
    this.width = 280,
    this.paddingH = 1.0,
    this.paddingV = 2.0,
    this.fontSize = 0.875,
    this.linkBorderRadius = 0.375,
    this.activeBorderWidth = 3,
    this.hasBorderRight = true,
    this.backgroundColor,
    this.borderColor,
    this.linkHoverBg,
    this.linkHoverColor,
    this.activeColor,
    this.activeBg,
    this.activeOpacity = 0.08,
    this.activeFontWeight = 500,
    this.expansionTileHoverBg,
  });

  /// Material Design 3 — pill-shaped, filled active indicator.
  const SidebarTheme.material3({
    this.width = 280,
    this.paddingH = 1.0,
    this.paddingV = 2.0,
    this.fontSize = 0.875,
    this.linkBorderRadius = 1.5,
    this.activeBorderWidth = 0,
    this.hasBorderRight = false,
    this.backgroundColor,
    this.borderColor,
    this.linkHoverBg,
    this.linkHoverColor,
    this.activeColor,
    this.activeBg,
    this.activeOpacity = 0.12,
    this.activeFontWeight = 500,
    this.expansionTileHoverBg,
  });

  /// shadcn/ui — tighter, sharper.
  const SidebarTheme.shadcn({
    this.width = 256,
    this.paddingH = 1.0,
    this.paddingV = 1.5,
    this.fontSize = 0.875,
    this.linkBorderRadius = 0.375,
    this.activeBorderWidth = 2,
    this.hasBorderRight = true,
    this.backgroundColor,
    this.borderColor,
    this.linkHoverBg,
    this.linkHoverColor,
    this.activeColor,
    this.activeBg,
    this.activeOpacity = 0.08,
    this.activeFontWeight = 500,
    this.expansionTileHoverBg,
  });

  factory SidebarTheme.fromJson(Map<String, dynamic> json) => SidebarTheme(
    width: (json['width'] as num?)?.toDouble() ?? 280,
    paddingH: (json['paddingH'] as num?)?.toDouble() ?? 1.0,
    paddingV: (json['paddingV'] as num?)?.toDouble() ?? 2.0,
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? 0.875,
    linkBorderRadius: (json['linkBorderRadius'] as num?)?.toDouble() ?? 0.375,
    activeBorderWidth: (json['activeBorderWidth'] as num?)?.toDouble() ?? 3,
    hasBorderRight: json['hasBorderRight'] as bool? ?? true,
    backgroundColor: json['backgroundColor'] as int?,
    borderColor: json['borderColor'] as int?,
    linkHoverBg: json['linkHoverBg'] as int?,
    linkHoverColor: json['linkHoverColor'] as int?,
    activeColor: json['activeColor'] as int?,
    activeBg: json['activeBg'] as int?,
    activeOpacity: (json['activeOpacity'] as num?)?.toDouble() ?? 0.08,
    activeFontWeight: json['activeFontWeight'] as int? ?? 500,
    expansionTileHoverBg: json['expansionTileHoverBg'] as int?,
  );

  /// Sidebar width in pixels.
  final double width;

  /// Horizontal padding in rem.
  final double paddingH;

  /// Vertical padding in rem.
  final double paddingV;

  /// Font size in rem.
  final double fontSize;

  /// Border radius for sidebar links in rem.
  final double linkBorderRadius;

  /// Width of the active indicator border (0 = no border).
  final double activeBorderWidth;

  /// Whether the sidebar has a right border.
  final bool hasBorderRight;

  /// Background color override (null = use CSS variable).
  final int? backgroundColor;

  /// Border color override (null = use CSS variable).
  final int? borderColor;

  /// Link hover background color (null = use CSS variable).
  final int? linkHoverBg;

  /// Link hover text color (null = use CSS variable).
  final int? linkHoverColor;

  /// Active link text color (null = use CSS variable).
  final int? activeColor;

  /// Active link background color (null = use CSS variable with opacity).
  final int? activeBg;

  /// Opacity for auto-generated active background.
  final double activeOpacity;

  /// Font weight for active links.
  final int activeFontWeight;

  /// Expansion tile header hover background (null = none).
  final int? expansionTileHoverBg;

  SidebarTheme copyWith({
    double? width,
    double? paddingH,
    double? paddingV,
    double? fontSize,
    double? linkBorderRadius,
    double? activeBorderWidth,
    bool? hasBorderRight,
    int? backgroundColor,
    int? borderColor,
    int? linkHoverBg,
    int? linkHoverColor,
    int? activeColor,
    int? activeBg,
    double? activeOpacity,
    int? activeFontWeight,
    int? expansionTileHoverBg,
  }) => SidebarTheme(
    width: width ?? this.width,
    paddingH: paddingH ?? this.paddingH,
    paddingV: paddingV ?? this.paddingV,
    fontSize: fontSize ?? this.fontSize,
    linkBorderRadius: linkBorderRadius ?? this.linkBorderRadius,
    activeBorderWidth: activeBorderWidth ?? this.activeBorderWidth,
    hasBorderRight: hasBorderRight ?? this.hasBorderRight,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    linkHoverBg: linkHoverBg ?? this.linkHoverBg,
    linkHoverColor: linkHoverColor ?? this.linkHoverColor,
    activeColor: activeColor ?? this.activeColor,
    activeBg: activeBg ?? this.activeBg,
    activeOpacity: activeOpacity ?? this.activeOpacity,
    activeFontWeight: activeFontWeight ?? this.activeFontWeight,
    expansionTileHoverBg: expansionTileHoverBg ?? this.expansionTileHoverBg,
  );

  Map<String, dynamic> toJson() => {
    'width': width,
    'paddingH': paddingH,
    'paddingV': paddingV,
    'fontSize': fontSize,
    'linkBorderRadius': linkBorderRadius,
    'activeBorderWidth': activeBorderWidth,
    'hasBorderRight': hasBorderRight,
    if (backgroundColor != null) 'backgroundColor': backgroundColor,
    if (borderColor != null) 'borderColor': borderColor,
    if (linkHoverBg != null) 'linkHoverBg': linkHoverBg,
    if (linkHoverColor != null) 'linkHoverColor': linkHoverColor,
    if (activeColor != null) 'activeColor': activeColor,
    if (activeBg != null) 'activeBg': activeBg,
    'activeOpacity': activeOpacity,
    'activeFontWeight': activeFontWeight,
    if (expansionTileHoverBg != null)
      'expansionTileHoverBg': expansionTileHoverBg,
  };
}
