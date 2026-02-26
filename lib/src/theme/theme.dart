import 'package:jaspr/dom.dart' show Color;
import 'package:meta/meta.dart';

import 'button_theme.dart';
import 'callout_theme.dart';
import 'card_theme.dart';
import 'color_resolver.dart';
import 'color_scheme.dart';
import 'footer_theme.dart';
import 'header_theme.dart';
import 'icon_button_theme.dart';
import 'landing_theme.dart';
import 'logo_theme.dart';
import 'markdown_theme.dart';
import 'sidebar_theme.dart';
import 'text_theme.dart';

/// Complete theme configuration for a DocuDart site.
///
/// A theme bundles color schemes (light + dark), typography, markdown styling,
/// and per-component themes into a single immutable object — mirroring
/// Flutter's `ThemeData` pattern.
///
/// Three built-in presets are available via named constructors:
/// - [Theme.classic] — dart.dev / flutter.dev style
/// - [Theme.material3] — Material Design 3
/// - [Theme.shadcn] — shadcn/ui inspired
///
/// Each preset accepts an optional [seedColor] to auto-generate a
/// harmonious color palette via [ColorScheme.fromSeed]. Pass any Jaspr
/// [Color] (e.g., `Colors.indigo`, `Color.value(0xFF006D40)`).
///
/// ```dart
/// // Use a preset as-is
/// Theme.classic()
///
/// // Seed from a named color
/// Theme.classic(seedColor: Colors.indigo)
///
/// // Deep customization
/// Theme.shadcn(seedColor: Colors.sky).copyWith(
///   sidebarTheme: SidebarTheme.shadcn().copyWith(width: 300),
///   buttonTheme: ButtonTheme.shadcn().copyWith(borderRadius: 1.0),
/// )
/// ```
@immutable
class Theme {
  const Theme({
    this.name = 'custom',
    required this.lightColorScheme,
    required this.darkColorScheme,
    this.textTheme = const TextTheme(),
    this.markdownTheme = const MarkdownTheme(),
    this.sidebarTheme = const SidebarTheme(),
    this.headerTheme = const HeaderTheme(),
    this.footerTheme = const FooterTheme(),
    this.logoTheme = const LogoTheme(),
    this.buttonTheme = const ButtonTheme(),
    this.cardTheme = const CardTheme(),
    this.calloutTheme = const CalloutTheme(),
    this.iconButtonTheme = const IconButtonTheme(),
    this.landingTheme = const LandingTheme(),
    this.contentMaxWidth = 1200,
    this.mainPaddingH = 3.0,
    this.mainPaddingV = 2.0,
    this.mobilePaddingH = 1.0,
    this.tabBorderWidth = 2,
  });

