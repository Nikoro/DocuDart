import 'package:meta/meta.dart';

import 'theme_colors.dart';
import 'theme_typography.dart';
import '../config/theme_config.dart';

/// Base class for DocuDart themes.
@immutable
abstract class BaseTheme {
  /// Theme identifier.
  String get name;

  /// Color configuration.
  ThemeColors get colors;

  /// Typography configuration.
  ThemeTypography get typography;

  /// Dark mode configuration.
  DarkModeConfig get darkMode;

  const BaseTheme();

  Map<String, dynamic> toJson() => {
    'name': name,
    'colors': colors.toJson(),
    'typography': typography.toJson(),
    'darkMode': darkMode.toJson(),
  };
}
