import 'package:meta/meta.dart';

/// Theme for buttons.
@immutable
class ButtonTheme {
  const ButtonTheme({
    this.paddingH = 1.5,
    this.paddingV = 0.75,
    this.borderRadius = 0.5,
    this.fontWeight = 500,
    this.primaryTextColor,
    this.hoverEffect = ButtonHoverEffect.brightness,
    this.hoverBrightness = 1.1,
    this.hoverOpacity = 0.9,
    this.hoverHasBoxShadow = false,
  });

  const ButtonTheme.classic({
    this.paddingH = 1.5,
    this.paddingV = 0.75,
    this.borderRadius = 0.5,
    this.fontWeight = 500,
    this.primaryTextColor,
    this.hoverEffect = ButtonHoverEffect.brightness,
    this.hoverBrightness = 1.1,
    this.hoverOpacity = 0.9,
    this.hoverHasBoxShadow = false,
  });

  const ButtonTheme.material3({
    this.paddingH = 1.5,
    this.paddingV = 0.625,
    this.borderRadius = 1.25,
    this.fontWeight = 500,
    this.primaryTextColor,
    this.hoverEffect = ButtonHoverEffect.brightness,
    this.hoverBrightness = 1.05,
    this.hoverOpacity = 0.9,
    this.hoverHasBoxShadow = true,
  });

  const ButtonTheme.shadcn({
    this.paddingH = 1.0,
    this.paddingV = 0.5,
    this.borderRadius = 0.375,
    this.fontWeight = 500,
    this.primaryTextColor,
    this.hoverEffect = ButtonHoverEffect.opacity,
    this.hoverBrightness = 1.1,
    this.hoverOpacity = 0.9,
    this.hoverHasBoxShadow = false,
  });

  factory ButtonTheme.fromJson(Map<String, dynamic> json) => .new(
    paddingH: (json['paddingH'] as num?)?.toDouble() ?? 1.5,
    paddingV: (json['paddingV'] as num?)?.toDouble() ?? 0.75,
    borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.5,
    fontWeight: json['fontWeight'] as int? ?? 500,
    primaryTextColor: json['primaryTextColor'] as int?,
    hoverEffect: json['hoverEffect'] == 'opacity'
        ? ButtonHoverEffect.opacity
        : ButtonHoverEffect.brightness,
    hoverBrightness: (json['hoverBrightness'] as num?)?.toDouble() ?? 1.1,
    hoverOpacity: (json['hoverOpacity'] as num?)?.toDouble() ?? 0.9,
    hoverHasBoxShadow: json['hoverHasBoxShadow'] as bool? ?? false,
  );

  /// Horizontal padding in rem.
  final double paddingH;

  /// Vertical padding in rem.
  final double paddingV;

  /// Border radius in rem.
  final double borderRadius;

  /// Font weight.
  final int fontWeight;

  /// Primary button text color override (null = white/background).
  final int? primaryTextColor;

  /// Hover effect type.
  final ButtonHoverEffect hoverEffect;

  /// Brightness multiplier for hover (when [hoverEffect] is brightness).
  final double hoverBrightness;

  /// Opacity for hover (when [hoverEffect] is opacity).
  final double hoverOpacity;

  /// Whether hover shows a box shadow.
  final bool hoverHasBoxShadow;

  ButtonTheme copyWith({
    double? paddingH,
    double? paddingV,
    double? borderRadius,
    int? fontWeight,
    int? primaryTextColor,
    ButtonHoverEffect? hoverEffect,
    double? hoverBrightness,
    double? hoverOpacity,
    bool? hoverHasBoxShadow,
  }) => .new(
    paddingH: paddingH ?? this.paddingH,
    paddingV: paddingV ?? this.paddingV,
    borderRadius: borderRadius ?? this.borderRadius,
    fontWeight: fontWeight ?? this.fontWeight,
    primaryTextColor: primaryTextColor ?? this.primaryTextColor,
    hoverEffect: hoverEffect ?? this.hoverEffect,
    hoverBrightness: hoverBrightness ?? this.hoverBrightness,
    hoverOpacity: hoverOpacity ?? this.hoverOpacity,
    hoverHasBoxShadow: hoverHasBoxShadow ?? this.hoverHasBoxShadow,
  );

  Map<String, dynamic> toJson() => {
    'paddingH': paddingH,
    'paddingV': paddingV,
    'borderRadius': borderRadius,
    'fontWeight': fontWeight,
    if (primaryTextColor != null) 'primaryTextColor': primaryTextColor,
    'hoverEffect': hoverEffect.name,
    'hoverBrightness': hoverBrightness,
    'hoverOpacity': hoverOpacity,
    'hoverHasBoxShadow': hoverHasBoxShadow,
  };
}

/// How a button responds to hover.
enum ButtonHoverEffect {
  /// Increases brightness via CSS `filter: brightness(...)`.
  brightness,

  /// Reduces opacity via CSS `opacity`.
  opacity,
}
