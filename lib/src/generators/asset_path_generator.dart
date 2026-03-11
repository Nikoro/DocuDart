import 'dart:io';

import 'package:path/path.dart' as p;

/// Scans an assets directory and generates typed Dart source for the
/// asset tree, with theme-aware support for `light/` and `dark/` subdirectories.
///
/// Used by [SiteGenerator] to embed asset data in `project_data.dart`.
class AssetPathGenerator {
  AssetPathGenerator._();

  /// Theme variant directory names (reserved, not included in the asset tree
  /// as regular subdirectories).
  static const _themeVariants = {'light', 'dark'};

  /// Generate Dart source for the project asset tree classes.
  ///
  /// Scans [assetsDir] (excluding `light/` and `dark/` at the root level),
  /// then scans `light/` and `dark/` separately, merging them into a single
  /// tree where files that exist in multiple variants become `ThemedAsset`
  /// and files with a single source become `SimpleAsset`.
  ///
  /// Returns empty string if [assetsDir] does not exist or has no assets.
  static String generateProjectAssets(String assetsDir) {
    final dir = Directory(assetsDir);
    if (!dir.existsSync()) return _emptyAssets();

    // Scan root (excluding theme variant dirs and special files).
    final rootFiles = _collectFiles(dir, exclude: _themeVariants);

    // Scan light/ and dark/ variant dirs.
    final lightDir = Directory(p.join(assetsDir, 'light'));
    final darkDir = Directory(p.join(assetsDir, 'dark'));
    final lightFiles = lightDir.existsSync()
        ? _collectFiles(lightDir)
        : <String, String>{};
    final darkFiles = darkDir.existsSync()
        ? _collectFiles(darkDir)
        : <String, String>{};

    // Merge into a unified asset tree.
    final merged = _mergeAssets(rootFiles, lightFiles, darkFiles);
    if (merged.isEmpty) return _emptyAssets();

    // Build a hierarchical tree from the flat merged map.
    final tree = _buildTree(merged);

    return _generateCode(tree);
  }

  // ---------------------------------------------------------------------------
  // File collection
  // ---------------------------------------------------------------------------

  /// Recursively collect files from [dir], returning a map of
  /// relative path → web path.
  ///
  /// [exclude] is a set of root-level directory names to skip.
  static Map<String, String> _collectFiles(
    Directory dir, {
    Set<String> exclude = const {},
  }) {
    final files = <String, String>{};
    _collectFilesRecursive(dir, dir.path, '', exclude, files);
    return files;
  }

