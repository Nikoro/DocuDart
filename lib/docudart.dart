/// DocuDart - A static documentation generator for Dart, powered by Jaspr.
library;

// Configuration
export 'src/config/docudart_config.dart';
export 'src/config/setup.dart';

// Models
export 'src/models/asset.dart';
export 'src/models/changelog.dart';
export 'src/models/doc.dart';
export 'src/models/license.dart';
export 'src/models/project.dart';
export 'src/models/pubspec.dart';
export 'src/models/repository.dart';
export 'src/models/page.dart';
export 'src/models/theme_mode.dart';
export 'src/models/toc_entry.dart';
export 'src/models/versioning_config.dart';

// Theme
export 'src/theme/theme.dart';
export 'src/theme/color_scheme.dart';
export 'src/theme/text_style.dart';
export 'src/theme/text_theme.dart';
export 'src/theme/markdown_theme.dart';
export 'src/theme/code_theme.dart';
export 'src/theme/sidebar_theme.dart';
export 'src/theme/header_theme.dart';
export 'src/theme/footer_theme.dart';
export 'src/theme/logo_theme.dart';
export 'src/theme/button_theme.dart';
export 'src/theme/card_theme.dart';
export 'src/theme/callout_theme.dart';
export 'src/theme/icon_button_theme.dart';
export 'src/theme/landing_theme.dart';

// Components — Navigation
export 'src/components/navigation/expansion_tile.dart';
export 'src/components/navigation/link.dart';
export 'src/components/navigation/sidebar.dart';
export 'src/components/navigation/sidebar_toggle.dart';
export 'src/components/navigation/table_of_contents.dart';
export 'src/components/navigation/theme_toggle.dart';
export 'src/components/navigation/toc_scroll_spy.dart';

// Components — Content
export 'src/components/content/markdown.dart';
export 'src/components/content/text_widget.dart';

// Components — Branding
export 'src/components/branding/logo.dart';
export 'src/components/branding/copyright.dart';
export 'src/components/branding/built_with_docudart.dart';
export 'src/components/branding/socials.dart';
export 'src/components/branding/topics.dart';

// Components — Interaction
export 'src/components/interaction/icon_button.dart';
export 'src/components/interaction/tooltip.dart';

// Components — Animation
export 'src/components/animation/slide_transition.dart';

// Components — Layout
export 'src/components/layout/layout.dart';
export 'src/components/layout/flex_enums.dart';
export 'src/components/layout/row.dart';
export 'src/components/layout/flexible.dart';
export 'src/components/layout/expanded.dart';
export 'src/components/layout/spacer.dart';
export 'src/components/layout/sized_box.dart';
export 'src/components/layout/padding.dart';
export 'src/components/layout/edge_insets.dart';
export 'src/components/layout/container.dart';
export 'src/components/layout/box_decoration.dart';
export 'src/components/layout/center.dart';
export 'src/components/layout/wrap.dart';
export 'src/components/layout/divider.dart';
export 'src/components/layout/card.dart';
export 'src/components/layout/badge.dart';

// Components — Providers
export 'src/components/providers/project_provider.dart';
export 'src/components/providers/theme_provider.dart';

// Icons
export 'src/icons/icons.dart';

// Extensions
export 'src/extensions/extensions.dart';

// Re-export Jaspr so user pages can use Jaspr APIs via docudart
export 'package:jaspr/jaspr.dart' hide Text;
export 'package:jaspr/dom.dart'
    hide ColorScheme, Padding, Border, BorderSide, BorderRadius, BoxShadow;
