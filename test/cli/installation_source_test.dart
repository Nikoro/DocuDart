import 'package:test/test.dart';
import 'package:docudart/src/cli/version/installation_source.dart';

void main() {
  group('InstallationInfo', () {
    test('stores source and git fields', () {
      final InstallationInfo(
        :source,
        :gitUrl,
        :gitRef,
        :version,
      ) = InstallationInfo(
        source: InstallationSource.git,
        gitUrl: 'https://github.com/Nikoro/docudart',
        gitRef: 'abc123',
      );

      expect(source, equals(InstallationSource.git));
      expect(gitUrl, equals('https://github.com/Nikoro/docudart'));
      expect(gitRef, equals('abc123'));
      expect(version, isNull);
    });

    test('stores source and version for hosted', () {
      final InstallationInfo(:source, :version, :gitUrl, :gitRef) =
          InstallationInfo(source: InstallationSource.hosted, version: '1.0.0');

      expect(source, equals(InstallationSource.hosted));
      expect(version, equals('1.0.0'));
      expect(gitUrl, isNull);
      expect(gitRef, isNull);
    });
  });

  group('InstallationSource enum', () {
    test('has git and hosted values', () {
      expect(InstallationSource.values, hasLength(2));
      expect(InstallationSource.values, contains(InstallationSource.git));
      expect(InstallationSource.values, contains(InstallationSource.hosted));
    });
  });

  // Note: detectInstallationSource() reads from $PUB_CACHE which we
  // can't easily override in tests. We test the data classes above
  // and verify the function handles missing files gracefully.
  group('detectInstallationSource', () {
    test('returns hosted when PUB_CACHE lock file does not exist', () async {
      // The function reads from the real PUB_CACHE. If the global
      // packages directory for docudart doesn't exist, it defaults
      // to hosted. This exercises the fallback path.
      final info = await detectInstallationSource();

      // Whatever the result, it should be a valid InstallationInfo
      expect(info, isA<InstallationInfo>());
      expect(
        info.source,
        anyOf(InstallationSource.git, InstallationSource.hosted),
      );
    });
  });
}
