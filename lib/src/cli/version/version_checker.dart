import 'dart:convert';
import 'dart:io';

import 'installation_source.dart';

class VersionCheckResult {
  VersionCheckResult({
    required this.currentVersion,
    this.latestVersion,
    this.changelogUrl,
  });

  final String currentVersion;
  final String? latestVersion;
  final String? changelogUrl;

  bool get hasNewerVersion {
    if (latestVersion == null) return false;
    return _compareVersions(currentVersion, latestVersion!) < 0;
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < parts1.length && i < parts2.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }

    return parts1.length.compareTo(parts2.length);
  }
}

/// Checks for available updates of docudart.
Future<VersionCheckResult?> checkForUpdate(String currentVersion) async {
  final installationInfo = await detectInstallationSource();

  if (installationInfo.source == InstallationSource.git) {
    return _checkGitHubRelease(currentVersion, installationInfo.gitUrl);
  } else {
    return _checkPubDev(currentVersion);
  }
}

/// Check latest version from pub.dev.
Future<VersionCheckResult?> _checkPubDev(String currentVersion) async {
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    final request = await client.getUrl(
      Uri.parse('https://pub.dev/api/packages/docudart'),
    );
    final response = await request.close();

    if (response.statusCode != 200) {
      client.close();
      return null;
    }

    final body = await response.transform(utf8.decoder).join();
    client.close();

    final json = jsonDecode(body) as Map<String, dynamic>;
    final latest = json['latest'] as Map<String, dynamic>?;
    if (latest == null) return null;

    final latestVersion = latest['version'] as String?;

    return VersionCheckResult(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      changelogUrl: 'https://pub.dev/packages/docudart/changelog',
    );
  } catch (e) {
    return null;
  }
}

/// Check latest version from GitHub releases.
Future<VersionCheckResult?> _checkGitHubRelease(
  String currentVersion,
  String? gitUrl,
) async {
  try {
    // Extract owner/repo from git URL
    final match = RegExp(
      r'github\.com[:/]([^/]+)/([^/.]+)',
    ).firstMatch(gitUrl ?? '');
    if (match == null) return null;

    final owner = match.group(1);
    final repo = match.group(2);

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    final request = await client.getUrl(
      Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest'),
    );
    request.headers.set('Accept', 'application/vnd.github.v3+json');
    final response = await request.close();

    if (response.statusCode != 200) {
      client.close();
      return null;
    }

    final body = await response.transform(utf8.decoder).join();
    client.close();

    final json = jsonDecode(body) as Map<String, dynamic>;
    final tagName = json['tag_name'] as String?;
    if (tagName == null) return null;

    // Remove 'v' prefix if present
    final latestVersion = tagName.startsWith('v')
        ? tagName.substring(1)
        : tagName;

    return VersionCheckResult(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      changelogUrl: 'https://github.com/$owner/$repo/releases/tag/$tagName',
    );
  } catch (e) {
    return null;
  }
}
