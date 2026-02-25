// ignore_for_file: prefer_class_destructuring
import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/docudart_config.dart';
import '../theme/code_theme.dart';
import '../theme/color_scheme.dart';

/// Generates the CSS stylesheet for the DocuDart site.
class StylesGenerator {
  StylesGenerator(this.config);

  final Config config;

  /// Generate styles.css in the given [webDir].
  Future<void> generate(
    String webDir, {
    bool includeVersionSwitcher = false,
  }) async {
    final theme = config.theme;
    final light = theme.lightColorScheme;
    final dark = theme.darkColorScheme;
    final text = theme.textTheme;
    final md = theme.markdownTheme;
    final sidebar = theme.sidebarTheme;
    final header = theme.headerTheme;
    final footer = theme.footerTheme;
    final logo = theme.logoTheme;
    final btn = theme.buttonTheme;
    final card = theme.cardTheme;
    final callout = theme.calloutTheme;
    final iconBtn = theme.iconButtonTheme;
    final landing = theme.landingTheme;

    // Generate heading CSS from TextTheme + MarkdownTheme spacing
    final h1Props = text.h1.toCssProperties();
    final h2Props = text.h2.toCssProperties();
    final h3Props = text.h3.toCssProperties();
    final h4Props = text.h4.toCssProperties();

    final headingsCss =
        '''
.docs-content h1 {
${h1Props.entries.map((e) => '  ${e.key}: ${e.value};').join('\n')}
  margin-bottom: ${md.h1MarginBottom}rem;
  padding-bottom: ${md.h1PaddingBottom}rem;
${md.h1HasBorderBottom ? '  border-bottom: 1px solid var(--color-border);' : ''}
}

.docs-content h2 {
${h2Props.entries.map((e) => '  ${e.key}: ${e.value};').join('\n')}
  margin-top: ${md.h2MarginTop}rem;
  margin-bottom: ${md.h2MarginBottom}rem;
}

.docs-content h3 {
${h3Props.entries.map((e) => '  ${e.key}: ${e.value};').join('\n')}
  margin-top: ${md.h3MarginTop}rem;
  margin-bottom: ${md.h3MarginBottom}rem;
}

.docs-content h4 {
${h4Props.entries.map((e) => '  ${e.key}: ${e.value};').join('\n')}
  margin-top: ${md.h4MarginTop}rem;
  margin-bottom: ${md.h4MarginBottom}rem;
}''';

    // Generate opal syntax highlighting CSS
    final lightBg = CodeTheme.toHex(md.lightCodeTheme.background);
    final lightFg = CodeTheme.toHex(md.lightCodeTheme.foreground);
    final darkBg = CodeTheme.toHex(md.darkCodeTheme.background);
    final darkFg = CodeTheme.toHex(md.darkCodeTheme.foreground);

    // Sidebar CSS — driven by SidebarTheme
    final sidebarBgCss = sidebar.backgroundColor != null
        ? '  background-color: ${_hex(sidebar.backgroundColor!)};'
        : '  background-color: var(--color-surface);';
    final sidebarBorderCss = sidebar.hasBorderRight
        ? '  border-right: 1px solid ${sidebar.borderColor != null ? _hex(sidebar.borderColor!) : 'var(--color-border)'};'
        : '  border-right: none;';

    final sidebarLinkHoverBgCss = sidebar.linkHoverBg != null
        ? '  background-color: ${_hex(sidebar.linkHoverBg!)};'
        : '  background-color: var(--color-surface-variant);';
    final sidebarLinkHoverColorCss = sidebar.linkHoverColor != null
        ? '  color: ${_hex(sidebar.linkHoverColor!)};'
        : '  color: var(--color-primary);';

    final sidebarActiveBorderCss = sidebar.activeBorderWidth > 0
        ? '  border-left-color: ${sidebar.activeColor != null ? _hex(sidebar.activeColor!) : 'var(--color-primary)'};'
        : '';
    final sidebarActiveColorCss = sidebar.activeColor != null
        ? '  color: ${_hex(sidebar.activeColor!)};'
        : '  color: var(--color-primary);';
    final sidebarActiveBgCss = sidebar.activeBg != null
        ? '  background-color: ${_hex(sidebar.activeBg!)};'
        : '  background-color: ${ColorScheme.toRgba(light.primary, sidebar.activeOpacity)};';

    final expansionTileHoverBgCss = sidebar.expansionTileHoverBg != null
        ? '  background-color: ${_hex(sidebar.expansionTileHoverBg!)};'
        : sidebar.activeBorderWidth == 0
        ? '  background-color: var(--color-surface-variant);'
        : '';

    // Button primary text color
    final btnPrimaryTextCss = btn.primaryTextColor != null
        ? '  color: ${_hex(btn.primaryTextColor!)};'
        : '  color: white;';

    // Button hover CSS
    final btnHoverCss = switch (btn.hoverEffect) {
      .brightness =>
        '${btn.hoverHasBoxShadow ? '  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);\n' : ''}'
            '  filter: brightness(${btn.hoverBrightness});',
      .opacity => '  opacity: ${btn.hoverOpacity};',
    };

