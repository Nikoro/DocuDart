import 'package:test/test.dart';

import 'package:docudart/src/cli/errors.dart';
import 'package:docudart/src/config/docudart_config.dart';
import 'package:docudart/src/models/doc_content.dart';
import 'package:docudart/src/models/versioning_config.dart';
import 'package:docudart/src/processing/version_manager.dart';

VersionManager _manager({
  bool enabled = true,
  List<String> versions = const ['v1', 'v2'],
  String defaultVersion = '',
}) => VersionManager(
  Config(
    versioning: VersioningConfig(
      enabled: enabled,
      versions: versions,
      defaultVersion: defaultVersion,
    ),
  ),
);

void main() {
  group('isEnabled', () {
    test('returns true when enabled with versions', () {
      expect(_manager().isEnabled, isTrue);
    });

    test('returns false when disabled', () {
      expect(_manager(enabled: false).isEnabled, isFalse);
    });

    test('returns false when enabled but no versions', () {
      expect(_manager(versions: []).isEnabled, isFalse);
    });
  });

  group('defaultVersion', () {
    test('returns configured default', () {
      expect(_manager(defaultVersion: 'v1').defaultVersion, equals('v1'));
    });

    test('falls back to last version when no default set', () {
      expect(_manager().defaultVersion, equals('v2'));
    });

    test('falls back to "latest" when no versions', () {
      final m = VersionManager(Config());
      expect(m.defaultVersion, equals('latest'));
    });
  });

  group('latestVersion', () {
    test('returns last version in list', () {
      expect(_manager().latestVersion, equals('v2'));
    });

    test('returns "latest" when no versions', () {
      final m = VersionManager(Config());
      expect(m.latestVersion, equals('latest'));
    });
  });

  group('extractVersionFromPath', () {
    test('matches versioned path', () {
      final m = _manager();
      expect(m.extractVersionFromPath('/v1/docs/intro'), equals('v1'));
      expect(m.extractVersionFromPath('/v2/docs/intro'), equals('v2'));
    });

    test('returns null for unversioned path', () {
      expect(_manager().extractVersionFromPath('/docs/intro'), isNull);
    });

    test('returns null for unknown version', () {
      expect(_manager().extractVersionFromPath('/v3/docs/intro'), isNull);
    });

    test('requires trailing slash after version', () {
      expect(_manager().extractVersionFromPath('/v1'), isNull);
    });
  });

  group('VersionedDocs.urlPrefix', () {
    test('returns version-prefixed docs path', () {
      final docs = VersionedDocs(
        version: 'v1',
        isDefault: false,
        isLatest: false,
        pages: const [],
        rootFolder: const DocFolder(
          relativePath: '',
          name: 'root',
          order: 0,
          pages: [],
          folders: [],
        ),
      );
      expect(docs.urlPrefix, equals('/v1/docs'));
    });
  });

  group('version validation', () {
    test('accepts valid version identifiers', () {
      expect(
        () => _manager(versions: ['v1.0', '2.0-beta', 'rc_1']),
        returnsNormally,
      );
    });

    test('rejects version with path traversal', () {
      expect(
        () => _manager(versions: ['../../etc']),
        throwsA(isA<DocuDartException>()),
      );
    });

    test('rejects version with spaces', () {
      expect(
        () => _manager(versions: ['v 1']),
        throwsA(isA<DocuDartException>()),
      );
    });

    test('rejects version with slashes', () {
      expect(
        () => _manager(versions: ['v1/v2']),
        throwsA(isA<DocuDartException>()),
      );
    });

    test('validates defaultVersion too', () {
      expect(
        () => _manager(defaultVersion: '../bad'),
        throwsA(isA<DocuDartException>()),
      );
    });
  });
}
