/// DocuDart - A static documentation generator for Dart, powered by Jaspr.
library;

// Configuration
export 'src/config/docudart_config.dart';
export 'src/config/nav_link.dart';
export 'src/config/setup.dart';
export 'src/config/project.dart';
export 'src/config/pubspec.dart';
export 'src/config/theme_config.dart';
export 'src/config/versioning_config.dart';
export 'src/config/custom_page.dart';
export 'src/config/config_loader.dart';

// Theme
export 'src/theme/base_theme.dart';
export 'src/theme/default_theme.dart';
export 'src/theme/theme_colors.dart';
export 'src/theme/theme_typography.dart';
export 'src/theme/theme_loader.dart';

// Core
export 'src/core/content_processor.dart';
export 'src/core/site_generator.dart';
export 'src/core/version_manager.dart';
export 'src/core/readme_parser.dart';

// Markdown
export 'src/markdown/markdown_processor.dart';
export 'src/markdown/frontmatter_handler.dart';
export 'src/markdown/component_parser.dart';

// Components
export 'src/components/component_registry.dart';
export 'src/components/defaults/default_header.dart';
export 'src/components/defaults/default_footer.dart';
export 'src/components/defaults/default_sidebar.dart';
export 'src/components/defaults/theme_toggle.dart';
export 'src/components/defaults/socials.dart';
export 'src/components/defaults/topics.dart';

// Routing
export 'src/routing/sidebar_generator.dart';

// Re-export Jaspr so user pages can use Jaspr APIs via docudart
export 'package:jaspr/jaspr.dart';
export 'package:jaspr/dom.dart';
