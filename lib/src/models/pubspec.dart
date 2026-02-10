import 'package:meta/meta.dart';

import 'repository.dart';

/// SDK environment constraints from pubspec.yaml.
///
/// Provides typed access to Dart SDK and Flutter SDK version constraints.
@immutable
class Environment {
  const Environment({required this.sdk, this.flutter});

  /// Dart SDK version constraint (e.g. '^3.10.0').
  final String sdk;

  /// Flutter SDK version constraint (e.g. '>=3.22.0').
  final String? flutter;
}

/// Represents the user's project pubspec.yaml fields.
///
/// Provides access to metadata like package name, version, description,
/// and URLs that can be used in the site configuration.
@immutable
class Pubspec {
  const Pubspec({
    required this.name,
    this.version,
    this.description,
    this.homepage,
    this.repository,
    this.issueTracker,
    this.documentation,
    this.publishTo,
    this.funding,
    this.topics,
    required this.environment,
  });

  /// Package name (required in pubspec.yaml).
  final String name;

  /// Package version (e.g. '1.0.0').
  final String? version;

  /// Package description.
  final String? description;

  /// Homepage URL.
  final String? homepage;

  /// Source code repository with auto-detected provider info.
  final Repository? repository;

  /// Issue tracker URL.
  final String? issueTracker;

  /// Documentation URL.
  final String? documentation;

  /// Publish target (or 'none' to prevent publishing).
  final String? publishTo;

  /// Funding URLs where users can sponsor development.
  final List<String>? funding;

  /// Topic tags for package categorization.
  final List<String>? topics;

  /// SDK environment constraints.
  final Environment environment;
}
