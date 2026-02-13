import 'package:meta/meta.dart';

/// Known open-source license types.
enum LicenseType {
  mit,
  bsd2,
  bsd3,
  apache2,
  isc,
  mpl2,
  gpl2,
  gpl3,
  lgpl,
  agpl,
  unlicense,
  cc0,
  wtfpl,
  unknown,
}

/// Parsed license information from a project's LICENSE file.
@immutable
class License {
  const License({required this.type, this.year, this.holder});

  /// The detected license type.
  final LicenseType type;

  /// The copyright year or year range (e.g. '2026' or '2020-2026').
  final String? year;

  /// The copyright holder name (e.g. 'Dominik Krajcer').
  final String? holder;
}
