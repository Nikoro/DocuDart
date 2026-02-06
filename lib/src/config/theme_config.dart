/// Theme mode configuration options.
enum ThemeMode {
  /// Follow system preference.
  system,

  /// Always use light mode.
  light,

  /// Always use dark mode.
  dark;

  String toJson() => name;

  static ThemeMode fromJson(String value) {
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
