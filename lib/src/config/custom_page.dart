import 'package:meta/meta.dart';

/// A custom page written in Dart/Jaspr.
@immutable
class CustomPage {
  /// URL path for this page.
  final String path;

  /// Path to the Dart file containing the page component.
  final String filePath;

  const CustomPage({required this.path, required this.filePath});
}
