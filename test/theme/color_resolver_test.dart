import 'package:jaspr/dom.dart' show Color;
import 'package:test/test.dart';

import 'package:docudart/src/theme/color_resolver.dart';
import 'package:docudart/src/theme/color_utils.dart';

void main() {
  group('resolveColor', () {
    test('parses 6-digit hex', () {
      expect(resolveColor(const Color('#FF6347')), equals(0xFFFF6347));
    });

    test('parses 3-digit hex', () {
      // #F00 -> #FF0000
      expect(resolveColor(const Color('#F00')), equals(0xFFFF0000));
    });

    test('parses rgb()', () {
      expect(resolveColor(const Color.rgb(255, 99, 71)), equals(0xFFFF6347));
    });

    test('parses rgba() — discards alpha', () {
      final result = resolveColor(const Color.rgba(255, 99, 71, 0.5));
      expect(result, equals(0xFFFF6347));
    });

    test('parses hsl()', () {
      // hsl(0, 100%, 50%) = pure red
      final result = resolveColor(const Color.hsl(0, 100, 50));
      expect(result, equals(0xFFFF0000));
    });

    test('resolves CSS named color', () {
      expect(resolveColor(const Color('tomato')), equals(0xFFFF6347));
    });

    test('throws on CSS variable', () {
      expect(
        () => resolveColor(const Color.variable('--my-color')),
        throwsArgumentError,
      );
    });

    test('throws on unsupported format', () {
      expect(() => resolveColor(const Color('inherit')), throwsArgumentError);
    });
  });

  group('HSL', () {
    test('fromInt and toInt roundtrip for pure red', () {
      const red = 0xFFFF0000;
      final hsl = HSL.fromInt(red);
      expect(hsl.hue, closeTo(0, 0.1));
      expect(hsl.saturation, closeTo(1.0, 0.01));
      expect(hsl.lightness, closeTo(0.5, 0.01));
      expect(hsl.toInt(), equals(red));
    });

    test('fromInt and toInt roundtrip for pure green', () {
      const green = 0xFF00FF00;
      final hsl = HSL.fromInt(green);
      expect(hsl.hue, closeTo(120, 0.1));
      expect(hsl.toInt(), equals(green));
    });

    test('fromInt and toInt roundtrip for pure blue', () {
      const blue = 0xFF0000FF;
      final hsl = HSL.fromInt(blue);
      expect(hsl.hue, closeTo(240, 0.1));
      expect(hsl.toInt(), equals(blue));
    });

    test('handles achromatic (gray)', () {
      const gray = 0xFF808080;
      final hsl = HSL.fromInt(gray);
      expect(hsl.hue, equals(0));
      expect(hsl.saturation, equals(0));
      expect(hsl.lightness, closeTo(0.502, 0.01));
      expect(hsl.toInt(), equals(gray));
    });

    test('handles black', () {
      const black = 0xFF000000;
      final hsl = HSL.fromInt(black);
      expect(hsl.lightness, equals(0));
      expect(hsl.toInt(), equals(black));
    });

    test('handles white', () {
      const white = 0xFFFFFFFF;
      final hsl = HSL.fromInt(white);
      expect(hsl.lightness, equals(1.0));
      expect(hsl.toInt(), equals(white));
    });

    test('withHue creates new HSL with different hue', () {
      final hsl = const HSL(120, 0.5, 0.5).withHue(240);
      expect(hsl.hue, equals(240));
      expect(hsl.saturation, equals(0.5));
    });

    test('withSaturation creates new HSL', () {
      final hsl = const HSL(120, 0.5, 0.5).withSaturation(0.8);
      expect(hsl.saturation, equals(0.8));
    });

    test('withLightness creates new HSL', () {
      final hsl = const HSL(120, 0.5, 0.5).withLightness(0.9);
      expect(hsl.lightness, equals(0.9));
    });

    test('rotateHue wraps around 360', () {
      final hsl = const HSL(350, 0.5, 0.5).rotateHue(30);
      expect(hsl.hue, closeTo(20, 0.01));
    });

    test('toInt clamps saturation and lightness', () {
      expect(() => const HSL(0, 1.5, -0.1).toInt(), returnsNormally);
    });
  });
}
