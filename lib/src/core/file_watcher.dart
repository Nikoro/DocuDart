import 'dart:async';
import 'dart:io';

import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as p;

import '../config/docudart_config.dart';
import '../cli/errors.dart';

/// Watches documentation files for changes and triggers regeneration.
class DocuDartFileWatcher {
  final DocuDartConfig config;
  final Future<void> Function() onRegenerate;

  final List<StreamSubscription<WatchEvent>> _subscriptions = [];
  Timer? _debounceTimer;
  bool _isRegenerating = false;

  DocuDartFileWatcher({required this.config, required this.onRegenerate});

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

  void _handleEvent(WatchEvent event) {
    // Only watch relevant files
    if (!_isWatchedFile(event.path)) {
      return;
    }

    // Debounce rapid changes
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_isRegenerating) return;

      _isRegenerating = true;
      try {
        final relativePath = p.relative(event.path);
        CliPrinter.blank();
        CliPrinter.info('File changed: $relativePath');
        CliPrinter.step('Regenerating site...');
        await onRegenerate();
        CliPrinter.success('Site regenerated');
      } catch (e) {
        CliPrinter.error('Regeneration failed: $e');
      } finally {
        _isRegenerating = false;
      }
    });
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

    // Config file
    if (path.endsWith('config.dart')) {
      return true;
    }

    return false;
  }
}
