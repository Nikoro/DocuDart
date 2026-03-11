import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package:docudart/src/cli/errors.dart';
import 'package:docudart/src/models/versioning_config.dart';
import 'package:docudart/src/config/docudart_config.dart';
import 'package:docudart/src/processing/content_processor.dart';

/// Represents a versioned documentation set.
@immutable
class VersionedDocs {
  const VersionedDocs({
    required this.version,
    required this.isDefault,
    required this.isLatest,
    required this.pages,
    required this.rootFolder,
  });

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

  /// URL prefix for this version's docs.
  String get urlPrefix => '/$version${ContentProcessor.docsPathPrefix}';
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
  VersionManager(this.config)
    : _versionConfig = config.versioning ?? const VersioningConfig() {
    // Validate all version identifiers at construction time.
    for (final version in _versionConfig.versions) {
      _validateVersion(version);
    }
    if (_versionConfig.defaultVersion.isNotEmpty) {
      _validateVersion(_versionConfig.defaultVersion);
    }
  }

  static final _validVersion = RegExp(r'^[a-zA-Z0-9._-]+$');

  static void _validateVersion(String version) {
    if (!_validVersion.hasMatch(version)) {
      throw DocuDartException(
        'Invalid version identifier: "$version".',
        hint:
            'Version identifiers must match [a-zA-Z0-9._-] '
            '(letters, digits, dots, hyphens, underscores).',
      );
    }
  }

  final Config config;
  final VersioningConfig _versionConfig;

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
    for (int i = 0; i < versions.length; i++) {
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
          : [for (final page in pages) _withVersionedUrl(page, version)];

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
      CliPrinter.warning('Version directory not found: ${versionDir.path}');
      return null;
    }

    // Create a temporary config pointing to the version directory
    final versionConfig = config.copyWith(docsDir: versionDir.path);
    final processor = ContentProcessor(versionConfig);
    final (pages, rootFolder) = await processor.processAll();

    // Non-latest versions always get prefixed URLs unless they are default
    final versionedPages = isDefault
        ? pages
        : [for (final page in pages) _withVersionedUrl(page, version)];

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
    final DocPage(
      :relativePath,
      :urlPath,
      :meta,
      :html,
      :toc,
      :parentPath,
      :order,
    ) = page;
    // Transform /docs/foo -> /v1/docs/foo
    final versionedUrl = urlPath.replaceFirst('/docs', '/$version/docs');

    return DocPage(
      relativePath: relativePath,
      urlPath: versionedUrl,
      meta: meta,
      html: html,
      toc: toc,
      parentPath: parentPath,
      order: order,
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
}
