import 'dart:isolate';

import 'package:path/path.dart' as p;

/// Resolves the path to the docudart package installation.
class PackageResolver {
  PackageResolver._();

  /// Resolves the absolute path to the docudart package root directory.
  static Future<String> resolveDocudartPath() async {
    final uri = await Isolate.resolvePackageUri(
      Uri.parse('package:docudart/docudart.dart'),
    );
    if (uri == null) {
      throw StateError('Could not resolve docudart package path');
    }
    // uri points to lib/docudart.dart, go up two levels to package root
    final libDir = p.dirname(uri.toFilePath()); // .../lib
    final packageRoot = p.dirname(libDir); // .../docudart
    return packageRoot;
  }

  /// Computes a relative path from [fromDir] to the docudart package root.
  static Future<String> relativePathTo(String fromDir) async {
    final docudartRoot = await resolveDocudartPath();
    return p.relative(docudartRoot, from: fromDir);
  }
}
