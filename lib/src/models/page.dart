import 'package:meta/meta.dart';

/// Metadata for an auto-discovered page from the pages/ directory.
@immutable
class Page {
  const Page({required this.path, required this.name});

  factory Page.fromJson(Map<String, dynamic> json) =>
      Page(path: json['path'] as String, name: json['name'] as String);

  /// URL route path (e.g., '/changelog', '/something/some').
  final String path;

  /// Human-readable display name (e.g., 'Changelog', 'Some').
  final String name;

  Map<String, dynamic> toJson() => {'path': path, 'name': name};
}
