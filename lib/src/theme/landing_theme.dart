import 'package:meta/meta.dart';

/// Theme for the landing/home page.
@immutable
class LandingTheme {
  const LandingTheme({
    this.paddingV = 4.0,
    this.titleFontSize = 3.0,
    this.descriptionFontSize = 1.25,
    this.mobilePaddingH = 1.0,
    this.mobileTitleFontSize = 2.0,
    this.mobileDescriptionFontSize = 1.0,
  });

  const LandingTheme.classic({
    this.paddingV = 4.0,
    this.titleFontSize = 3.0,
    this.descriptionFontSize = 1.25,
    this.mobilePaddingH = 1.0,
    this.mobileTitleFontSize = 2.0,
    this.mobileDescriptionFontSize = 1.0,
  });

  const LandingTheme.material3({
    this.paddingV = 5.0,
    this.titleFontSize = 2.75,
    this.descriptionFontSize = 1.25,
    this.mobilePaddingH = 1.0,
    this.mobileTitleFontSize = 2.0,
    this.mobileDescriptionFontSize = 1.0,
  });

  const LandingTheme.shadcn({
    this.paddingV = 4.0,
    this.titleFontSize = 3.0,
    this.descriptionFontSize = 1.25,
    this.mobilePaddingH = 1.0,
    this.mobileTitleFontSize = 2.0,
    this.mobileDescriptionFontSize = 1.0,
  });

  factory LandingTheme.fromJson(Map<String, dynamic> json) => .new(
    paddingV: (json['paddingV'] as num?)?.toDouble() ?? 4.0,
    titleFontSize: (json['titleFontSize'] as num?)?.toDouble() ?? 3.0,
    descriptionFontSize:
        (json['descriptionFontSize'] as num?)?.toDouble() ?? 1.25,
    mobilePaddingH: (json['mobilePaddingH'] as num?)?.toDouble() ?? 1.0,
    mobileTitleFontSize:
        (json['mobileTitleFontSize'] as num?)?.toDouble() ?? 2.0,
    mobileDescriptionFontSize:
        (json['mobileDescriptionFontSize'] as num?)?.toDouble() ?? 1.0,
  );

  /// Vertical padding in rem.
  final double paddingV;

  /// Title font size in rem.
  final double titleFontSize;

  /// Description font size in rem.
  final double descriptionFontSize;

  /// Horizontal padding in rem on mobile (≤768px).
  final double mobilePaddingH;

  /// Title font size in rem on mobile (≤768px).
  final double mobileTitleFontSize;

  /// Description font size in rem on mobile (≤768px).
  final double mobileDescriptionFontSize;

  LandingTheme copyWith({
    double? paddingV,
    double? titleFontSize,
    double? descriptionFontSize,
    double? mobilePaddingH,
    double? mobileTitleFontSize,
    double? mobileDescriptionFontSize,
  }) => .new(
    paddingV: paddingV ?? this.paddingV,
    titleFontSize: titleFontSize ?? this.titleFontSize,
    descriptionFontSize: descriptionFontSize ?? this.descriptionFontSize,
    mobilePaddingH: mobilePaddingH ?? this.mobilePaddingH,
    mobileTitleFontSize: mobileTitleFontSize ?? this.mobileTitleFontSize,
    mobileDescriptionFontSize:
        mobileDescriptionFontSize ?? this.mobileDescriptionFontSize,
  );

  Map<String, dynamic> toJson() => {
    'paddingV': paddingV,
    'titleFontSize': titleFontSize,
    'descriptionFontSize': descriptionFontSize,
    'mobilePaddingH': mobilePaddingH,
    'mobileTitleFontSize': mobileTitleFontSize,
    'mobileDescriptionFontSize': mobileDescriptionFontSize,
  };
}
