import 'package:meta/meta.dart';

/// Theme for callout/admonition components.
@immutable
class CalloutTheme {
  const CalloutTheme({
    this.padding = 1.0,
    this.borderRadius = 0.5,
    this.borderWidth = 4,
  });

  const CalloutTheme.classic({
    this.padding = 1.0,
    this.borderRadius = 0.5,
    this.borderWidth = 4,
  });

  const CalloutTheme.material3({
    this.padding = 1.25,
    this.borderRadius = 0.75,
    this.borderWidth = 3,
  });

  const CalloutTheme.shadcn({
    this.padding = 1.0,
    this.borderRadius = 0.375,
    this.borderWidth = 2,
  });

  factory CalloutTheme.fromJson(Map<String, dynamic> json) => CalloutTheme(
    padding: (json['padding'] as num?)?.toDouble() ?? 1.0,
    borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.5,
    borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 4,
  );

  /// Callout padding in rem.
  final double padding;

  /// Callout border radius in rem.
  final double borderRadius;

  /// Left border width in pixels.
  final double borderWidth;

  CalloutTheme copyWith({
    double? padding,
    double? borderRadius,
    double? borderWidth,
  }) => CalloutTheme(
    padding: padding ?? this.padding,
    borderRadius: borderRadius ?? this.borderRadius,
    borderWidth: borderWidth ?? this.borderWidth,
  );

  Map<String, dynamic> toJson() => {
    'padding': padding,
    'borderRadius': borderRadius,
    'borderWidth': borderWidth,
  };
}
