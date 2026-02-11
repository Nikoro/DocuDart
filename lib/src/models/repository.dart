import 'package:docudart/docudart.dart';

/// Represents a source code repository URL with auto-detected provider info.
///
/// Wraps a URL string and provides [label] and [icon] getters that
/// detect the hosting provider (GitHub, GitLab, Bitbucket) from the URL host.
@immutable
class Repository {
  const Repository(this.link);

  /// The repository URL string.
  final String link;

  /// Auto-detected provider label based on URL host.
  String get label => _matchHost(
    github: 'GitHub',
    gitlab: 'GitLab',
    bitbucket: 'Bitbucket',
    orElse: 'Repository',
  );

  /// Auto-detected provider icon based on URL host.
  Component get icon => Icon(
    _matchHost(
      github: FontAwesomeIcons.github_brand,
      gitlab: FontAwesomeIcons.gitlab_brand,
      bitbucket: FontAwesomeIcons.bitbucket_brand,
      orElse: FontAwesomeIcons.link,
    ),
  );

  T _matchHost<T>({
    required T github,
    required T gitlab,
    required T bitbucket,
    required T orElse,
  }) {
    final host = Uri.parse(link).host;
    if (host.contains('github')) return github;
    if (host.contains('gitlab')) return gitlab;
    if (host.contains('bitbucket')) return bitbucket;
    return orElse;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Repository &&
          runtimeType == other.runtimeType &&
          link == other.link;

  @override
  int get hashCode => link.hashCode;

  @override
  String toString() => 'Repository($link)';
}
