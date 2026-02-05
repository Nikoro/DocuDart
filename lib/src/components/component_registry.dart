import '../markdown/component_parser.dart';

/// Factory function for creating component HTML from props and children.
typedef ComponentFactory = String Function(
  Map<String, dynamic> props,
  String? children,
);

/// Registry for custom components that can be embedded in markdown.
class ComponentRegistry {
  final Map<String, ComponentFactory> _components = {};

  /// Register a component with its factory function.
  void register(String name, ComponentFactory factory) {
    _components[name] = factory;
  }

  /// Check if a component is registered.
  bool hasComponent(String name) => _components.containsKey(name);

  /// Build HTML for a component.
  String? buildComponent(EmbeddedComponent component) {
    final factory = _components[component.name];
    if (factory == null) return null;

    return factory(component.props, component.children);
  }

  /// Get all registered component names.
  Set<String> get registeredNames => _components.keys.toSet();

  /// Create a registry with all built-in components.
  static ComponentRegistry withBuiltIns() {
    final registry = ComponentRegistry();

    // Register built-in components
    registry.register('Callout', _buildCallout);
    registry.register('Tabs', _buildTabs);
    registry.register('Tab', _buildTab);
    registry.register('CodeBlock', _buildCodeBlock);
    registry.register('Card', _buildCard);
    registry.register('CardGrid', _buildCardGrid);

    return registry;
  }

  // Built-in component factories

  static String _buildCallout(Map<String, dynamic> props, String? children) {
    final type = props['type'] as String? ?? 'info';
    final title = props['title'] as String?;

    final iconMap = {
      'info': 'ℹ️',
      'tip': '💡',
      'warning': '⚠️',
      'danger': '🚨',
      'note': '📝',
    };

    final icon = iconMap[type] ?? iconMap['info']!;
    final titleHtml = title != null
        ? '<div class="callout-title">$icon $title</div>'
        : '<div class="callout-icon">$icon</div>';

    return '''
<div class="callout callout-$type">
  $titleHtml
  <div class="callout-content">
    ${children ?? ''}
  </div>
</div>
''';
  }

  static String _buildTabs(Map<String, dynamic> props, String? children) {
    // Tabs component wraps Tab children
    // The actual tab switching is handled by CSS/JS
    final tabId = 'tabs-${DateTime.now().millisecondsSinceEpoch}';

    return '''
<div class="tabs-container" data-tabs-id="$tabId">
  <div class="tabs-list" role="tablist">
    <!-- Tab buttons will be generated from Tab children -->
  </div>
  <div class="tabs-content">
    ${children ?? ''}
  </div>
</div>
''';
  }

  static String _buildTab(Map<String, dynamic> props, String? children) {
    final label = props['label'] as String? ?? 'Tab';
    final tabId = label.toLowerCase().replaceAll(RegExp(r'\s+'), '-');

    return '''
<div class="tab-panel" data-tab-id="$tabId" data-tab-label="$label">
  ${children ?? ''}
</div>
''';
  }

  static String _buildCodeBlock(Map<String, dynamic> props, String? children) {
    final language = props['language'] as String? ?? '';
    final title = props['title'] as String?;
    final showLineNumbers = props['lineNumbers'] as bool? ?? false;
    final code = props['code'] as String? ?? children ?? '';

    final lineNumbersClass = showLineNumbers ? ' line-numbers' : '';
    final titleHtml = title != null
        ? '<div class="code-block-title">$title</div>'
        : '';

    return '''
<div class="code-block$lineNumbersClass">
  $titleHtml
  <pre><code class="language-$language">$code</code></pre>
  <button class="copy-button" aria-label="Copy code">Copy</button>
</div>
''';
  }

  static String _buildCard(Map<String, dynamic> props, String? children) {
    final title = props['title'] as String?;
    final icon = props['icon'] as String?;
    final href = props['href'] as String?;

    final iconHtml = icon != null ? '<div class="card-icon">$icon</div>' : '';
    final titleHtml = title != null ? '<h3 class="card-title">$title</h3>' : '';

    final content = '''
<div class="card">
  $iconHtml
  $titleHtml
  <div class="card-content">${children ?? ''}</div>
</div>
''';

    if (href != null) {
      return '<a href="$href" class="card-link">$content</a>';
    }

    return content;
  }

  static String _buildCardGrid(Map<String, dynamic> props, String? children) {
    final cols = props['cols'] as int? ?? 2;

    return '''
<div class="card-grid" style="--card-grid-cols: $cols">
  ${children ?? ''}
</div>
''';
  }
}
