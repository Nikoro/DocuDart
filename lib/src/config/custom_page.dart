import 'package:meta/meta.dart';

/// A custom page written in Dart/Jaspr.
@immutable
class CustomPage {
  const CustomPage({required this.path, required this.filePath});

  factory CustomPage.fromJson(Map<String, dynamic> json) => CustomPage(
    path: json['path'] as String,
    filePath: json['filePath'] as String,
  );

  /// URL path for this page.
  final String path;

  /// Path to the Dart file containing the page component.
  final String filePath;

  Map<String, dynamic> toJson() => {'path': path, 'filePath': filePath};
}
