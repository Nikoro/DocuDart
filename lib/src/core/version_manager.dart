import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/versioning_config.dart';
import '../config/docudart_config.dart';
import 'content_processor.dart';

/// Represents a versioned documentation set.
class VersionedDocs {
  /// Version identifier (e.g., 'v1', 'v2', '1.0.0').
  final String version;

  /// Whether this is the default version.
  final bool isDefault;

  /// Whether this is the latest version.
  final bool isLatest;

  /// All pages in this version.
  final List<DocPage> pages;

  /// Folder structure for this version.
  final DocFolder rootFolder;

  const VersionedDocs({
    required this.version,
    required this.isDefault,
    required this.isLatest,
    required this.pages,
    required this.rootFolder,
  });

  /// URL prefix for this version's docs.
  String get urlPrefix => '/$version/docs';
}

/// Manages versioned documentation.
///
/// Handles version folder structure:
/// ```
/// docs/           # Current/latest version
/// versions/
///   v1/           # Older version
///   v2/           # Another version
/// ```
class VersionManager {
  final Config config;
  final VersioningConfig _versionConfig;

  VersionManager(this.config)
    : _versionConfig = config.versioning ?? const VersioningConfig();

  /// Whether versioning is enabled.
  bool get isEnabled =>
      _versionConfig.enabled && _versionConfig.versions.isNotEmpty;

  /// List of all available versions.
  List<String> get versions => _versionConfig.versions;

  /// The default version to display.
  String get defaultVersion {
    if (_versionConfig.defaultVersion.isNotEmpty) {
      return _versionConfig.defaultVersion;
    }
    // Fall back to latest version
    return versions.isNotEmpty ? versions.last : 'latest';
  }

  /// The latest version (typically the last in the list).
  String get latestVersion => versions.isNotEmpty ? versions.last : 'latest';

  /// Process all versioned documentation.
  ///
  /// Returns a map of version -> VersionedDocs.
  Future<Map<String, VersionedDocs>> processAllVersions() async {
    if (!isEnabled) {
      // No versioning - just process main docs
      final processor = ContentProcessor(config);
      final (pages, rootFolder) = await processor.processAll();

      return {
        'latest': VersionedDocs(
          version: 'latest',
          isDefault: true,
          isLatest: true,
          pages: pages,
          rootFolder: rootFolder,
        ),
      };
    }

    final result = <String, VersionedDocs>{};

    // Process each version
    for (var i = 0; i < versions.length; i++) {
      final version = versions[i];
      final isLatest = i == versions.length - 1;
      final isDefault = version == defaultVersion;

      final versionedDocs = await _processVersion(version, isDefault, isLatest);
      if (versionedDocs != null) {
        result[version] = versionedDocs;
      }
    }

    // If latest version uses main docs/ folder
    if (!result.containsKey(latestVersion)) {
      final processor = ContentProcessor(config);
      final (pages, rootFolder) = await processor.processAll();

      result[latestVersion] = VersionedDocs(
        version: latestVersion,
        isDefault: latestVersion == defaultVersion,
        isLatest: true,
        pages: pages,
        rootFolder: rootFolder,
      );
    }

    return result;
  }

  /// Process documentation for a specific version.
  Future<VersionedDocs?> _processVersion(
    String version,
    bool isDefault,
    bool isLatest,
  ) async {
    // Check if this version uses the main docs/ folder (latest)
    if (isLatest) {
      final processor = ContentProcessor(config);
      final (pages, rootFolder) = await processor.processAll();

      // For latest/default version, keep URLs as-is (/docs/...)
      // Other versions get prefixed (/v1/docs/...)
      final versionedPages = isDefault
          ? pages
          : pages.map((page) => _withVersionedUrl(page, version)).toList();

      return VersionedDocs(
        version: version,
        isDefault: isDefault,
        isLatest: true,
        pages: versionedPages,
        rootFolder: rootFolder,
      );
    }

    // Look for version in versions/ directory
    final versionDir = Directory(p.join(_versionConfig.versionDir, version));
    if (!versionDir.existsSync()) {
      print('Warning: Version directory not found: ${versionDir.path}');
      return null;
    }

    // Create a temporary config pointing to the version directory
    final versionConfig = config.copyWith(docsDir: versionDir.path);
    final processor = ContentProcessor(versionConfig);
    final (pages, rootFolder) = await processor.processAll();

    // Non-latest versions always get prefixed URLs unless they are default
    final versionedPages = isDefault
        ? pages
        : pages.map((page) => _withVersionedUrl(page, version)).toList();

    return VersionedDocs(
      version: version,
      isDefault: isDefault,
      isLatest: false,
      pages: versionedPages,
      rootFolder: rootFolder,
    );
  }

  /// Create a new DocPage with a versioned URL path.
  DocPage _withVersionedUrl(DocPage page, String version) {
    // Transform /docs/foo -> /v1/docs/foo
    final versionedUrl = page.urlPath.replaceFirst('/docs', '/$version/docs');

    return DocPage(
      relativePath: page.relativePath,
      urlPath: versionedUrl,
      meta: page.meta,
      html: page.html,
      toc: page.toc,
      parentPath: page.parentPath,
      order: page.order,
    );
  }

  /// Get the path to a specific version's docs directory.
  String getVersionDocsPath(String version) {
    if (version == latestVersion) {
      return config.docsDir;
    }
    return p.join(_versionConfig.versionDir, version);
  }

  /// Check if a given path matches a versioned route.
  ///
  /// Returns the version if matched, null otherwise.
  String? extractVersionFromPath(String path) {
    for (final version in versions) {
      if (path.startsWith('/$version/')) {
        return version;
      }
    }
    return null;
  }

  /// Generate version switcher data for templates.
  List<VersionSwitcherItem> getVersionSwitcherItems(String currentVersion) {
    return versions.map((version) {
      return VersionSwitcherItem(
        version: version,
        label: _formatVersionLabel(version),
        isCurrent: version == currentVersion,
        isLatest: version == latestVersion,
        isDefault: version == defaultVersion,
      );
    }).toList();
  }

  String _formatVersionLabel(String version) {
    // Add badges for latest/default
    final badges = <String>[];
    if (version == latestVersion) badges.add('latest');
    if (version == defaultVersion && version != latestVersion) {
      badges.add('default');
    }

    if (badges.isEmpty) return version;
    return '$version (${badges.join(', ')})';
  }
}

/// Item for the version switcher dropdown.
class VersionSwitcherItem {
  final String version;
  final String label;
  final bool isCurrent;
  final bool isLatest;
  final bool isDefault;

  const VersionSwitcherItem({
    required this.version,
    required this.label,
    required this.isCurrent,
    required this.isLatest,
    required this.isDefault,
  });
}
