import 'package:meta/meta.dart';

/// Theme for card components.
@immutable
class CardTheme {
  const CardTheme({
    this.padding = 1.5,
    this.borderRadius = 0.5,
    this.hasBoxShadow = false,
    this.shadowBlur = 2,
    this.shadowOpacity = 0.06,
    this.hoverEffect = CardHoverEffect.shadow,
    this.hoverShadowBlur = 16,
    this.hoverShadowOpacity = 0.12,
    this.hoverTranslateY = -1,
  });

  const CardTheme.classic({
    this.padding = 1.5,
    this.borderRadius = 0.5,
    this.hasBoxShadow = false,
    this.shadowBlur = 2,
    this.shadowOpacity = 0.06,
    this.hoverEffect = CardHoverEffect.shadow,
    this.hoverShadowBlur = 12,
    this.hoverShadowOpacity = 0.1,
    this.hoverTranslateY = 0,
  });

  const CardTheme.material3({
    this.padding = 1.5,
    this.borderRadius = 0.75,
    this.hasBoxShadow = true,
    this.shadowBlur = 2,
    this.shadowOpacity = 0.06,
    this.hoverEffect = CardHoverEffect.shadow,
    this.hoverShadowBlur = 16,
    this.hoverShadowOpacity = 0.12,
    this.hoverTranslateY = -1,
  });

  const CardTheme.shadcn({
    this.padding = 1.5,
    this.borderRadius = 0.375,
    this.hasBoxShadow = false,
    this.shadowBlur = 2,
    this.shadowOpacity = 0.06,
    this.hoverEffect = CardHoverEffect.borderHighlight,
    this.hoverShadowBlur = 0,
    this.hoverShadowOpacity = 0,
    this.hoverTranslateY = 0,
  });

  factory CardTheme.fromJson(Map<String, dynamic> json) => .new(
    padding: (json['padding'] as num?)?.toDouble() ?? 1.5,
    borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.5,
    hasBoxShadow: json['hasBoxShadow'] as bool? ?? false,
    shadowBlur: (json['shadowBlur'] as num?)?.toDouble() ?? 2,
    shadowOpacity: (json['shadowOpacity'] as num?)?.toDouble() ?? 0.06,
    hoverEffect: json['hoverEffect'] == 'borderHighlight'
        ? CardHoverEffect.borderHighlight
        : CardHoverEffect.shadow,
    hoverShadowBlur: (json['hoverShadowBlur'] as num?)?.toDouble() ?? 16,
    hoverShadowOpacity:
        (json['hoverShadowOpacity'] as num?)?.toDouble() ?? 0.12,
    hoverTranslateY: (json['hoverTranslateY'] as num?)?.toDouble() ?? -1,
  );

  /// Card padding in rem.
  final double padding;

  /// Card border radius in rem.
  final double borderRadius;

  /// Whether the card has a default box shadow.
  final bool hasBoxShadow;

  /// Default shadow blur radius in pixels.
  final double shadowBlur;

  /// Default shadow opacity (0.0–1.0).
  final double shadowOpacity;

  /// How the card responds to hover.
  final CardHoverEffect hoverEffect;

  /// Hover shadow blur radius in pixels.
  final double hoverShadowBlur;

  /// Hover shadow opacity (0.0–1.0).
  final double hoverShadowOpacity;

  /// Vertical translate on hover in pixels (negative = lift up).
  final double hoverTranslateY;

  CardTheme copyWith({
    double? padding,
    double? borderRadius,
    bool? hasBoxShadow,
    double? shadowBlur,
    double? shadowOpacity,
    CardHoverEffect? hoverEffect,
    double? hoverShadowBlur,
    double? hoverShadowOpacity,
    double? hoverTranslateY,
  }) => .new(
    padding: padding ?? this.padding,
    borderRadius: borderRadius ?? this.borderRadius,
    hasBoxShadow: hasBoxShadow ?? this.hasBoxShadow,
    shadowBlur: shadowBlur ?? this.shadowBlur,
    shadowOpacity: shadowOpacity ?? this.shadowOpacity,
    hoverEffect: hoverEffect ?? this.hoverEffect,
    hoverShadowBlur: hoverShadowBlur ?? this.hoverShadowBlur,
    hoverShadowOpacity: hoverShadowOpacity ?? this.hoverShadowOpacity,
    hoverTranslateY: hoverTranslateY ?? this.hoverTranslateY,
  );

  Map<String, dynamic> toJson() => {
    'padding': padding,
    'borderRadius': borderRadius,
    'hasBoxShadow': hasBoxShadow,
    'shadowBlur': shadowBlur,
    'shadowOpacity': shadowOpacity,
    'hoverEffect': hoverEffect.name,
    'hoverShadowBlur': hoverShadowBlur,
    'hoverShadowOpacity': hoverShadowOpacity,
    'hoverTranslateY': hoverTranslateY,
  };
}

/// How a card responds to hover.
enum CardHoverEffect {
  /// Increases shadow and optionally lifts the card.
  shadow,

  /// Highlights the border color (shadcn style).
  borderHighlight,
}
