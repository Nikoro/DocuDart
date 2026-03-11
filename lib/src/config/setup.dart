import 'package:jaspr/jaspr.dart';

import 'package:docudart/src/models/doc_page_info.dart';
import 'package:docudart/src/config/docudart_config.dart';

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

/// Type alias for a custom layout builder function.
///
/// Receives the four resolved layout components (any may be null) and
/// returns a single [Component] that arranges them. Used by
/// [Config.layoutBuilder] to override the default [Layout] component.
typedef LayoutBuilder =
    Component Function({
      Component? header,
      Component? footer,
      Component? sidebar,
      Component? body,
    });

/// Type alias for a custom docs page builder function.
///
/// Receives a [DocPageInfo] containing the rendered content, table of
/// contents entries, and page metadata. Returns a [Component] that
/// arranges the doc page body.
///
/// When [Config.docsBuilder] is null, a built-in default layout with
/// [TableOfContents] and [TocScrollSpy] is used. Set this to fully
/// replace the default doc page body layout.
typedef DocsBuilder = Component Function(DocPageInfo page);
