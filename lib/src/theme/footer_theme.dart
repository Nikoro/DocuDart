import 'package:meta/meta.dart';

/// Theme for the site footer.
@immutable
class FooterTheme {
  const FooterTheme({this.paddingH = 2.0, this.paddingV = 2.0});

  const FooterTheme.classic() : this();

  const FooterTheme.material3({this.paddingH = 2.0, this.paddingV = 2.0});

  const FooterTheme.shadcn({this.paddingH = 2.0, this.paddingV = 1.5});

  factory FooterTheme.fromJson(Map<String, dynamic> json) => .new(
    paddingH: (json['paddingH'] as num?)?.toDouble() ?? 2.0,
    paddingV: (json['paddingV'] as num?)?.toDouble() ?? 2.0,
  );

  /// Horizontal padding in rem.
  final double paddingH;

  /// Vertical padding in rem.
  final double paddingV;

  FooterTheme copyWith({double? paddingH, double? paddingV}) => .new(
    paddingH: paddingH ?? this.paddingH,
    paddingV: paddingV ?? this.paddingV,
  );

  Map<String, dynamic> toJson() => {'paddingH': paddingH, 'paddingV': paddingV};
}
