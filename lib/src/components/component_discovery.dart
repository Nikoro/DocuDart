import 'dart:io';

import 'package:path/path.dart' as p;

/// Information about a discovered component.
class DiscoveredComponent {
  /// Component class name.
  final String name;

  /// File path where the component is defined.
  final String filePath;

  /// Relative import path from the components directory.
  final String importPath;

  const DiscoveredComponent({
    required this.name,
    required this.filePath,
    required this.importPath,
  });
}

/// Discovers custom components in the user's project.
class ComponentDiscovery {
  final String componentsDir;

  ComponentDiscovery(this.componentsDir);

  /// Discover all components in the components directory.
  ///
  /// Looks for Dart files containing classes that could be Jaspr components.
  Future<List<DiscoveredComponent>> discover() async {
    final discovered = <DiscoveredComponent>[];
    final dir = Directory(componentsDir);

    if (!dir.existsSync()) return discovered;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final components = await _analyzeFile(entity);
        discovered.addAll(components);
      }
    }

    return discovered;
  }

  /// Analyze a Dart file for component definitions.
  Future<List<DiscoveredComponent>> _analyzeFile(File file) async {
    final components = <DiscoveredComponent>[];

    try {
      final content = await file.readAsString();

      // Look for classes that extend StatelessComponent or StatefulComponent
      // This is a simple regex-based approach; a proper solution would use the analyzer package
      final classPattern = RegExp(
        r'class\s+(\w+)\s+extends\s+(Stateless|Stateful)Component',
        multiLine: true,
      );

      for (final match in classPattern.allMatches(content)) {
        final className = match.group(1)!;

        // Calculate import path relative to components directory
        final relativePath = p.relative(file.path, from: componentsDir);
        final importPath = relativePath.replaceAll(r'\', '/');

        components.add(DiscoveredComponent(
          name: className,
          filePath: file.path,
          importPath: importPath,
        ));
      }
    } catch (e) {
      // Ignore files that can't be read or parsed
    }

    return components;
  }

  /// Generate Dart code to register discovered components.
  static String generateRegistrationCode(List<DiscoveredComponent> components) {
    if (components.isEmpty) {
      return '// No custom components discovered';
    }

    final buffer = StringBuffer();

    // Generate imports
    for (final component in components) {
      buffer.writeln("import 'package:user_project/components/${component.importPath}';");
    }

    buffer.writeln();
    buffer.writeln('void registerCustomComponents(ComponentRegistry registry) {');

    for (final component in components) {
      buffer.writeln('  // ${component.name} from ${component.importPath}');
      buffer.writeln("  registry.register('${component.name}', (props, children) {");
      buffer.writeln('    // Custom component rendering logic');
      buffer.writeln("    return '<div data-component=\"${component.name}\">\$children</div>';");
      buffer.writeln('  });');
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}
