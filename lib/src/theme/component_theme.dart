import 'package:meta/meta.dart';

/// Styling for structural components (sidebar, header, footer, cards, etc.).
///
/// Controls dimensions, spacing, and border radii for the site chrome.
/// Colors are inherited from [ColorScheme] via CSS variables.
@immutable
class ComponentTheme {
  const ComponentTheme({
    this.sidebarWidth = 280,
    this.sidebarPaddingH = 1.0,
    this.sidebarPaddingV = 2.0,
    this.sidebarFontSize = 0.875,
    this.sidebarLinkBorderRadius = 0.375,
    this.sidebarActiveBorderWidth = 3,
    this.headerPaddingH = 2.0,
    this.headerPaddingV = 1.0,
    this.headerMaxWidth = 1400,
    this.logoFontSize = 1.25,
    this.logoFontWeight = 600,
    this.logoImageHeight = 1.75,
    this.footerPaddingH = 2.0,
    this.footerPaddingV = 2.0,
    this.footerMaxWidth = 1400,
    this.mainPaddingH = 3.0,
    this.mainPaddingV = 2.0,
    this.calloutPadding = 1.0,
    this.calloutBorderRadius = 0.5,
    this.calloutBorderWidth = 4,
    this.cardPadding = 1.5,
    this.cardBorderRadius = 0.5,
    this.buttonPaddingH = 1.5,
    this.buttonPaddingV = 0.75,
    this.buttonBorderRadius = 0.5,
    this.buttonFontWeight = 500,
    this.tabBorderWidth = 2,
    this.contentMaxWidth = 1200,
    this.landingPaddingV = 4.0,
    this.landingTitleFontSize = 3.0,
    this.landingDescriptionFontSize = 1.25,
  });

  /// dart.dev / flutter.dev style component sizing.
  const ComponentTheme.classic({
    this.sidebarWidth = 280,
    this.sidebarPaddingH = 1.0,
    this.sidebarPaddingV = 2.0,
    this.sidebarFontSize = 0.875,
    this.sidebarLinkBorderRadius = 0.375,
    this.sidebarActiveBorderWidth = 3,
    this.headerPaddingH = 2.0,
    this.headerPaddingV = 1.0,
    this.headerMaxWidth = 1400,
    this.logoFontSize = 1.25,
    this.logoFontWeight = 600,
    this.logoImageHeight = 1.75,
    this.footerPaddingH = 2.0,
    this.footerPaddingV = 2.0,
    this.footerMaxWidth = 1400,
    this.mainPaddingH = 3.0,
    this.mainPaddingV = 2.0,
    this.calloutPadding = 1.0,
    this.calloutBorderRadius = 0.5,
    this.calloutBorderWidth = 4,
    this.cardPadding = 1.5,
    this.cardBorderRadius = 0.5,
    this.buttonPaddingH = 1.5,
    this.buttonPaddingV = 0.75,
    this.buttonBorderRadius = 0.5,
    this.buttonFontWeight = 500,
    this.tabBorderWidth = 2,
    this.contentMaxWidth = 1200,
    this.landingPaddingV = 4.0,
    this.landingTitleFontSize = 3.0,
    this.landingDescriptionFontSize = 1.25,
  });

  /// Material Design 3 — larger radii, pill buttons.
  const ComponentTheme.material3({
    this.sidebarWidth = 280,
    this.sidebarPaddingH = 1.0,
    this.sidebarPaddingV = 2.0,
    this.sidebarFontSize = 0.875,
    this.sidebarLinkBorderRadius = 1.5,
    this.sidebarActiveBorderWidth = 0,
    this.headerPaddingH = 2.0,
    this.headerPaddingV = 1.0,
    this.headerMaxWidth = 1400,
    this.logoFontSize = 1.25,
    this.logoFontWeight = 500,
    this.logoImageHeight = 1.75,
    this.footerPaddingH = 2.0,
    this.footerPaddingV = 2.0,
    this.footerMaxWidth = 1400,
    this.mainPaddingH = 3.0,
    this.mainPaddingV = 2.0,
    this.calloutPadding = 1.25,
    this.calloutBorderRadius = 0.75,
    this.calloutBorderWidth = 3,
    this.cardPadding = 1.5,
    this.cardBorderRadius = 0.75,
    this.buttonPaddingH = 1.5,
    this.buttonPaddingV = 0.625,
    this.buttonBorderRadius = 1.25,
    this.buttonFontWeight = 500,
    this.tabBorderWidth = 3,
    this.contentMaxWidth = 1200,
    this.landingPaddingV = 5.0,
    this.landingTitleFontSize = 2.75,
    this.landingDescriptionFontSize = 1.25,
  });