  /// dart.dev / flutter.dev style — clean, professional, familiar to Dart devs.
  ///
  /// When [seedColor] is provided, both light and dark color schemes are
  /// auto-generated from that seed. Otherwise, handcrafted defaults are used.
  factory Theme.classic({Color? seedColor}) {
    final seed = seedColor != null ? resolveColor(seedColor) : null;
    return Theme(
      name: 'classic',
      lightColorScheme: seed != null
          ? ColorScheme.fromSeed(seedColor: seed)
          : const ColorScheme.light(),
      darkColorScheme: seed != null
          ? ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)
          : const ColorScheme.dark(),
      textTheme: const TextTheme.classic(),
      markdownTheme: const MarkdownTheme.classic(),
      sidebarTheme: const SidebarTheme.classic(),
      headerTheme: const HeaderTheme.classic(),
      footerTheme: const FooterTheme.classic(),
      logoTheme: const LogoTheme.classic(),
      buttonTheme: const ButtonTheme.classic(),
      cardTheme: const CardTheme.classic(),
      calloutTheme: const CalloutTheme.classic(),
      iconButtonTheme: const IconButtonTheme.classic(),
      landingTheme: const LandingTheme.classic(),
    );
  }

  /// Material Design 3 — larger radii, lighter heading weights, Roboto.
  ///
  /// When [seedColor] is provided, both light and dark color schemes are
  /// auto-generated from that seed.
  factory Theme.material3({Color? seedColor}) {
    final seed = seedColor != null ? resolveColor(seedColor) : null;
    return Theme(
      name: 'material3',
      lightColorScheme: seed != null
          ? ColorScheme.fromSeed(seedColor: seed)
          : const ColorScheme.material3Light(),
      darkColorScheme: seed != null
          ? ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)
          : const ColorScheme.material3Dark(),
      textTheme: const TextTheme.material3(),
      markdownTheme: const MarkdownTheme.material3(),
      sidebarTheme: const SidebarTheme.material3(),
      headerTheme: const HeaderTheme.material3(),
      footerTheme: const FooterTheme.material3(),
      logoTheme: const LogoTheme.material3(),
      buttonTheme: const ButtonTheme.material3(),
      cardTheme: const CardTheme.material3(),
      calloutTheme: const CalloutTheme.material3(),
      iconButtonTheme: const IconButtonTheme.material3(),
      landingTheme: const LandingTheme.material3(),
      tabBorderWidth: 3,
    );
  }

  /// shadcn/ui — tight spacing, sharp radii, bold typography.
  ///
  /// When [seedColor] is provided, both light and dark color schemes are
  /// auto-generated from that seed.
  factory Theme.shadcn({Color? seedColor}) {
    final seed = seedColor != null ? resolveColor(seedColor) : null;
    return Theme(
      name: 'shadcn',
      lightColorScheme: seed != null
          ? ColorScheme.fromSeed(seedColor: seed)
          : const ColorScheme.shadcnLight(),
      darkColorScheme: seed != null
          ? ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)
          : const ColorScheme.shadcnDark(),
      textTheme: const TextTheme.shadcn(),
      markdownTheme: const MarkdownTheme.shadcn(),
      sidebarTheme: const SidebarTheme.shadcn(),
      headerTheme: const HeaderTheme.shadcn(),
      footerTheme: const FooterTheme.shadcn(),
      logoTheme: const LogoTheme.shadcn(),
      buttonTheme: const ButtonTheme.shadcn(),
      cardTheme: const CardTheme.shadcn(),
      calloutTheme: const CalloutTheme.shadcn(),
      iconButtonTheme: const IconButtonTheme.shadcn(),
      landingTheme: const LandingTheme.shadcn(),
    );
  }

  factory Theme.fromJson(Map<String, dynamic> json) => .new(
    name: json['name'] as String? ?? 'custom',
    lightColorScheme: json['lightColorScheme'] != null
        ? ColorScheme.fromJson(json['lightColorScheme'] as Map<String, dynamic>)
        : const ColorScheme.light(),
    darkColorScheme: json['darkColorScheme'] != null
        ? ColorScheme.fromJson(json['darkColorScheme'] as Map<String, dynamic>)
        : const ColorScheme.dark(),
    textTheme: json['textTheme'] != null
        ? TextTheme.fromJson(json['textTheme'] as Map<String, dynamic>)
        : const TextTheme(),
    markdownTheme: json['markdownTheme'] != null
        ? MarkdownTheme.fromJson(json['markdownTheme'] as Map<String, dynamic>)
        : const MarkdownTheme(),
    sidebarTheme: json['sidebarTheme'] != null
        ? SidebarTheme.fromJson(json['sidebarTheme'] as Map<String, dynamic>)
        : const SidebarTheme(),
    headerTheme: json['headerTheme'] != null
        ? HeaderTheme.fromJson(json['headerTheme'] as Map<String, dynamic>)
        : const HeaderTheme(),
    footerTheme: json['footerTheme'] != null
        ? FooterTheme.fromJson(json['footerTheme'] as Map<String, dynamic>)
        : const FooterTheme(),
    logoTheme: json['logoTheme'] != null
        ? LogoTheme.fromJson(json['logoTheme'] as Map<String, dynamic>)
        : const LogoTheme(),
    buttonTheme: json['buttonTheme'] != null
        ? ButtonTheme.fromJson(json['buttonTheme'] as Map<String, dynamic>)
        : const ButtonTheme(),
    cardTheme: json['cardTheme'] != null
        ? CardTheme.fromJson(json['cardTheme'] as Map<String, dynamic>)
        : const CardTheme(),
    calloutTheme: json['calloutTheme'] != null
        ? CalloutTheme.fromJson(json['calloutTheme'] as Map<String, dynamic>)
        : const CalloutTheme(),
    iconButtonTheme: json['iconButtonTheme'] != null
        ? IconButtonTheme.fromJson(
            json['iconButtonTheme'] as Map<String, dynamic>,
          )
        : const IconButtonTheme(),
    landingTheme: json['landingTheme'] != null
        ? LandingTheme.fromJson(json['landingTheme'] as Map<String, dynamic>)
        : const LandingTheme(),
    contentMaxWidth: (json['contentMaxWidth'] as num?)?.toDouble() ?? 1200,
    mainPaddingH: (json['mainPaddingH'] as num?)?.toDouble() ?? 3.0,
    mainPaddingV: (json['mainPaddingV'] as num?)?.toDouble() ?? 2.0,
    mobilePaddingH: (json['mobilePaddingH'] as num?)?.toDouble() ?? 1.0,
    tabBorderWidth: (json['tabBorderWidth'] as num?)?.toDouble() ?? 2,
  );

  /// Display name for the theme.
  final String name;

  /// Color scheme used in light mode.
  final ColorScheme lightColorScheme;

  /// Color scheme used in dark mode.
  final ColorScheme darkColorScheme;

  /// Typography configuration (fonts, heading styles, body text).
  final TextTheme textTheme;

  /// Markdown content styling (spacing, borders, code themes).
  final MarkdownTheme markdownTheme;

  /// Sidebar navigation theme.
  final SidebarTheme sidebarTheme;

  /// Site header theme.
  final HeaderTheme headerTheme;

  /// Site footer theme.
  final FooterTheme footerTheme;

  /// Logo appearance theme.
  final LogoTheme logoTheme;

  /// Button styling theme.
  final ButtonTheme buttonTheme;

  /// Card component theme.
  final CardTheme cardTheme;

  /// Callout/admonition theme.
  final CalloutTheme calloutTheme;

  /// Icon button theme.
  final IconButtonTheme iconButtonTheme;

  /// Landing/home page theme.
  final LandingTheme landingTheme;

  /// Maximum content width in pixels.
  final double contentMaxWidth;

  /// Main content horizontal padding in rem.
  final double mainPaddingH;

  /// Main content vertical padding in rem.
  final double mainPaddingV;

  /// Main content horizontal padding in rem on mobile (≤768px).
  final double mobilePaddingH;

  /// Tab indicator border width in pixels.
  final double tabBorderWidth;

  Theme copyWith({
    String? name,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
    TextTheme? textTheme,
    MarkdownTheme? markdownTheme,
    SidebarTheme? sidebarTheme,
    HeaderTheme? headerTheme,
    FooterTheme? footerTheme,
    LogoTheme? logoTheme,
    ButtonTheme? buttonTheme,
    CardTheme? cardTheme,
    CalloutTheme? calloutTheme,
    IconButtonTheme? iconButtonTheme,
    LandingTheme? landingTheme,
    double? contentMaxWidth,
    double? mainPaddingH,
    double? mainPaddingV,
    double? mobilePaddingH,
    double? tabBorderWidth,
  }) => .new(
    name: name ?? this.name,
    lightColorScheme: lightColorScheme ?? this.lightColorScheme,
    darkColorScheme: darkColorScheme ?? this.darkColorScheme,
    textTheme: textTheme ?? this.textTheme,
    markdownTheme: markdownTheme ?? this.markdownTheme,
    sidebarTheme: sidebarTheme ?? this.sidebarTheme,
    headerTheme: headerTheme ?? this.headerTheme,
    footerTheme: footerTheme ?? this.footerTheme,
    logoTheme: logoTheme ?? this.logoTheme,
    buttonTheme: buttonTheme ?? this.buttonTheme,
    cardTheme: cardTheme ?? this.cardTheme,
    calloutTheme: calloutTheme ?? this.calloutTheme,
    iconButtonTheme: iconButtonTheme ?? this.iconButtonTheme,
    landingTheme: landingTheme ?? this.landingTheme,
    contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
    mainPaddingH: mainPaddingH ?? this.mainPaddingH,
    mainPaddingV: mainPaddingV ?? this.mainPaddingV,
    mobilePaddingH: mobilePaddingH ?? this.mobilePaddingH,
    tabBorderWidth: tabBorderWidth ?? this.tabBorderWidth,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'lightColorScheme': lightColorScheme.toJson(),
    'darkColorScheme': darkColorScheme.toJson(),
    'textTheme': textTheme.toJson(),
    'markdownTheme': markdownTheme.toJson(),
    'sidebarTheme': sidebarTheme.toJson(),
    'headerTheme': headerTheme.toJson(),
    'footerTheme': footerTheme.toJson(),
    'logoTheme': logoTheme.toJson(),
    'buttonTheme': buttonTheme.toJson(),
    'cardTheme': cardTheme.toJson(),
    'calloutTheme': calloutTheme.toJson(),
    'iconButtonTheme': iconButtonTheme.toJson(),
    'landingTheme': landingTheme.toJson(),
    'contentMaxWidth': contentMaxWidth,
    'mainPaddingH': mainPaddingH,
    'mainPaddingV': mainPaddingV,
    'mobilePaddingH': mobilePaddingH,
    'tabBorderWidth': tabBorderWidth,
  };
}
