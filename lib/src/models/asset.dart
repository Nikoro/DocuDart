import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart' as dom;

/// A single asset variant (light or dark) with a web path.
///
/// Callable — returns an `<img>` [Component] for this variant:
///
/// ```dart
/// // As a Component:
/// context.project.assets.logo.logo_webp.light(alt: 'Logo')
///
/// // Raw path string:
/// context.project.assets.logo.logo_webp.light.path
/// ```
@immutable
class AssetVariant {
  const AssetVariant(this.path);

  /// The web path to this asset variant (e.g. `/assets/logo/logo.webp`).
  final String path;

  /// Returns an `<img>` [Component] for this asset variant.
  Component call({String alt = '', String? classes}) =>
      dom.img(src: path, alt: alt, classes: classes ?? '');
}

/// A reference to a static asset, potentially with theme variants.
///
/// Callable — returns a [Component] that automatically renders the correct
/// variant based on the active theme mode (via CSS visibility switching):
///
/// ```dart
/// // Auto-switching Component:
/// context.project.assets.logo.logo_webp(alt: 'Logo')
///
/// // Default path (light-mode or single):
/// context.project.assets.logo.logo_webp.path
///
/// // Explicit variant access:
/// context.project.assets.logo.logo_webp.light.path
/// context.project.assets.logo.logo_webp.dark.path
/// ```
@immutable
sealed class Asset {
  const Asset();

  /// The default asset path (light-mode path, or the single path).
  String get path;

  /// The light-mode variant.
  AssetVariant get light;

  /// The dark-mode variant.
  AssetVariant get dark;

  /// Returns a [Component] for this asset.
  ///
  /// For [SimpleAsset], returns a single `<img>`.
  /// For [ThemedAsset], returns both light and dark `<img>` elements
  /// wrapped in a `<span>` with CSS visibility switching.
  Component call({String alt = '', String? classes});
}

/// An asset with a single path, used for both light and dark modes.
@immutable
class SimpleAsset extends Asset {
  const SimpleAsset(this._path);

  final String _path;

  @override
  String get path => _path;

  @override
  AssetVariant get light => AssetVariant(_path);

  @override
  AssetVariant get dark => AssetVariant(_path);

  @override
  Component call({String alt = '', String? classes}) =>
      dom.img(src: _path, alt: alt, classes: classes ?? '');
}

/// An asset with separate light and dark mode paths.
///
/// When called as a [Component], renders both variants with CSS-based
/// visibility switching (same pattern as [ThemeToggle]).
@immutable
class ThemedAsset extends Asset {
  ThemedAsset({required String light, required String dark})
    : light = AssetVariant(light),
      dark = AssetVariant(dark);

  @override
  final AssetVariant light;

  @override
  final AssetVariant dark;

  @override
  String get path => light.path;

  @override
  Component call({String alt = '', String? classes}) {
    final cls = classes;
    return dom.span(classes: cls != null ? 'theme-asset $cls' : 'theme-asset', [
      dom.img(src: light.path, alt: alt, classes: 'theme-asset-light'),
      dom.img(src: dark.path, alt: alt, classes: 'theme-asset-dark'),
    ]);
  }
}