    // Card CSS — driven by CardTheme
    final cardShadowCss = card.hasBoxShadow
        ? '  box-shadow: 0 ${card.shadowBlur ~/ 2}px ${card.shadowBlur.toInt()}px rgba(0, 0, 0, ${card.shadowOpacity});'
        : '';

    final cardHoverCss = switch (card.hoverEffect) {
      .shadow =>
        '  box-shadow: 0 ${card.hoverShadowBlur ~/ 4}px ${card.hoverShadowBlur.toInt()}px rgba(0, 0, 0, ${card.hoverShadowOpacity});'
            '${card.hoverTranslateY != 0 ? '\n  transform: translateY(${card.hoverTranslateY}px);' : ''}',
      .borderHighlight =>
        '  border-color: var(--color-text-muted);\n  box-shadow: none;',
    };

    final styles =
        '''
/* DocuDart Generated Styles */

:root {
  /* Colors - Light Mode */
${_cssVars(light.cssVariables)}

  /* Typography */
${_cssVars(text.cssVariables)}
}

/* Dark mode via system preference */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
${_cssVars(dark.cssVariables, indent: '    ')}
  }
}

/* Dark mode via toggle */
:root[data-theme="dark"] {
${_cssVars(dark.cssVariables)}
}

/* Reset */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* Base */
html {
  font-size: var(--font-size-base);
  line-height: var(--line-height);
}

body {
  font-family: var(--font-family);
  background-color: var(--color-background);
  color: var(--color-text);
  min-height: 100vh;
}

/* Skip to content (accessibility) */
.skip-to-content {
  position: absolute;
  left: -9999px;
  top: 0;
  z-index: 999;
  padding: 0.5rem 1rem;
  background-color: var(--color-primary);
  color: #fff;
  text-decoration: none;
  font-weight: 600;
}

.skip-to-content:focus {
  left: 0;
}

/* Header */
header {
  position: sticky;
  top: 0;
  z-index: 100;
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
${header.hasBoxShadow ? '  box-shadow: 0 1px ${header.shadowBlur.toInt()}px rgba(0, 0, 0, ${header.shadowOpacity});\n' : ''}}

header > .row {
  padding: ${header.paddingV}rem ${header.paddingH}rem;
}

.logo,
.logo:visited {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: var(--color-text);
  line-height: 1;
}

.logo:hover,
.logo:visited:hover {
  color: var(--color-primary);
  text-decoration: none;
}

.logo-image {
  display: inline-flex;
  align-items: center;
  flex-shrink: 0;
}

.logo-image img {
  height: ${logo.imageHeight}rem;
  width: auto;
  display: block;
}

.logo-title {
  font-size: ${logo.fontSize}rem;
  font-weight: ${logo.fontWeight};
  white-space: nowrap;
}

header a:not(.logo) {
  color: var(--color-text-muted);
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s;
}

header a:not(.logo):hover,
header a:not(.logo).active {
  color: var(--color-primary);
}

.nav-link {
  display: inline-flex;
  align-items: center;
  gap: 0.375em;
}

.nav-link-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.25em;
  height: 1.25em;
  line-height: 0;
  flex-shrink: 0;
}

.nav-link-icon svg {
  width: 100%;
  height: 100%;
}

/* Sidebar */
.sidebar {
  width: ${sidebar.width.toInt()}px;
  flex-shrink: 0;
  padding: ${sidebar.paddingV}rem ${sidebar.paddingH}rem;
$sidebarBorderCss
$sidebarBgCss
  height: calc(100vh - 65px);
  position: sticky;
  top: 65px;
  overflow-y: auto;
}

/* ExpansionTile */
.expansion-tile {
  margin-bottom: 0.25rem;
}

.expansion-tile-header {
  display: flex;
  align-items: center;
  cursor: pointer;
  user-select: none;
  font-size: ${sidebar.fontSize}rem;
  font-weight: 600;
  color: var(--color-text);
  padding: 0.375rem 0.75rem;
  border-radius: ${sidebar.linkBorderRadius}rem;
  transition: color 0.15s;
}

.expansion-tile-header:hover {
  color: var(--color-primary);
$expansionTileHoverBgCss
}

.expansion-tile-header::before {
  content: '';
  display: inline-block;
  width: 0;
  height: 0;
  border-left: 5px solid currentColor;
  border-top: 4px solid transparent;
  border-bottom: 4px solid transparent;
  margin-right: 0.5rem;
  flex-shrink: 0;
  transition: transform 0.2s ease;
}

.expansion-tile[data-collapsed="false"] > .expansion-tile-header::before {
  transform: rotate(90deg);
}

.expansion-tile-content {
  padding-left: 0.75rem;
  overflow: hidden;
  max-height: 2000px;
  opacity: 1;
  transition: max-height 0.3s ease, opacity 0.2s ease;
}

.expansion-tile[data-collapsed="true"] > .expansion-tile-content {
  max-height: 0;
  opacity: 0;
}

.sidebar-link {
  display: block;
  padding: 0.5rem 0.75rem;
  color: var(--color-text-muted);
  text-decoration: none;
  border-radius: ${sidebar.linkBorderRadius}rem;
  font-size: ${sidebar.fontSize}rem;
${sidebar.activeBorderWidth > 0 ? '  border-left: ${sidebar.activeBorderWidth.toInt()}px solid transparent;\n' : ''}  transition: all 0.15s;
}

.sidebar-link:hover {
$sidebarLinkHoverBgCss
$sidebarLinkHoverColorCss
}

.sidebar-link.active {
$sidebarActiveBorderCss
$sidebarActiveColorCss
$sidebarActiveBgCss
  font-weight: ${sidebar.activeFontWeight};
}

/* Main */
.site-main {
  padding: ${theme.mainPaddingV}rem ${theme.mainPaddingH}rem;
}

/* Footer */
footer {
  background-color: var(--color-surface);
  border-top: 1px solid var(--color-border);
  padding: ${footer.paddingV}rem ${footer.paddingH}rem;
}

footer > .row {
  padding: 0 ${footer.paddingH}rem;
  color: var(--color-text-muted);
}

footer .column {
  text-align: center;
}

.built-with {
  font-size: 0.85rem;
  margin-top: 0.5rem;
  opacity: 0.8;
}

.built-with a {
  color: var(--color-primary);
  text-decoration: none;
  font-weight: 500;
}

.built-with a:hover {
  text-decoration: underline;
}

/* Socials */
.socials {
  display: flex;
  gap: 0.75rem;
}

.socials .nav-link {
  color: var(--color-text-muted);
  transition: color 0.2s;
}

.socials .nav-link:hover {
  color: var(--color-primary);
}

.socials .nav-link-icon {
  width: 1.5em;
  height: 1.5em;
}

/* Topics */
.topics {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.topics-title {
  font-size: 0.7rem;
  font-weight: 500;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  opacity: 0.7;
}

.topics-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
}

.topics-grid .nav-link {
  padding: 0.2rem 0.55rem;
  border-radius: 1rem;
  font-size: 0.72rem;
  color: var(--color-text-muted);
  border: 1px solid var(--color-border, rgba(128, 128, 128, 0.25));
  transition: color 0.2s, border-color 0.2s;
  text-decoration: none;
  white-space: nowrap;
}

.topics-grid .nav-link:hover {
  color: var(--color-primary);
  border-color: var(--color-primary);
}

/* Hero */
.home-page {
  max-width: ${theme.contentMaxWidth.toInt()}px;
  margin: 0 auto;
}

.landing-page.column {
  text-align: center;
  padding: ${landing.paddingV}rem 2rem;
}

.landing-page.column h1 {
  font-size: ${landing.titleFontSize}rem;
  font-weight: 700;
  color: var(--color-text);
}

.landing-page .description {
  font-size: ${landing.descriptionFontSize}rem;
  color: var(--color-text-muted);
  max-width: 600px;
}

.landing-page .logo-image img {
  height: 5rem;
}

/* Buttons */
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: ${btn.paddingV}rem ${btn.paddingH}rem;
  font-size: 1rem;
  font-weight: ${btn.fontWeight};
  border-radius: ${btn.borderRadius}rem;
  text-decoration: none;
  transition: all 0.2s;
  cursor: pointer;
  border: none;
}

.button-primary {
  background-color: var(--color-primary);
$btnPrimaryTextCss
}

.button-primary:hover {
$btnHoverCss
}

/* Docs Content */
.docs-page {
  width: 100%;
}

.docs-content {
  max-width: 100%;
}

$headingsCss

.docs-content p {
  margin-bottom: ${md.paragraphMarginBottom}rem;
}

.docs-content ul, .docs-content ol {
  margin-bottom: ${md.listMarginBottom}rem;
  padding-left: ${md.listPaddingLeft}rem;
}

.docs-content li {
  margin-bottom: ${md.listItemMarginBottom}rem;
}

.docs-content a {
  color: var(--color-primary);
  text-decoration: ${md.linkDecoration};
}

.docs-content a:hover {
  text-decoration: ${md.linkHoverDecoration};
}

.docs-content code {
  font-family: var(--font-family-mono);
  font-size: 0.875em;
  background-color: var(--color-code-background);
  padding: ${md.codeInlinePaddingV}em ${md.codeInlinePaddingH}em;
  border-radius: ${md.codeInlineBorderRadius}rem;
}

.docs-content pre {
  padding: ${md.codeBlockPadding}rem;
  border-radius: ${md.codeBlockBorderRadius}rem;
  border: 1px solid var(--color-border);
  overflow-x: auto;
  margin-bottom: 1rem;
  line-height: 1.6;
}

.docs-content pre code {
  background: none;
  padding: 0;
  border-radius: 0;
  font-size: 0.875rem;
  line-height: inherit;
}

/* Code block wrapper (injected by JS around <pre>) */
.code-block-wrapper {
  position: relative;
  margin-bottom: 1rem;
}

.code-block-wrapper pre {
  margin-bottom: 0;
}

/* Language label */
.code-block-label {
  position: absolute;
  top: 0.25rem;
  right: 0.5rem;
  padding: 0.125rem 0.375rem;
  font-size: 0.8125rem;
  font-family: var(--font-family-mono);
  color: var(--color-text-muted);
  opacity: 0.6;
  user-select: none;
  pointer-events: none;
  line-height: 1.5;
  transition: opacity 0.25s;
  z-index: 1;
}

.code-block-wrapper:hover .code-block-label {
  opacity: 0;
}

/* Copy button */
.code-block-copy {
  position: absolute;
  top: 0.25rem;
  right: 0.375rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.625rem;
  height: 1.625rem;
  padding: 0.25rem;
  border: none;
  background: none;
  cursor: pointer;
  border-radius: 0.25rem;
  color: var(--color-text-muted);
  opacity: 0;
  transition: opacity 0.25s, color 0.15s, background-color 0.15s;
  z-index: 2;
}

.code-block-wrapper:hover .code-block-copy {
  opacity: 0.7;
}

.code-block-copy:hover {
  opacity: 1 !important;
  color: var(--color-text);
  background-color: var(--color-surface-variant);
}

.docs-content blockquote {
  border-left: ${md.blockquoteBorderWidth.toInt()}px solid var(--color-primary);
  padding-left: ${md.blockquotePaddingLeft}rem;
  margin: 1rem 0;
  color: var(--color-text-muted);
}

.docs-content table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}

.docs-content th, .docs-content td {
  padding: ${md.tableCellPadding}rem;
  text-align: left;
  border-bottom: 1px solid var(--color-border);
}

.docs-content th {
  font-weight: 600;
  background-color: var(--color-surface);
}

.docs-content img {
  max-width: 100%;
  height: auto;
  border-radius: ${md.imageBorderRadius}rem;
}

.docs-content hr {
  border: none;
  border-top: 1px solid var(--color-border);
  margin: ${md.hrMarginY}rem 0;
}

/* IconButton */
.icon-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: none;
  background: none;
  cursor: pointer;
  padding: ${iconBtn.padding}rem;
  border-radius: ${iconBtn.borderRadius}rem;
  color: var(--color-text-muted);
  transition: color 0.2s, background-color 0.2s;
  -webkit-tap-highlight-color: transparent;
}

.icon-button:hover {
  color: var(--color-primary);
  background-color: var(--color-bg-hover);
}

.icon-button svg {
  width: ${iconBtn.iconSize}rem;
  height: ${iconBtn.iconSize}rem;
}

/* Sidebar backdrop overlay */
.sidebar-backdrop {
  display: none;
  position: fixed;
  inset: 0;
  z-index: 199;
  background: rgba(0, 0, 0, 0.5);
  opacity: 0;
  transition: opacity 0.3s;
}

/* Responsive */
@media (max-width: 1024px) {
  .sidebar {
    position: fixed;
    top: 0;
    left: 0;
    z-index: 200;
    height: 100vh;
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }

  body.sidebar-open .sidebar {
    transform: translateX(0);
  }

  body.sidebar-open .sidebar-backdrop {
    display: block;
    opacity: 1;
  }

  .site-main {
    padding: 1.5rem;
  }
}

@media (max-width: 768px) {
  header > .row {
    padding: 1rem;
  }

  .landing-page.column h1 {
    font-size: 2rem;
  }

  .landing-page .description {
    font-size: 1rem;
  }

  .docs-content h1 {
    font-size: 1.75rem;
  }

  .docs-content h2 {
    font-size: 1.5rem;
  }
}

/* Screen-responsive containers */
.screen-mobile, .screen-tablet, .screen-desktop { display: none; }

@media (max-width: 768px) {
  .screen-mobile { display: contents; }
}

@media (min-width: 769px) and (max-width: 1024px) {
  .screen-tablet { display: contents; }
}

@media (min-width: 1025px) {
  .screen-desktop { display: contents; }
}

/* SlideTransition */
.slide-transition[data-slide-active] {
  transform: translate(0, 0) !important;
}

/* ========== Component Styles ========== */

/* Callout Component */
.callout {
  padding: ${callout.padding}rem ${callout.padding * 1.25}rem;
  margin: 1rem 0;
  border-radius: ${callout.borderRadius}rem;
  border-left: ${callout.borderWidth.toInt()}px solid;
}

.callout-icon {
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
}

.callout-title {
  font-weight: 600;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.callout-content p:last-child {
  margin-bottom: 0;
}

.callout-info {
  background-color: ${ColorScheme.toRgba(light.info, 0.1)};
  border-color: var(--color-info);
}

.callout-tip {
  background-color: ${ColorScheme.toRgba(light.success, 0.1)};
  border-color: var(--color-success);
}

.callout-warning {
  background-color: ${ColorScheme.toRgba(light.warning, 0.1)};
  border-color: var(--color-warning);
}

.callout-danger {
  background-color: ${ColorScheme.toRgba(light.error, 0.1)};
  border-color: var(--color-error);
}

.callout-note {
  background-color: rgba(107, 114, 128, 0.1);
  border-color: #6b7280;
}

/* Tabs Component */
.tabs-container {
  margin: 1.5rem 0;
  border: 1px solid var(--color-border);
  border-radius: ${card.borderRadius}rem;
  overflow: hidden;
}

.tabs-list {
  display: flex;
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  overflow-x: auto;
}

.tab-button {
  padding: 0.75rem 1.25rem;
  border: none;
  background: none;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text-muted);
  cursor: pointer;
  border-bottom: ${theme.tabBorderWidth.toInt()}px solid transparent;
  white-space: nowrap;
  transition: all 0.15s;
}

.tab-button:hover {
  color: var(--color-text);
  background-color: var(--color-background);
}

.tab-button.active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
}

.tabs-content {
  padding: 1rem;
}

.tab-panel {
  display: none;
}

.tab-panel.active {
  display: block;
}

/* Card Component */
.card {
  padding: ${card.padding}rem;
  border: 1px solid var(--color-border);
  border-radius: ${card.borderRadius}rem;
  background-color: var(--color-surface);
  transition: all 0.15s;
$cardShadowCss
}

.card:hover {
$cardHoverCss
}

.card-icon {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.card-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.card-content {
  color: var(--color-text-muted);
  font-size: 0.875rem;
}

.card-link {
  text-decoration: none;
  color: inherit;
  display: block;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(var(--card-grid-cols, 2), 1fr);
  gap: 1rem;
  margin: 1.5rem 0;
}

/* Unknown Component */
.component-unknown {
  padding: 1rem;
  margin: 1rem 0;
  background-color: ${ColorScheme.toRgba(light.error, 0.1)};
  border: 1px dashed var(--color-error);
  border-radius: ${card.borderRadius}rem;
  color: var(--color-error);
  font-size: 0.875rem;
}

/* Dark Mode for Components */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) .callout-info {
    background-color: ${ColorScheme.toRgba(dark.info, 0.15)};
  }

  :root:not([data-theme="light"]) .callout-tip {
    background-color: ${ColorScheme.toRgba(dark.success, 0.15)};
  }

  :root:not([data-theme="light"]) .callout-warning {
    background-color: ${ColorScheme.toRgba(dark.warning, 0.15)};
  }

  :root:not([data-theme="light"]) .callout-danger {
    background-color: ${ColorScheme.toRgba(dark.error, 0.15)};
  }

  :root:not([data-theme="light"]) .callout-note {
    background-color: rgba(107, 114, 128, 0.2);
  }

  :root:not([data-theme="light"]) .card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  }
}

:root[data-theme="dark"] .callout-info {
  background-color: ${ColorScheme.toRgba(dark.info, 0.15)};
}

:root[data-theme="dark"] .callout-tip {
  background-color: ${ColorScheme.toRgba(dark.success, 0.15)};
}

:root[data-theme="dark"] .callout-warning {
  background-color: ${ColorScheme.toRgba(dark.warning, 0.15)};
}

:root[data-theme="dark"] .callout-danger {
  background-color: ${ColorScheme.toRgba(dark.error, 0.15)};
}

:root[data-theme="dark"] .callout-note {
  background-color: rgba(107, 114, 128, 0.2);
}

:root[data-theme="dark"] .card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

/* ========== Theme Toggle ========== */

.theme-toggle {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  border: none;
  background: none;
  color: var(--color-text-muted);
  cursor: pointer;
  transition: color 0.2s;
  font-size: 1em;
}

.theme-toggle:hover {
  color: var(--color-primary);
}

.theme-toggle-light,
.theme-toggle-dark {
  display: inline-flex;
  align-items: center;
  width: 1.375em;
  height: 1.375em;
}

.theme-toggle-light svg,
.theme-toggle-dark svg {
  width: 100%;
  height: 100%;
}

/* Default: light icon visible, dark icon hidden */
.theme-toggle-dark { display: none; }

/* Dark mode via attribute */
:root[data-theme="dark"] .theme-toggle-dark { display: inline-flex; }
:root[data-theme="dark"] .theme-toggle-light { display: none; }

/* Dark mode via system preference (no explicit toggle yet) */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) .theme-toggle-dark { display: inline-flex; }
  :root:not([data-theme="light"]) .theme-toggle-light { display: none; }
}

/* ========== Theme-Aware Assets ========== */

.theme-asset { display: inline-block; }
.theme-asset > .theme-asset-light { display: inline; }
.theme-asset > .theme-asset-dark { display: none; }

/* Dark mode via attribute */
:root[data-theme="dark"] .theme-asset > .theme-asset-light { display: none; }
:root[data-theme="dark"] .theme-asset > .theme-asset-dark { display: inline; }

/* Dark mode via system preference (no explicit toggle yet) */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) .theme-asset > .theme-asset-light { display: none; }
  :root:not([data-theme="light"]) .theme-asset > .theme-asset-dark { display: inline; }
}

/* ========== Syntax Highlighting (opal build-time) ========== */

pre.opal {
  background-color: $lightBg;
  color: $lightFg;
}
.code-block-wrapper pre.opal {
  background-color: $lightBg;
}

:root[data-theme="dark"] pre.opal {
  background-color: $darkBg;
  color: $darkFg;
}
:root[data-theme="dark"] .code-block-wrapper pre.opal {
  background-color: $darkBg;
}
:root[data-theme="dark"] pre.opal span[style] {
  color: var(--dd-dark-color) !important;
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) pre.opal {
    background-color: $darkBg;
    color: $darkFg;
  }
  :root:not([data-theme="light"]) .code-block-wrapper pre.opal {
    background-color: $darkBg;
  }
  :root:not([data-theme="light"]) pre.opal span[style] {
    color: var(--dd-dark-color) !important;
  }
}
''';

