import 'package:docudart/docudart.dart';

/// Branding component showing a copyright notice.
///
/// ```dart
/// Copyright(text: 'My Company')
/// Copyright(text: 'My Company', year: 2024)
/// ```
class Copyright extends StatelessComponent {
  const Copyright({required this.text, this.year, super.key});

  /// The copyright holder name.
  final String text;

  /// Override year. Defaults to the current year at build time.
  final int? year;

  @override
  Component build(BuildContext context) {
    final y = year ?? DateTime.now().year;
    return p([.text('© $y $text')]);
  }
}