  static void _collectFilesRecursive(
    Directory dir,
    String baseDir,
    String relativePath,
    Set<String> exclude,
    Map<String, String> result,
  ) {
    final entities = dir.listSync()..sort((a, b) => a.path.compareTo(b.path));

    for (final entity in entities) {
      final name = p.basename(entity.path);

      // Skip hidden files/dirs and the legacy assets.dart.
      if (name.startsWith('.') || name == 'assets.dart') continue;

      final relPath = relativePath.isEmpty ? name : '$relativePath/$name';

      if (entity is File) {
        result[relPath] = name;
      } else if (entity is Directory) {
        if (exclude.contains(name)) continue;
        _collectFilesRecursive(entity, baseDir, relPath, const {}, result);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Merging
  // ---------------------------------------------------------------------------

  /// Merge root, light, and dark file maps into a flat map of
  /// relative path → [_MergedAsset].
  ///
  /// Priority rules:
  /// - light + dark exist → ThemedAsset(light: light/..., dark: dark/...)
  /// - root + light only  → ThemedAsset(light: light/..., dark: root/...)
  /// - root + dark only   → ThemedAsset(light: root/..., dark: dark/...)
  /// - root only          → SimpleAsset(root/...)
  /// - light only         → SimpleAsset(light/...)
  /// - dark only          → SimpleAsset(dark/...)
  static Map<String, _MergedAsset> _mergeAssets(
    Map<String, String> rootFiles,
    Map<String, String> lightFiles,
    Map<String, String> darkFiles,
  ) {
    final allKeys = <String>{
      ...rootFiles.keys,
      ...lightFiles.keys,
      ...darkFiles.keys,
    };

    final merged = <String, _MergedAsset>{};

    for (final key in allKeys) {
      final inRoot = rootFiles.containsKey(key);
      final inLight = lightFiles.containsKey(key);
      final inDark = darkFiles.containsKey(key);

      final rootPath = '/assets/$key';
      final lightPath = '/assets/light/$key';
      final darkPath = '/assets/dark/$key';

      if (inLight && inDark) {
        merged[key] = _MergedAsset.themed(lightPath, darkPath);
      } else if (inRoot && inLight) {
        merged[key] = _MergedAsset.themed(lightPath, rootPath);
      } else if (inRoot && inDark) {
        merged[key] = _MergedAsset.themed(rootPath, darkPath);
      } else if (inRoot) {
        merged[key] = _MergedAsset.simple(rootPath);
      } else if (inLight) {
        merged[key] = _MergedAsset.simple(lightPath);
      } else {
        merged[key] = _MergedAsset.simple(darkPath);
      }
    }

    return merged;
  }

  // ---------------------------------------------------------------------------
  // Tree building
  // ---------------------------------------------------------------------------

  /// Build a hierarchical [_AssetNode] tree from a flat map of
  /// relative paths to merged assets.
  static _AssetNode _buildTree(Map<String, _MergedAsset> merged) {
    final root = _AssetNode(name: 'assets', identifier: 'assets');

    for (final entry in merged.entries) {
      final parts = entry.key.split('/');
      _AssetNode node = root;

      // Navigate/create intermediate directory nodes.
      for (int i = 0; i < parts.length - 1; i++) {
        final dirName = parts[i];
        final id = _toIdentifier(dirName);
        node = node.dirs.putIfAbsent(
          dirName,
          () => _AssetNode(name: dirName, identifier: id),
        );
      }

      // Add the file leaf.
      final fileName = parts.last;
      node.files[fileName] = _AssetLeaf(
        identifier: _toIdentifier(fileName),
        asset: entry.value,
      );
    }

    return root;
  }

  // ---------------------------------------------------------------------------
  // Code generation
  // ---------------------------------------------------------------------------

  static String _generateCode(_AssetNode root) {
    final buffer = StringBuffer();

    // Generate the root class.
    buffer.writeln('class _ProjectAssets {');
    buffer.writeln('  _ProjectAssets();');
    _writeNodeFields(buffer, root, '_ProjectAssets');
    buffer.writeln('}');
    buffer.writeln();

    // Generate nested classes (depth-first).
    _generateNodeClasses(buffer, root, '_ProjectAssets');

    return buffer.toString();
  }

  static void _writeNodeFields(
    StringBuffer buffer,
    _AssetNode node,
    String className,
  ) {
    // File leaves.
    for (final entry in node.files.entries) {
      final leaf = entry.value;
      final _MergedAsset(:isThemed, :lightPath, :darkPath) = leaf.asset;
      buffer.writeln();
      if (isThemed) {
        buffer.writeln(
          "  final Asset ${leaf.identifier} = ThemedAsset(light: '$lightPath', dark: '$darkPath');",
        );
      } else {
        buffer.writeln(
          "  final Asset ${leaf.identifier} = SimpleAsset('$lightPath');",
        );
      }
    }

    // Subdirectory nodes.
    for (final entry in node.dirs.entries) {
      final childClassName = _className(className, entry.key);
      buffer.writeln();
      buffer.writeln('  final ${entry.value.identifier} = $childClassName();');
    }
  }

  static void _generateNodeClasses(
    StringBuffer buffer,
    _AssetNode node,
    String parentClassName,
  ) {
    for (final entry in node.dirs.entries) {
      final childClassName = _className(parentClassName, entry.key);
      final childNode = entry.value;

      // Recurse first so nested classes are defined before they are referenced.
      _generateNodeClasses(buffer, childNode, childClassName);

      buffer.writeln('class $childClassName {');
      buffer.writeln('  $childClassName();');
      _writeNodeFields(buffer, childNode, childClassName);
      buffer.writeln('}');
      buffer.writeln();
    }
  }

  // ---------------------------------------------------------------------------
  // Naming helpers
  // ---------------------------------------------------------------------------

  /// Build a private class name from a parent class name and a directory name.
  ///
  /// Example: `_className('_ProjectAssets', 'logo')` → `_ProjectAssetsLogo`.
  static String _className(String parent, String dirName) {
    final pascal = _toPascalCase(dirName);
    if (parent == '_ProjectAssets') return '_ProjectAssets$pascal';
    return '$parent$pascal';
  }

  static final _nonAlphanumPattern = RegExp(r'[^a-zA-Z0-9]');
  static final _leadingDigitPattern = RegExp(r'^[0-9]');
  static final _nonIdentCharPattern = RegExp(r'[^a-zA-Z0-9_]');
  static final _multiUnderscorePattern = RegExp(r'_+');
  static final _edgeUnderscorePattern = RegExp(r'^_+|_+$');

  /// Convert a directory name to PascalCase.
  ///
  /// `my-icons` → `MyIcons`, `01-guides` → `\$01Guides`.
  static String _toPascalCase(String name) {
    final parts = name.split(_nonAlphanumPattern).where((s) => s.isNotEmpty);
    final result = parts.map((s) => s[0].toUpperCase() + s.substring(1)).join();
    if (result.isEmpty) return 'Unnamed';
    if (_leadingDigitPattern.hasMatch(result)) return '\$$result';
    return result;
  }

  /// Convert a filename to a valid Dart snake_case identifier.
  ///
  /// `logo.webp` → `logo_webp`, `favicon-32x32.png` → `favicon_32x32_png`,
  /// `1icon.svg` → `\$1icon_svg`.
  static String _toIdentifier(String name) {
    String result = name.replaceAll(_nonIdentCharPattern, '_');
    result = result.replaceAll(_multiUnderscorePattern, '_');
    result = result.replaceAll(_edgeUnderscorePattern, '');
    if (result.isEmpty) return 'unnamed';
    if (_leadingDigitPattern.hasMatch(result)) return '\$$result';
    return result;
  }

  // ---------------------------------------------------------------------------
  // Empty fallback
  // ---------------------------------------------------------------------------

  static String _emptyAssets() {
    return '''
class _ProjectAssets {
  _ProjectAssets();
}
''';
  }
}

// ---------------------------------------------------------------------------
// Internal data structures (not exported)
// ---------------------------------------------------------------------------

/// A merged asset entry — either simple (one path) or themed (light + dark).
class _MergedAsset {
  _MergedAsset.simple(this.lightPath) : darkPath = lightPath, isThemed = false;
  _MergedAsset.themed(this.lightPath, this.darkPath) : isThemed = true;

  final String lightPath;
  final String darkPath;
  final bool isThemed;
}

/// A node in the asset tree (represents a directory).
class _AssetNode {
  _AssetNode({required this.name, required this.identifier});

  final String name;
  final String identifier;
  final Map<String, _AssetNode> dirs = {};
  final Map<String, _AssetLeaf> files = {};
}

/// A leaf in the asset tree (represents a file).
class _AssetLeaf {
  const _AssetLeaf({required this.identifier, required this.asset});

  final String identifier;
  final _MergedAsset asset;
}
