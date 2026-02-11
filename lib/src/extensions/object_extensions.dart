/// Kotlin-style `.let()` extension on nullable objects.
///
/// Enables null-safe scoping — if the receiver is null, returns null;
/// otherwise applies the [block] function to the non-null value.
///
/// ```dart
/// final name = user?.name.let((n) => 'Hello, $n'); // null if user is null
/// ```
///
/// **Note**: This extension is defined on `T?` (all nullable objects) and is
/// re-exported via `package:docudart/docudart.dart`. If your project defines
/// its own `.let()` extension, you may see a conflict. In that case, use a
/// `hide` clause: `import 'package:docudart/docudart.dart' hide OptionalAnyObjectExtensions;`
extension OptionalAnyObjectExtensions<T extends Object> on T? {
  /// Applies [block] to `this` if non-null; returns null otherwise.
  R? let<R>(R? Function(T it) block) => this == null ? null : block(this!);
}
