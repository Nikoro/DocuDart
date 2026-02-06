import 'package:meta/meta.dart';

/// Configuration for documentation versioning.
@immutable
class VersioningConfig {
  /// Whether versioning is enabled.
  final bool enabled;

  /// List of available versions.
  final List<String> versions;

  /// Default version to show.
  final String defaultVersion;

  /// Directory containing versioned docs.
  final String versionDir;

  const VersioningConfig({
    this.enabled = false,
    this.versions = const [],
    this.defaultVersion = '',
    this.versionDir = 'versions',
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'versions': versions,
    'defaultVersion': defaultVersion,
    'versionDir': versionDir,
  };

  factory VersioningConfig.fromJson(Map<String, dynamic> json) =>
      VersioningConfig(
        enabled: json['enabled'] as bool? ?? false,
        versions: (json['versions'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        defaultVersion: json['defaultVersion'] as String? ?? '',
        versionDir: json['versionDir'] as String? ?? 'versions',
      );
}
