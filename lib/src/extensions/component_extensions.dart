import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

extension ComponentApplyExtension on Component {
  Component apply({String? classes, Styles? styles}) {
    return Component.wrapElement(classes: classes, styles: styles, child: this);
  }
}
