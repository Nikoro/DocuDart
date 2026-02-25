import 'package:meta/meta.dart';

/// Theme for icon buttons.
@immutable
class IconButtonTheme {
  const IconButtonTheme({
    this.padding = 0.5,
    this.borderRadius = 0.375,
    this.iconSize = 1.25,
  });

  const IconButtonTheme.classic({
    this.padding = 0.5,
    this.borderRadius = 0.375,
    this.iconSize = 1.25,
  });

  const IconButtonTheme.material3({
    this.padding = 0.5,
    this.borderRadius = 0.375,
    this.iconSize = 1.25,
  });

  const IconButtonTheme.shadcn({
    this.padding = 0.5,
    this.borderRadius = 0.375,
    this.iconSize = 1.25,
  });

  factory IconButtonTheme.fromJson(Map<String, dynamic> json) =>
      IconButtonTheme(
        padding: (json['padding'] as num?)?.toDouble() ?? 0.5,
        borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.375,
        iconSize: (json['iconSize'] as num?)?.toDouble() ?? 1.25,
      );

  /// Button padding in rem.
  final double padding;

  /// Border radius in rem.
  final double borderRadius;

  /// Icon size in rem.
  final double iconSize;

  IconButtonTheme copyWith({
    double? padding,
    double? borderRadius,
    double? iconSize,
  }) => IconButtonTheme(
    padding: padding ?? this.padding,
    borderRadius: borderRadius ?? this.borderRadius,
    iconSize: iconSize ?? this.iconSize,
  );

  Map<String, dynamic> toJson() => {
    'padding': padding,
    'borderRadius': borderRadius,
    'iconSize': iconSize,
  };
}
