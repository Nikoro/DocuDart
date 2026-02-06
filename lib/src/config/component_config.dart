import 'package:meta/meta.dart';

/// Configuration for custom component registration.
@immutable
class ComponentConfig {
  /// Whether to auto-discover components from componentsDir.
  final bool autoDiscover;

  /// Directory to scan for custom components.
  final String componentsDir;

  /// Explicitly registered components.
  final List<ComponentRegistration> register;

  const ComponentConfig({
    this.autoDiscover = true,
    this.componentsDir = 'components',
    this.register = const [],
  });

  Map<String, dynamic> toJson() => {
    'autoDiscover': autoDiscover,
    'componentsDir': componentsDir,
    'register': register.map((r) => r.toJson()).toList(),
  };

  factory ComponentConfig.fromJson(Map<String, dynamic> json) =>
      ComponentConfig(
        autoDiscover: json['autoDiscover'] as bool? ?? true,
        componentsDir: json['componentsDir'] as String? ?? 'components',
        register: (json['register'] as List<dynamic>?)
                ?.map(
                  (e) =>
                      ComponentRegistration.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const [],
      );
}

/// Registration of a custom component for use in markdown.
@immutable
class ComponentRegistration {
  /// Name used to reference the component in markdown (e.g., `<MyComponent />`).
  final String name;

  /// The component type.
  final Type componentType;

  const ComponentRegistration(this.name, this.componentType);

  Map<String, dynamic> toJson() => {'name': name};

  factory ComponentRegistration.fromJson(Map<String, dynamic> json) =>
      ComponentRegistration(json['name'] as String, Object);
}
