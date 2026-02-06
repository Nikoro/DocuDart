import 'dart:io';

import 'package:path/path.dart' as p;

/// Resolves the website directory for DocuDart commands.
class WorkspaceResolver {
  WorkspaceResolver._();

  /// Resolves the website directory from the given working directory.
  ///
  /// Search strategy:
  /// 1. If cwd IS the website dir (has config.dart + pubspec.yaml), use cwd
  /// 2. If cwd has a website/ subdirectory with config.dart, use that
  /// 3. Legacy: if cwd has config.dart directly (old-style project), use cwd
  ///
  /// Returns the absolute path to the website directory, or null if not found.
  static String? resolve([String? workingDirectory]) {
    final cwd = workingDirectory ?? Directory.current.path;

    // Check if we ARE in the website directory
    if (_isWebsiteDir(cwd)) {
      return p.normalize(p.absolute(cwd));
    }

    // Check for website/ subdirectory
    final websiteDir = p.join(cwd, 'website');
    if (_isWebsiteDir(websiteDir)) {
      return p.normalize(p.absolute(websiteDir));
    }

    // Legacy: config.dart directly in cwd (old-style project)
    if (File(p.join(cwd, 'config.dart')).existsSync()) {
      return p.normalize(p.absolute(cwd));
    }

    return null;
  }

  static bool _isWebsiteDir(String dir) {
    return File(p.join(dir, 'config.dart')).existsSync() &&
        File(p.join(dir, 'pubspec.yaml')).existsSync();
  }
}
