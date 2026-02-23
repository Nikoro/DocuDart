import 'package:jaspr/dom.dart' show Color;
import 'package:meta/meta.dart';

import 'color_resolver.dart';
import 'color_scheme.dart';
import 'component_theme.dart';
import 'markdown_theme.dart';
import 'text_theme.dart';

/// Complete theme configuration for a DocuDart site.
///
/// A theme bundles color schemes (light + dark), typography, markdown styling,
/// and component dimensions into a single immutable object.
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
/// // Seed from a hex value
/// Theme.material3(seedColor: Color.value(0xFF006D40))
///
/// // Deep customization
/// Theme.shadcn(seedColor: Colors.sky).copyWith(
///   textTheme: TextTheme.shadcn().copyWith(
///     fontFamily: 'Geist, system-ui, sans-serif',
///   ),
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
    this.componentTheme = const ComponentTheme(),
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
      componentTheme: const ComponentTheme.classic(),
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
      componentTheme: const ComponentTheme.material3(),
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
      componentTheme: const ComponentTheme.shadcn(),
    );
  }

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
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
    componentTheme: json['componentTheme'] != null
        ? ComponentTheme.fromJson(
            json['componentTheme'] as Map<String, dynamic>,
          )
        : const ComponentTheme(),
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

  /// Component dimensions (sidebar, header, footer, cards, buttons).
  final ComponentTheme componentTheme;

  Theme copyWith({
    String? name,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
    TextTheme? textTheme,
    MarkdownTheme? markdownTheme,
    ComponentTheme? componentTheme,
  }) => Theme(
    name: name ?? this.name,
    lightColorScheme: lightColorScheme ?? this.lightColorScheme,
    darkColorScheme: darkColorScheme ?? this.darkColorScheme,
    textTheme: textTheme ?? this.textTheme,
    markdownTheme: markdownTheme ?? this.markdownTheme,
    componentTheme: componentTheme ?? this.componentTheme,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'lightColorScheme': lightColorScheme.toJson(),
    'darkColorScheme': darkColorScheme.toJson(),
    'textTheme': textTheme.toJson(),
    'markdownTheme': markdownTheme.toJson(),
    'componentTheme': componentTheme.toJson(),
  };
}
