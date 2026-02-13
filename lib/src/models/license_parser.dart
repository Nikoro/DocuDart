import 'license.dart';

/// Parses LICENSE file content to extract license type, year, and holder.
class LicenseParser {
  LicenseParser._();

  /// Parses LICENSE file content into a [License] object.
  ///
  /// Returns `null` if the content is empty or completely unrecognizable.
  static License? parse(String content) {
    if (content.trim().isEmpty) return null;

    final type = _detectType(content);
    final (year, holder) = _extractCopyright(content);

    return License(type: type, year: year, holder: holder);
  }

  /// Detects the license type from known header strings.
  static LicenseType _detectType(String content) {
    final upper = content.toUpperCase();

    // Check specific variants before generic ones.
    if (upper.contains('MIT LICENSE') ||
        upper.contains('PERMISSION IS HEREBY GRANTED, FREE OF CHARGE')) {
      return LicenseType.mit;
    }
    if (upper.contains('APACHE LICENSE, VERSION 2.0') ||
        upper.contains('APACHE LICENSE\n')) {
      return LicenseType.apache2;
    }
    if (upper.contains('BSD 2-CLAUSE') ||
        upper.contains('SIMPLIFIED BSD LICENSE') ||
        upper.contains('FREEBSD LICENSE')) {
      return LicenseType.bsd2;
    }
    if (upper.contains('BSD 3-CLAUSE') ||
        upper.contains('NEW BSD LICENSE') ||
        upper.contains('MODIFIED BSD LICENSE')) {
      return LicenseType.bsd3;
    }
    // Generic BSD fallback (after specific variants).
    if (upper.contains('BSD LICENSE') ||
        (upper.contains('REDISTRIBUTION AND USE IN SOURCE AND BINARY') &&
            !upper.contains('APACHE'))) {
      return LicenseType.bsd3;
    }
    if (upper.contains('ISC LICENSE') ||
        upper.contains('ISC-LICENSE') ||
        (upper.contains('PERMISSION TO USE, COPY, MODIFY') &&
            upper.contains('ISC'))) {
      return LicenseType.isc;
    }
    if (upper.contains('MOZILLA PUBLIC LICENSE VERSION 2.0') ||
        upper.contains('MOZILLA PUBLIC LICENSE, VERSION 2.0')) {
      return LicenseType.mpl2;
    }
    if (upper.contains('GNU AFFERO GENERAL PUBLIC LICENSE')) {
      return LicenseType.agpl;
    }
    if (upper.contains('GNU LESSER GENERAL PUBLIC LICENSE')) {
      return LicenseType.lgpl;
    }
    if (upper.contains('GNU GENERAL PUBLIC LICENSE') &&
        upper.contains('VERSION 3')) {
      return LicenseType.gpl3;
    }
    if (upper.contains('GNU GENERAL PUBLIC LICENSE') &&
        upper.contains('VERSION 2')) {
      return LicenseType.gpl2;
    }
    if (upper.contains('GNU GENERAL PUBLIC LICENSE')) {
      return LicenseType.gpl3;
    }
    if (upper.contains('THE UNLICENSE') || upper.contains('UNLICENSE')) {
      return LicenseType.unlicense;
    }
    if (upper.contains('CC0 1.0 UNIVERSAL') ||
        upper.contains('CREATIVE COMMONS ZERO')) {
      return LicenseType.cc0;
    }
    if (upper.contains('DO WHAT THE FUCK YOU WANT TO') ||
        upper.contains('WTFPL')) {
      return LicenseType.wtfpl;
    }

    return LicenseType.unknown;
  }

  /// Extracts the copyright year and holder from content.
  ///
  /// Returns `(year, holder)` where either may be null.
  static (String?, String?) _extractCopyright(String content) {
    // Matches: Copyright (c) 2026 Holder Name
    //          Copyright © 2020-2026 Holder Name
    //          Copyright (C) 2026, Holder Name
    //          Copyright 2026 Holder Name
    final match = RegExp(
      r'Copyright\s*(?:\(c\)|©|\(C\))?\s*'
      r'(\d{4}(?:\s*[-–,]\s*\d{4})?)'
      r'\s*,?\s*'
      r'(.+)',
      caseSensitive: false,
    ).firstMatch(content);

    if (match == null) return (null, null);

    final year = match.group(1)?.trim();
    final holder = match.group(2)?.trim().replaceAll(RegExp(r'[.\s]+$'), '');

    return (
      year?.isEmpty == true ? null : year,
      holder?.isEmpty == true ? null : holder,
    );
  }
}
