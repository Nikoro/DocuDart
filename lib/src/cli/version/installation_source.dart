import 'dart:io';

enum InstallationSource { git, hosted }

class InstallationInfo {
  InstallationInfo({
    required this.source,
    this.gitUrl,
    this.gitRef,
    this.version,
  });

  final InstallationSource source;
  final String? gitUrl;
  final String? gitRef;
  final String? version;
}

/// Detects the installation source of docudart from the global pub cache.
Future<InstallationInfo> detectInstallationSource() async {
  try {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      return InstallationInfo(source: InstallationSource.hosted);
    }

    final pubCachePath =
        Platform.environment['PUB_CACHE'] ?? '$home/.pub-cache';
    final pubspecLockPath =
        '$pubCachePath/global_packages/docudart/pubspec.lock';
    final pubspecLockFile = File(pubspecLockPath);

    if (!await pubspecLockFile.exists()) {
      return InstallationInfo(source: InstallationSource.hosted);
    }

    final content = await pubspecLockFile.readAsString();

    // Parse the pubspec.lock to find the docudart package entry
    final docudartSection = RegExp(
      r'docudart:.*?source:\s*(\w+)',
      dotAll: true,
    ).firstMatch(content);

    if (docudartSection != null) {
      final source = docudartSection.group(1);

      if (source == 'git') {
        // Extract git URL and ref
        final gitUrlMatch = RegExp(r'url:\s*"([^"]+)"').firstMatch(content);

        final gitRefMatch = RegExp(
          r'resolved-ref:\s*"?([a-f0-9]+)"?',
        ).firstMatch(content);

        return InstallationInfo(
          source: InstallationSource.git,
          gitUrl: gitUrlMatch?.group(1),
          gitRef: gitRefMatch?.group(1),
        );
      } else if (source == 'hosted') {
        // Extract version from pub.dev
        final versionMatch = RegExp(
          r'docudart:.*?version:\s*"([^"]+)"',
          dotAll: true,
        ).firstMatch(content);

        return InstallationInfo(
          source: InstallationSource.hosted,
          version: versionMatch?.group(1),
        );
      }
    }

    // Default to hosted (pub.dev)
    return InstallationInfo(source: InstallationSource.hosted);
  } catch (e) {
    // If we can't detect, assume hosted (pub.dev)
    return InstallationInfo(source: InstallationSource.hosted);
  }
}
