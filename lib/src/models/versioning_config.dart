import 'package:meta/meta.dart';

/// Configuration for documentation versioning.
@immutable
class VersioningConfig {
  const VersioningConfig({
    this.enabled = false,
    this.versions = const [],
    this.defaultVersion = '',
    this.versionDir = 'versions',
  });

  factory VersioningConfig.fromJson(Map<String, dynamic> json) => .new(
    enabled: json['enabled'] as bool? ?? false,
    versions: switch (json['versions'] as List<dynamic>?) {
      final list? => [for (final e in list) e as String],
      null => const <String>[],
    },
    defaultVersion: json['defaultVersion'] as String? ?? '',
    versionDir: json['versionDir'] as String? ?? 'versions',
  );

  /// Whether versioning is enabled.
  final bool enabled;

  /// List of available versions.
  final List<String> versions;

  /// Default version to show.
  final String defaultVersion;

  /// Directory containing versioned docs.
  final String versionDir;

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'versions': versions,
    'defaultVersion': defaultVersion,
    'versionDir': versionDir,
  };
}
