import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'package:docudart/src/constants.dart';
import 'package:docudart/src/cli/version/installation_source.dart';

@immutable
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
    // Strip pre-release/build-metadata suffixes (e.g. "1.0.0-beta.1+build.2")
    final core1 = v1.split(RegExp(r'[-+]')).first;
    final core2 = v2.split(RegExp(r'[-+]')).first;
    final parts1 = core1.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final parts2 = core2.split('.').map((s) => int.tryParse(s) ?? 0).toList();

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

  if (installationInfo.source == .git) {
    return _checkGitHubRelease(currentVersion, installationInfo.gitUrl);
  } else {
    return _checkPubDev(currentVersion);
  }
}

/// Check latest version from pub.dev.
Future<VersionCheckResult?> _checkPubDev(String currentVersion) async {
  final client = HttpClient();
  try {
    client.connectionTimeout = httpTimeout;
    final request = await client.getUrl(
      Uri.parse('https://pub.dev/api/packages/docudart'),
    );
    final response = await request.close();

    if (response.statusCode != 200) return null;

    final body = await response.transform(utf8.decoder).join();

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
  } finally {
    client.close();
  }
}

/// Check latest version from GitHub releases.
Future<VersionCheckResult?> _checkGitHubRelease(
  String currentVersion,
  String? gitUrl,
) async {
  // Extract owner/repo from git URL
  final match = RegExp(
    r'github\.com[:/]([^/]+)/([^/.]+)',
  ).firstMatch(gitUrl ?? '');
  if (match == null) return null;

  final owner = match.group(1);
  final repo = match.group(2);

  final client = HttpClient();
  try {
    client.connectionTimeout = httpTimeout;
    final request = await client.getUrl(
      Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest'),
    );
    request.headers.set('Accept', 'application/vnd.github.v3+json');
    final response = await request.close();

    if (response.statusCode != 200) return null;

    final body = await response.transform(utf8.decoder).join();

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
  } finally {
    client.close();
  }
}
