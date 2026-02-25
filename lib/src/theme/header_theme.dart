import 'package:meta/meta.dart';

/// Theme for the site header.
@immutable
class HeaderTheme {
  const HeaderTheme({
    this.paddingH = 2.0,
    this.paddingV = 1.0,
    this.hasBoxShadow = false,
    this.shadowBlur = 3,
    this.shadowOpacity = 0.08,
  });

  const HeaderTheme.classic({
    this.paddingH = 2.0,
    this.paddingV = 1.0,
    this.hasBoxShadow = false,
    this.shadowBlur = 3,
    this.shadowOpacity = 0.08,
  });

  const HeaderTheme.material3({
    this.paddingH = 2.0,
    this.paddingV = 1.0,
    this.hasBoxShadow = true,
    this.shadowBlur = 3,
    this.shadowOpacity = 0.08,
  });

  const HeaderTheme.shadcn({
    this.paddingH = 2.0,
    this.paddingV = 0.75,
    this.hasBoxShadow = false,
    this.shadowBlur = 3,
    this.shadowOpacity = 0.08,
  });

  factory HeaderTheme.fromJson(Map<String, dynamic> json) => .new(
    paddingH: (json['paddingH'] as num?)?.toDouble() ?? 2.0,
    paddingV: (json['paddingV'] as num?)?.toDouble() ?? 1.0,
    hasBoxShadow: json['hasBoxShadow'] as bool? ?? false,
    shadowBlur: (json['shadowBlur'] as num?)?.toDouble() ?? 3,
    shadowOpacity: (json['shadowOpacity'] as num?)?.toDouble() ?? 0.08,
  );

  /// Horizontal padding in rem.
  final double paddingH;

  /// Vertical padding in rem.
  final double paddingV;

  /// Whether the header has a box shadow.
  final bool hasBoxShadow;

  /// Shadow blur radius in pixels.
  final double shadowBlur;

  /// Shadow opacity (0.0–1.0).
  final double shadowOpacity;

  HeaderTheme copyWith({
    double? paddingH,
    double? paddingV,
    bool? hasBoxShadow,
    double? shadowBlur,
    double? shadowOpacity,
  }) => .new(
    paddingH: paddingH ?? this.paddingH,
    paddingV: paddingV ?? this.paddingV,
    hasBoxShadow: hasBoxShadow ?? this.hasBoxShadow,
    shadowBlur: shadowBlur ?? this.shadowBlur,
    shadowOpacity: shadowOpacity ?? this.shadowOpacity,
  );

  Map<String, dynamic> toJson() => {
    'paddingH': paddingH,
    'paddingV': paddingV,
    'hasBoxShadow': hasBoxShadow,
    'shadowBlur': shadowBlur,
    'shadowOpacity': shadowOpacity,
  };
}
