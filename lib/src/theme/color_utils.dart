import 'dart:math' as math;

/// HSL (Hue, Saturation, Lightness) color representation.
///
/// Used internally for seed-based palette generation.
/// - [hue]: 0–360 degrees on the color wheel
/// - [saturation]: 0.0–1.0 (gray to fully saturated)
/// - [lightness]: 0.0–1.0 (black to white)
class HSL {
  const HSL(this.hue, this.saturation, this.lightness);

  /// Create HSL from an ARGB int color (0xAARRGGBB).
  factory HSL.fromInt(int color) {
    final r = ((color >> 16) & 0xFF) / 255.0;
    final g = ((color >> 8) & 0xFF) / 255.0;
    final b = (color & 0xFF) / 255.0;

    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final delta = max - min;

    // Lightness
    final l = (max + min) / 2.0;

    // Achromatic
    if (delta == 0) return HSL(0, 0, l);

    // Saturation
    final s = l > 0.5 ? delta / (2.0 - max - min) : delta / (max + min);

    // Hue
    double h;
    if (max == r) {
      h = ((g - b) / delta) + (g < b ? 6.0 : 0.0);
    } else if (max == g) {
      h = ((b - r) / delta) + 2.0;
    } else {
      h = ((r - g) / delta) + 4.0;
    }
    h *= 60.0;

    return HSL(h, s, l);
  }

  final double hue;
  final double saturation;
  final double lightness;

  /// Convert back to ARGB int (0xFFRRGGBB).
  int toInt() {
    final h = hue % 360;
    final s = saturation.clamp(0.0, 1.0);
    final l = lightness.clamp(0.0, 1.0);

    if (s == 0) {
      final v = (l * 255).round();
      return 0xFF000000 | (v << 16) | (v << 8) | v;
    }

    final c = (1.0 - (2.0 * l - 1.0).abs()) * s;
    final x = c * (1.0 - ((h / 60.0) % 2.0 - 1.0).abs());
    final m = l - c / 2.0;

    double r, g, b;
    if (h < 60) {
      (r, g, b) = (c, x, 0.0);
    } else if (h < 120) {
      (r, g, b) = (x, c, 0.0);
    } else if (h < 180) {
      (r, g, b) = (0.0, c, x);
    } else if (h < 240) {
      (r, g, b) = (0.0, x, c);
    } else if (h < 300) {
      (r, g, b) = (x, 0.0, c);
    } else {
      (r, g, b) = (c, 0.0, x);
    }

    return 0xFF000000 |
        (((r + m) * 255).round().clamp(0, 255) << 16) |
        (((g + m) * 255).round().clamp(0, 255) << 8) |
        ((b + m) * 255).round().clamp(0, 255);
  }

  /// Return a new HSL with a different [hue].
  HSL withHue(double hue) => .new(hue % 360, saturation, lightness);

  /// Return a new HSL with a different [saturation] (0.0–1.0).
  HSL withSaturation(double saturation) => .new(hue, saturation, lightness);

  /// Return a new HSL with a different [lightness] (0.0–1.0).
  HSL withLightness(double lightness) => .new(hue, saturation, lightness);

  /// Rotate hue by [degrees] (positive = clockwise).
  HSL rotateHue(double degrees) =>
      .new((hue + degrees) % 360, saturation, lightness);
}
