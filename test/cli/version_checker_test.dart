import 'package:test/test.dart';
import 'package:docudart/src/cli/version/version_checker.dart';

void main() {
  group('VersionCheckResult', () {
    test('hasNewerVersion returns false when latestVersion is null', () {
      final result = VersionCheckResult(currentVersion: '1.0.0');

      expect(result.hasNewerVersion, isFalse);
    });

    test('hasNewerVersion returns true when latest is newer (patch)', () {
      final result = VersionCheckResult(
        currentVersion: '1.0.0',
        latestVersion: '1.0.1',
      );

      expect(result.hasNewerVersion, isTrue);
    });

    test('hasNewerVersion returns true when latest is newer (minor)', () {
      final result = VersionCheckResult(
        currentVersion: '1.0.0',
        latestVersion: '1.1.0',
      );

      expect(result.hasNewerVersion, isTrue);
    });

    test('hasNewerVersion returns true when latest is newer (major)', () {
      final result = VersionCheckResult(
        currentVersion: '1.0.0',
        latestVersion: '2.0.0',
      );

      expect(result.hasNewerVersion, isTrue);
    });

    test('hasNewerVersion returns false when versions are equal', () {
      final result = VersionCheckResult(
        currentVersion: '1.0.0',
        latestVersion: '1.0.0',
      );

      expect(result.hasNewerVersion, isFalse);
    });

    test('hasNewerVersion returns false when current is newer', () {
      final result = VersionCheckResult(
        currentVersion: '2.0.0',
        latestVersion: '1.0.0',
      );

      expect(result.hasNewerVersion, isFalse);
    });

    test('hasNewerVersion handles different length version parts', () {
      final result = VersionCheckResult(
        currentVersion: '1.0',
        latestVersion: '1.0.1',
      );

      // 1.0 has fewer parts than 1.0.1, so compareTo returns -1 (newer exists)
      expect(result.hasNewerVersion, isTrue);
    });

    test('hasNewerVersion handles multi-digit version numbers', () {
      final result = VersionCheckResult(
        currentVersion: '1.9.0',
        latestVersion: '1.10.0',
      );

      expect(result.hasNewerVersion, isTrue);
    });

    test('changelogUrl is stored correctly', () {
      final result = VersionCheckResult(
        currentVersion: '1.0.0',
        latestVersion: '2.0.0',
        changelogUrl: 'https://example.com/changelog',
      );

      expect(result.changelogUrl, equals('https://example.com/changelog'));
    });
  });
}