  /// shadcn/ui — tighter, sharper.
  const ComponentTheme.shadcn({
    this.sidebarWidth = 256,
    this.sidebarPaddingH = 1.0,
    this.sidebarPaddingV = 1.5,
    this.sidebarFontSize = 0.875,
    this.sidebarLinkBorderRadius = 0.375,
    this.sidebarActiveBorderWidth = 2,
    this.headerPaddingH = 2.0,
    this.headerPaddingV = 0.75,
    this.headerMaxWidth = 1400,
    this.logoFontSize = 1.125,
    this.logoFontWeight = 700,
    this.logoImageHeight = 1.5,
    this.footerPaddingH = 2.0,
    this.footerPaddingV = 1.5,
    this.footerMaxWidth = 1400,
    this.mainPaddingH = 3.0,
    this.mainPaddingV = 2.0,
    this.calloutPadding = 1.0,
    this.calloutBorderRadius = 0.375,
    this.calloutBorderWidth = 2,
    this.cardPadding = 1.5,
    this.cardBorderRadius = 0.375,
    this.buttonPaddingH = 1.0,
    this.buttonPaddingV = 0.5,
    this.buttonBorderRadius = 0.375,
    this.buttonFontWeight = 500,
    this.tabBorderWidth = 2,
    this.contentMaxWidth = 1200,
    this.landingPaddingV = 4.0,
    this.landingTitleFontSize = 3.0,
    this.landingDescriptionFontSize = 1.25,
  });

  factory ComponentTheme.fromJson(Map<String, dynamic> json) => ComponentTheme(
    sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 280,
    sidebarPaddingH: (json['sidebarPaddingH'] as num?)?.toDouble() ?? 1.0,
    sidebarPaddingV: (json['sidebarPaddingV'] as num?)?.toDouble() ?? 2.0,
    sidebarFontSize: (json['sidebarFontSize'] as num?)?.toDouble() ?? 0.875,
    sidebarLinkBorderRadius:
        (json['sidebarLinkBorderRadius'] as num?)?.toDouble() ?? 0.375,
    sidebarActiveBorderWidth:
        (json['sidebarActiveBorderWidth'] as num?)?.toDouble() ?? 3,
    headerPaddingH: (json['headerPaddingH'] as num?)?.toDouble() ?? 2.0,
    headerPaddingV: (json['headerPaddingV'] as num?)?.toDouble() ?? 1.0,
    headerMaxWidth: (json['headerMaxWidth'] as num?)?.toDouble() ?? 1400,
    logoFontSize: (json['logoFontSize'] as num?)?.toDouble() ?? 1.25,
    logoFontWeight: json['logoFontWeight'] as int? ?? 600,
    logoImageHeight: (json['logoImageHeight'] as num?)?.toDouble() ?? 1.75,
    footerPaddingH: (json['footerPaddingH'] as num?)?.toDouble() ?? 2.0,
    footerPaddingV: (json['footerPaddingV'] as num?)?.toDouble() ?? 2.0,
    footerMaxWidth: (json['footerMaxWidth'] as num?)?.toDouble() ?? 1400,
    mainPaddingH: (json['mainPaddingH'] as num?)?.toDouble() ?? 3.0,
    mainPaddingV: (json['mainPaddingV'] as num?)?.toDouble() ?? 2.0,
    calloutPadding: (json['calloutPadding'] as num?)?.toDouble() ?? 1.0,
    calloutBorderRadius:
        (json['calloutBorderRadius'] as num?)?.toDouble() ?? 0.5,
    calloutBorderWidth: (json['calloutBorderWidth'] as num?)?.toDouble() ?? 4,
    cardPadding: (json['cardPadding'] as num?)?.toDouble() ?? 1.5,
    cardBorderRadius: (json['cardBorderRadius'] as num?)?.toDouble() ?? 0.5,
    buttonPaddingH: (json['buttonPaddingH'] as num?)?.toDouble() ?? 1.5,
    buttonPaddingV: (json['buttonPaddingV'] as num?)?.toDouble() ?? 0.75,
    buttonBorderRadius: (json['buttonBorderRadius'] as num?)?.toDouble() ?? 0.5,
    buttonFontWeight: json['buttonFontWeight'] as int? ?? 500,
    tabBorderWidth: (json['tabBorderWidth'] as num?)?.toDouble() ?? 2,
    contentMaxWidth: (json['contentMaxWidth'] as num?)?.toDouble() ?? 1200,
    landingPaddingV: (json['landingPaddingV'] as num?)?.toDouble() ?? 4.0,
    landingTitleFontSize:
        (json['landingTitleFontSize'] as num?)?.toDouble() ?? 3.0,
    landingDescriptionFontSize:
        (json['landingDescriptionFontSize'] as num?)?.toDouble() ?? 1.25,
  );

