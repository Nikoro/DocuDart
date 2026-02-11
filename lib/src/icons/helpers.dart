/// A helper class that stores the data for an SVG icon.
class IconData {
  /// Creates icon data from a list of SVG element maps.
  ///
  /// This can be used to supply an [Icon] component with the data it needs
  /// to draw an SVG icon.
  const IconData(this.content);

  /// A list of XML elements that form an SVG.
  ///
  /// Each element is a map with the following keys:
  /// - `tag`: the name of the SVG element
  /// - `attrs`: a map of attributes specific to the element
  final List<Map<String, dynamic>> content;
}

/// SVG stroke-linejoin options.
enum StrokeLineJoin {
  /// arcs
  arcs('arcs'),

  /// bevel
  bevel('bevel'),

  /// miter
  miter('miter'),

  /// miter-clip
  miterClip('miter-clip'),

  /// round
  round('round');

  const StrokeLineJoin(this.value);

  /// The SVG attribute value.
  final String value;
}

/// SVG stroke-linecap options.
enum StrokeLineCap {
  /// butt
  butt('butt'),

  /// round
  round('round'),

  /// square
  square('square');

  const StrokeLineCap(this.value);

  /// The SVG attribute value.
  final String value;
}
