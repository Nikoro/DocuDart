import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

/// Adds an `.apply()` method to [Component] for merging element properties.
///
/// Wraps the component's root element with the given [id], [classes], [styles],
/// [attributes], and [events] — without adding an extra wrapper div.
///
/// ```dart
/// Column(children: [...]).apply(classes: 'landing-page')
/// myComponent.apply(styles: Styles(maxWidth: 800.px))
/// ```
extension ComponentApplyExtension on Component {
  Component apply({
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
  }) {
    return .wrapElement(
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      child: this,
    );
  }
}
