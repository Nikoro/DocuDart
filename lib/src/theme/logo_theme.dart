import 'package:meta/meta.dart';

/// Theme for the site logo.
@immutable
class LogoTheme {
  const LogoTheme({
    this.fontSize = 1.25,
    this.fontWeight = 600,
    this.imageHeight = 1.75,
  });

  const LogoTheme.classic({
    this.fontSize = 1.25,
    this.fontWeight = 600,
    this.imageHeight = 1.75,
  });

  const LogoTheme.material3({
    this.fontSize = 1.25,
    this.fontWeight = 500,
    this.imageHeight = 1.75,
  });

  const LogoTheme.shadcn({
    this.fontSize = 1.125,
    this.fontWeight = 700,
    this.imageHeight = 1.5,
  });

  factory LogoTheme.fromJson(Map<String, dynamic> json) => LogoTheme(
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? 1.25,
    fontWeight: json['fontWeight'] as int? ?? 600,
    imageHeight: (json['imageHeight'] as num?)?.toDouble() ?? 1.75,
  );

  /// Logo title font size in rem.
  final double fontSize;

  /// Logo title font weight.
  final int fontWeight;

  /// Logo image height in rem.
  final double imageHeight;

  LogoTheme copyWith({
    double? fontSize,
    int? fontWeight,
    double? imageHeight,
  }) => LogoTheme(
    fontSize: fontSize ?? this.fontSize,
    fontWeight: fontWeight ?? this.fontWeight,
    imageHeight: imageHeight ?? this.imageHeight,
  );

  Map<String, dynamic> toJson() => {
    'fontSize': fontSize,
    'fontWeight': fontWeight,
    'imageHeight': imageHeight,
  };
}
