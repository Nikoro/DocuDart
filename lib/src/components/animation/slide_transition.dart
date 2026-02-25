import 'package:docudart/docudart.dart';

/// The direction a [SlideTransition] slides FROM when entering.
enum SlideDirection { left, right, top, bottom }

/// A component that slides its [child] in/out using CSS transforms.
///
/// The child starts off-screen in the given [direction] and slides to its
/// natural position when the [trigger] CSS selector matches. A small JS
/// observer watches for class changes on `<body>` and `<html>` to toggle
/// the `data-slide-active` attribute.
///
/// ```dart
/// SlideTransition(
///   direction: SlideDirection.left,
///   trigger: 'body.sidebar-open',
///   child: sidebar,
/// )
/// ```
class SlideTransition extends StatelessComponent {
  const SlideTransition({
    required this.child,
    this.direction = SlideDirection.left,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curve.ease,
    this.offset = 100,
    this.trigger,
    this.classes,
    super.key,
  });

  /// The content to slide in/out.
  final Component child;

  /// Direction the child slides FROM when entering.
  final SlideDirection direction;

  /// Duration of the slide animation.
  final Duration duration;

  /// Timing curve for the CSS transition.
  final Curve curve;

  /// Distance to slide in percent. Defaults to 100%.
  final double offset;

  /// CSS selector that, when matched, activates the slide.
  ///
  /// Example: `'body.sidebar-open'` — the child slides in when `<body>`
  /// has the `sidebar-open` class.
  final String? trigger;

  /// Additional CSS classes.
  final String? classes;

  @override
  Component build(BuildContext context) {
    final offset = switch (direction) {
      SlideDirection.left => Transform.translate(x: (-this.offset).percent),
      SlideDirection.right => Transform.translate(x: this.offset.percent),
      SlideDirection.top => Transform.translate(y: (-this.offset).percent),
      SlideDirection.bottom => Transform.translate(y: this.offset.percent),
    };

    return div(
      classes: 'slide-transition${classes != null ? ' $classes' : ''}',
      styles: Styles(
        transform: offset,
        transition: Transition('transform', duration: duration, curve: curve),
      ),
      attributes: {'data-slide-trigger': ?trigger},
      [child],
    );
  }
}
