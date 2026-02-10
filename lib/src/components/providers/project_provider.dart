import 'package:jaspr/jaspr.dart';

import '../../models/project.dart';

/// Provides [Project] data to descendant components via the component tree.
///
/// Wrap your app (or any subtree) with [ProjectProvider] to make [Project]
/// accessible through [BuildContext]:
///
/// ```dart
/// ProjectProvider(
///   project: myProject,
///   child: MyApp(),
/// )
/// ```
///
/// Then access it from any descendant component:
///
/// ```dart
/// @override
/// Component build(BuildContext context) {
///   final project = context.project;
///   return .text(project.pubspec.name);
/// }
/// ```
class ProjectProvider extends InheritedComponent {
  const ProjectProvider({
    required this.project,
    required super.child,
    super.key,
  });

  final Project project;

  @override
  bool updateShouldNotify(covariant ProjectProvider oldComponent) {
    return project != oldComponent.project;
  }
}

/// Extension on [BuildContext] to conveniently access [Project] data
/// provided by an ancestor [ProjectProvider].
extension ProjectContext on BuildContext {
  /// Returns the [Project] from the nearest ancestor [ProjectProvider].
  ///
  /// Throws an assertion error in debug mode if no [ProjectProvider]
  /// is found in the ancestor tree.
  Project get project {
    final provider = dependOnInheritedComponentOfExactType<ProjectProvider>();
    assert(provider != null, 'No ProjectProvider found in ancestor tree');
    return provider!.project;
  }
}