    // Add version switcher styles if enabled
    final versionSwitcherStyles = includeVersionSwitcher
        ? '''

/* ========== Version Switcher ========== */

.version-switcher {
  display: flex;
  align-items: center;
}

.version-select {
  appearance: none;
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 0.375rem;
  padding: 0.5rem 2rem 0.5rem 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text);
  cursor: pointer;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M2.5 4.5L6 8l3.5-3.5'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.5rem center;
  transition: all 0.15s;
}

.version-select:hover {
  border-color: var(--color-primary);
}

.version-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px ${ColorScheme.toRgba(light.primary, 0.1)};
}

.version-select option {
  background-color: var(--color-surface);
  color: var(--color-text);
}

@media (prefers-color-scheme: dark) {
  .version-select {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%239ca3af' d='M2.5 4.5L6 8l3.5-3.5'/%3E%3C/svg%3E");
  }

  .version-select:focus {
    box-shadow: 0 0 0 3px ${ColorScheme.toRgba(dark.primary, 0.2)};
  }
}
'''
        : '';

    await Directory(webDir).create(recursive: true);
    await File(
      p.join(webDir, 'styles.css'),
    ).writeAsString(styles + versionSwitcherStyles);
  }

  /// Format CSS variable declarations.
  static String _cssVars(Map<String, String> vars, {String indent = '  '}) {
    return vars.entries.map((e) => '$indent${e.key}: ${e.value};').join('\n');
  }

  /// Convert an ARGB int color to a CSS hex string.
  static String _hex(int color) =>
      '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
