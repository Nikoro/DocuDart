import 'docudart_config.dart';
import '../models/project.dart';

/// Type alias for the configuration function that users define in config.dart.
///
/// Users export a top-level function named `configure` from their `config.dart`:
/// ```dart
/// Config configure(Project project) => Config(
///   title: project.pubspec.name,
///   description: project.pubspec.description,
///   // ...
/// );
/// ```
///
/// The generated code imports `config.dart` and calls `configure(project)` directly.
typedef ConfigureFunction = Config Function(Project project);
