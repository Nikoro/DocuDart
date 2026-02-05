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
}
