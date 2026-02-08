import 'package:meta/meta.dart';

import 'docudart_config.dart';
import 'project.dart';

/// Stored setup callback. Set by [setup], consumed by [resolveConfig].
Config Function(Project)? _setupCallback;

/// Registers the site configuration callback.
///
/// Call this at the top level of your `config.dart` as a variable
/// initializer so it runs when the file is first imported:
/// ```dart
/// final init = setup((project) => Config(
///   title: project.pubspec.name,
///   description: project.pubspec.description,
///   // ...
/// ));
/// ```
///
/// Returns `null` — the return value exists only to enable the
/// `final init = setup(...)` top-level initializer pattern.
/// The variable **must** be public (not `_`) so generated code can
/// reference it and force Dart's lazy top-level initializer to run.
Null setup(Config Function(Project project) callback) {
  _setupCallback = callback;
  return null;
}

/// Resolves the current config by invoking the stored setup callback.
///
/// Called by the generated layout and app code. Throws if [setup]
/// has not been called.
Config resolveConfig(Project project) {
  final callback = _setupCallback;
  if (callback == null) {
    throw StateError(
      'setup() has not been called. '
      'Your config.dart must call setup() at the top level.',
    );
  }
  return callback(project);
}

/// Resets the setup callback. For testing only.
@visibleForTesting
void resetSetup() {
  _setupCallback = null;
}
