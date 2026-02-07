import 'dart:async';
import 'dart:io';

import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as p;

import '../config/docudart_config.dart';
import '../cli/errors.dart';

/// Watches documentation files for changes and triggers regeneration.
class DocuDartFileWatcher {
  final Config config;
  final String websiteDir;
  final Future<void> Function() onRegenerate;

  final List<StreamSubscription<WatchEvent>> _subscriptions = [];
  Timer? _debounceTimer;
  bool _isRegenerating = false;
  bool _pendingRegeneration = false;

  DocuDartFileWatcher({
    required this.config,
    required this.websiteDir,
    required this.onRegenerate,
  });

  /// Start watching for file changes.
  Future<void> start() async {
    CliPrinter.info('Watching for file changes...');

    // Watch docs directory
    await _watchDirectory(config.docsDir);

    // Watch assets directory if it exists
    final assetsDir = Directory(config.assetsDir);
    if (assetsDir.existsSync()) {
      await _watchDirectory(config.assetsDir);
    }

    // Watch versions directory if versioning is enabled
    if (config.versioning?.enabled == true) {
      final versionDir = config.versioning!.versionDir;
      if (Directory(versionDir).existsSync()) {
        await _watchDirectory(versionDir);
      }
    }

    // Watch config.dart file
    final configFile = File(p.join(websiteDir, 'config.dart'));
    if (configFile.existsSync()) {
      await _watchFile(configFile.path);
    }

    // Watch components directory
    final componentsDir = Directory(p.join(websiteDir, 'components'));
    if (componentsDir.existsSync()) {
      await _watchDirectory(componentsDir.path);
    }

    // Watch pages directory
    final pagesDir = Directory(p.join(websiteDir, 'pages'));
    if (pagesDir.existsSync()) {
      await _watchDirectory(pagesDir.path);
    }
  }

  /// Stop watching for file changes.
  Future<void> stop() async {
    _debounceTimer?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> _watchDirectory(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return;
    }

    final watcher = DirectoryWatcher(path);
    final subscription = watcher.events.listen(_handleEvent);
    _subscriptions.add(subscription);
  }

  Future<void> _watchFile(String path) async {
    final watcher = FileWatcher(path);
    final subscription = watcher.events.listen(_handleEvent);
    _subscriptions.add(subscription);
  }

  void _handleEvent(WatchEvent event) {
    // Only watch relevant files
    if (!_isWatchedFile(event.path)) {
      return;
    }

    // Debounce rapid changes
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // If already regenerating, mark as pending so we re-run after it finishes
      if (_isRegenerating) {
        _pendingRegeneration = true;
        return;
      }

      await _runRegeneration(event.path);
    });
  }

  Future<void> _runRegeneration(String changedPath) async {
    _isRegenerating = true;
    _pendingRegeneration = false;
    try {
      final relativePath = p.relative(changedPath);
      CliPrinter.blank();
      CliPrinter.info('File changed: $relativePath');
      CliPrinter.step('Regenerating site...');
      await onRegenerate();
      CliPrinter.success('Site regenerated');
    } catch (e) {
      CliPrinter.error('Regeneration failed: $e');
    } finally {
      _isRegenerating = false;

      // If another change came in while we were regenerating, run again
      if (_pendingRegeneration) {
        _pendingRegeneration = false;
        await _runRegeneration(changedPath);
      }
    }
  }

  bool _isWatchedFile(String path) {
    final ext = p.extension(path).toLowerCase();

    // Markdown files
    if (ext == '.md' || ext == '.markdown') {
      return true;
    }

    // Asset files
    if ([
      '.png',
      '.jpg',
      '.jpeg',
      '.gif',
      '.svg',
      '.webp',
      '.ico',
    ].contains(ext)) {
      return true;
    }

    // Dart files (config.dart, components/*.dart, pages/*.dart)
    if (ext == '.dart') {
      return true;
    }

    return false;
  }
}
