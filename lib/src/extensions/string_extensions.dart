/// Internal string utilities used by generators and processors.
extension StringTitleCase on String {
  /// Converts a space-separated string to Title Case.
  ///
  /// Each word's first letter is uppercased and the rest lowercased.
  /// Empty words are preserved as-is.
  String toTitleCase() => split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .join(' ');
}
