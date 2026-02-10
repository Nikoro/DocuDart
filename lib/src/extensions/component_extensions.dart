import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

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
