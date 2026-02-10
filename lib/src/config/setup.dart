import 'package:jaspr/jaspr.dart';

import 'docudart_config.dart';

/// Type alias for the configuration function that users define in config.dart.
///
/// Users export a top-level function named `configure` from their `config.dart`:
/// ```dart
/// Config configure(BuildContext context) => Config(
///   title: context.project.pubspec.name,
///   description: context.project.pubspec.description,
///   // ...
/// );
/// ```
///
/// The generated code imports `config.dart` and calls `configure(context)` directly.
typedef ConfigureFunction = Config Function(BuildContext context);
