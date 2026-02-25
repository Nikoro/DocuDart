import 'package:meta/meta.dart';

/// Theme for the landing/home page.
@immutable
class LandingTheme {
  const LandingTheme({
    this.paddingV = 4.0,
    this.titleFontSize = 3.0,
    this.descriptionFontSize = 1.25,
  });

  const LandingTheme.classic({
    this.paddingV = 4.0,
    this.titleFontSize = 3.0,
    this.descriptionFontSize = 1.25,
  });

  const LandingTheme.material3({
    this.paddingV = 5.0,
    this.titleFontSize = 2.75,
    this.descriptionFontSize = 1.25,
  });

  const LandingTheme.shadcn({
    this.paddingV = 4.0,
    this.titleFontSize = 3.0,
    this.descriptionFontSize = 1.25,
  });

  factory LandingTheme.fromJson(Map<String, dynamic> json) => .new(
    paddingV: (json['paddingV'] as num?)?.toDouble() ?? 4.0,
    titleFontSize: (json['titleFontSize'] as num?)?.toDouble() ?? 3.0,
    descriptionFontSize:
        (json['descriptionFontSize'] as num?)?.toDouble() ?? 1.25,
  );

  /// Vertical padding in rem.
  final double paddingV;

  /// Title font size in rem.
  final double titleFontSize;

  /// Description font size in rem.
  final double descriptionFontSize;

  LandingTheme copyWith({
    double? paddingV,
    double? titleFontSize,
    double? descriptionFontSize,
  }) => .new(
    paddingV: paddingV ?? this.paddingV,
    titleFontSize: titleFontSize ?? this.titleFontSize,
    descriptionFontSize: descriptionFontSize ?? this.descriptionFontSize,
  );

  Map<String, dynamic> toJson() => {
    'paddingV': paddingV,
    'titleFontSize': titleFontSize,
    'descriptionFontSize': descriptionFontSize,
  };
}