  // --- Sidebar ---
  final double sidebarWidth;
  final double sidebarPaddingH;
  final double sidebarPaddingV;
  final double sidebarFontSize;
  final double sidebarLinkBorderRadius;
  final double sidebarActiveBorderWidth;

  // --- Header ---
  final double headerPaddingH;
  final double headerPaddingV;
  final double headerMaxWidth;
  final double logoFontSize;
  final int logoFontWeight;
  final double logoImageHeight;

  // --- Footer ---
  final double footerPaddingH;
  final double footerPaddingV;
  final double footerMaxWidth;

  // --- Main content ---
  final double mainPaddingH;
  final double mainPaddingV;

  // --- Callout ---
  final double calloutPadding;
  final double calloutBorderRadius;
  final double calloutBorderWidth;

  // --- Card ---
  final double cardPadding;
  final double cardBorderRadius;

  // --- Button ---
  final double buttonPaddingH;
  final double buttonPaddingV;
  final double buttonBorderRadius;
  final int buttonFontWeight;

  // --- Tabs ---
  final double tabBorderWidth;

  // --- Content ---
  final double contentMaxWidth;

  // --- Landing page ---
  final double landingPaddingV;
  final double landingTitleFontSize;
  final double landingDescriptionFontSize;

  ComponentTheme copyWith({
    double? sidebarWidth,
    double? sidebarPaddingH,
    double? sidebarPaddingV,
    double? sidebarFontSize,
    double? sidebarLinkBorderRadius,
    double? sidebarActiveBorderWidth,
    double? headerPaddingH,
    double? headerPaddingV,
    double? headerMaxWidth,
    double? logoFontSize,
    int? logoFontWeight,
    double? logoImageHeight,
    double? footerPaddingH,
    double? footerPaddingV,
    double? footerMaxWidth,
    double? mainPaddingH,
    double? mainPaddingV,
    double? calloutPadding,
    double? calloutBorderRadius,
    double? calloutBorderWidth,
    double? cardPadding,
    double? cardBorderRadius,
    double? buttonPaddingH,
    double? buttonPaddingV,
    double? buttonBorderRadius,
    int? buttonFontWeight,
    double? tabBorderWidth,
    double? contentMaxWidth,
    double? landingPaddingV,
    double? landingTitleFontSize,
    double? landingDescriptionFontSize,
  }) => ComponentTheme(
    sidebarWidth: sidebarWidth ?? this.sidebarWidth,
    sidebarPaddingH: sidebarPaddingH ?? this.sidebarPaddingH,
    sidebarPaddingV: sidebarPaddingV ?? this.sidebarPaddingV,
    sidebarFontSize: sidebarFontSize ?? this.sidebarFontSize,
    sidebarLinkBorderRadius:
        sidebarLinkBorderRadius ?? this.sidebarLinkBorderRadius,
    sidebarActiveBorderWidth:
        sidebarActiveBorderWidth ?? this.sidebarActiveBorderWidth,
    headerPaddingH: headerPaddingH ?? this.headerPaddingH,
    headerPaddingV: headerPaddingV ?? this.headerPaddingV,
    headerMaxWidth: headerMaxWidth ?? this.headerMaxWidth,
    logoFontSize: logoFontSize ?? this.logoFontSize,
    logoFontWeight: logoFontWeight ?? this.logoFontWeight,
    logoImageHeight: logoImageHeight ?? this.logoImageHeight,
    footerPaddingH: footerPaddingH ?? this.footerPaddingH,
    footerPaddingV: footerPaddingV ?? this.footerPaddingV,
    footerMaxWidth: footerMaxWidth ?? this.footerMaxWidth,
    mainPaddingH: mainPaddingH ?? this.mainPaddingH,
    mainPaddingV: mainPaddingV ?? this.mainPaddingV,
    calloutPadding: calloutPadding ?? this.calloutPadding,
    calloutBorderRadius: calloutBorderRadius ?? this.calloutBorderRadius,
    calloutBorderWidth: calloutBorderWidth ?? this.calloutBorderWidth,
    cardPadding: cardPadding ?? this.cardPadding,
    cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
    buttonPaddingH: buttonPaddingH ?? this.buttonPaddingH,
    buttonPaddingV: buttonPaddingV ?? this.buttonPaddingV,
    buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
    buttonFontWeight: buttonFontWeight ?? this.buttonFontWeight,
    tabBorderWidth: tabBorderWidth ?? this.tabBorderWidth,
    contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
    landingPaddingV: landingPaddingV ?? this.landingPaddingV,
    landingTitleFontSize: landingTitleFontSize ?? this.landingTitleFontSize,
    landingDescriptionFontSize:
        landingDescriptionFontSize ?? this.landingDescriptionFontSize,
  );

