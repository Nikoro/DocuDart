/// Dark mode configuration options.
enum DarkModeConfig {
  /// Follow system preference.
  system,

  /// Always use light mode.
  light,

  /// Always use dark mode.
  dark,

  /// Show toggle, default to system preference.
  toggle;

  String toJson() => name;

  static DarkModeConfig fromJson(String value) {
    return DarkModeConfig.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DarkModeConfig.system,
    );
  }
}
