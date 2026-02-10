/// DocuDart - A static documentation generator for Dart, powered by Jaspr.
library;

// Configuration
export 'src/config/docudart_config.dart';
export 'src/config/setup.dart';
export 'src/config/config_loader.dart';

// Models
export 'src/models/project.dart';
export 'src/models/pubspec.dart';
export 'src/models/repository.dart';
export 'src/models/custom_page.dart';
export 'src/models/theme_mode.dart';
export 'src/models/versioning_config.dart';

// Theme
export 'src/theme/base_theme.dart';
export 'src/theme/default_theme.dart';
export 'src/theme/theme_colors.dart';
export 'src/theme/theme_typography.dart';
export 'src/theme/theme_loader.dart';

// Processing
export 'src/processing/content_processor.dart';
export 'src/processing/version_manager.dart';
export 'src/processing/readme_parser.dart';

// Generators
export 'src/generators/site_generator.dart';

// Markdown
export 'src/markdown/markdown_processor.dart';
export 'src/markdown/frontmatter_handler.dart';
export 'src/markdown/component_parser.dart';

// Components
export 'src/components/link.dart';
export 'src/components/component_registry.dart';
export 'src/components/defaults/logo.dart';
export 'src/components/defaults/built_with_docudart.dart';
export 'src/components/defaults/copyright.dart';
export 'src/components/defaults/default_sidebar.dart';
export 'src/components/defaults/theme_toggle.dart';
export 'src/components/defaults/socials.dart';
export 'src/components/defaults/topics.dart';
export 'src/components/defaults/markdown.dart';
export 'src/components/defaults/project_provider.dart';

// Layout
export 'src/components/layout/flex_enums.dart';
export 'src/components/layout/row.dart';
export 'src/components/layout/flexible.dart';
export 'src/components/layout/expanded.dart';
export 'src/components/layout/spacer.dart';

// Extensions
export 'src/extensions/extensions.dart';

// Routing
export 'src/generators/sidebar_generator.dart';

// Re-export Jaspr so user pages can use Jaspr APIs via docudart
export 'package:jaspr/jaspr.dart';
export 'package:jaspr/dom.dart';