  Map<String, dynamic> toJson() => {
    'sidebarWidth': sidebarWidth,
    'sidebarPaddingH': sidebarPaddingH,
    'sidebarPaddingV': sidebarPaddingV,
    'sidebarFontSize': sidebarFontSize,
    'sidebarLinkBorderRadius': sidebarLinkBorderRadius,
    'sidebarActiveBorderWidth': sidebarActiveBorderWidth,
    'headerPaddingH': headerPaddingH,
    'headerPaddingV': headerPaddingV,
    'headerMaxWidth': headerMaxWidth,
    'logoFontSize': logoFontSize,
    'logoFontWeight': logoFontWeight,
    'logoImageHeight': logoImageHeight,
    'footerPaddingH': footerPaddingH,
    'footerPaddingV': footerPaddingV,
    'footerMaxWidth': footerMaxWidth,
    'mainPaddingH': mainPaddingH,
    'mainPaddingV': mainPaddingV,
    'calloutPadding': calloutPadding,
    'calloutBorderRadius': calloutBorderRadius,
    'calloutBorderWidth': calloutBorderWidth,
    'cardPadding': cardPadding,
    'cardBorderRadius': cardBorderRadius,
    'buttonPaddingH': buttonPaddingH,
    'buttonPaddingV': buttonPaddingV,
    'buttonBorderRadius': buttonBorderRadius,
    'buttonFontWeight': buttonFontWeight,
    'tabBorderWidth': tabBorderWidth,
    'contentMaxWidth': contentMaxWidth,
    'landingPaddingV': landingPaddingV,
    'landingTitleFontSize': landingTitleFontSize,
    'landingDescriptionFontSize': landingDescriptionFontSize,
  };
}
