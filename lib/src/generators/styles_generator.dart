import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/docudart_config.dart';

/// Generates the CSS stylesheet for the DocuDart site.
class StylesGenerator {
  StylesGenerator(this.config);

  final Config config;

  static String _toHex(int color) =>
      '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// Generate styles.css in the given [webDir].
  Future<void> generate(
    String webDir, {
    bool includeVersionSwitcher = false,
  }) async {
    final colors = config.theme.colors;
    final typography = config.theme.typography;

    final styles =
        '''
/* DocuDart Generated Styles */

:root {
  /* Colors - Light Mode */
  --color-primary: ${_toHex(colors.primary)};
  --color-secondary: ${_toHex(colors.secondary)};
  --color-background: ${_toHex(colors.background)};
  --color-surface: ${_toHex(colors.surface)};
  --color-text: ${_toHex(colors.text)};
  --color-text-muted: ${_toHex(colors.textMuted)};
  --color-border: ${_toHex(colors.border)};
  --color-code-background: ${_toHex(colors.codeBackground)};

  /* Typography */
  --font-family: ${typography.fontFamily};
  --font-family-mono: ${typography.monoFontFamily};
  --font-size-base: ${typography.baseFontSize}px;
  --line-height: ${typography.lineHeight};
}

/* Dark mode via system preference */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --color-primary: ${_toHex(colors.darkPrimary)};
    --color-secondary: ${_toHex(colors.darkSecondary)};
    --color-background: ${_toHex(colors.darkBackground)};
    --color-surface: ${_toHex(colors.darkSurface)};
    --color-text: ${_toHex(colors.darkText)};
    --color-text-muted: ${_toHex(colors.darkTextMuted)};
    --color-border: ${_toHex(colors.darkBorder)};
    --color-code-background: ${_toHex(colors.darkCodeBackground)};
  }
}

/* Dark mode via toggle */
:root[data-theme="dark"] {
  --color-primary: ${_toHex(colors.darkPrimary)};
  --color-secondary: ${_toHex(colors.darkSecondary)};
  --color-background: ${_toHex(colors.darkBackground)};
  --color-surface: ${_toHex(colors.darkSurface)};
  --color-text: ${_toHex(colors.darkText)};
  --color-text-muted: ${_toHex(colors.darkTextMuted)};
  --color-border: ${_toHex(colors.darkBorder)};
  --color-code-background: ${_toHex(colors.darkCodeBackground)};
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
}

header > .row {
  max-width: 1400px;
  margin: 0 auto;
  padding: 1rem 2rem;
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
  height: 1.75rem;
  width: auto;
  display: block;
}

.logo-title {
  font-size: 1.25rem;
  font-weight: 600;
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
  fill: currentColor;
}

/* Sidebar */
.sidebar {
  width: 280px;
  flex-shrink: 0;
  padding: 2rem 1rem;
  border-right: 1px solid var(--color-border);
  background-color: var(--color-surface);
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
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--color-text);
  padding: 0.375rem 0.75rem;
  border-radius: 0.375rem;
  transition: color 0.15s;
}

.expansion-tile-header:hover {
  color: var(--color-primary);
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
  color: var(--color-text);
  text-decoration: none;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  border-left: 3px solid transparent;
  transition: all 0.15s;
}

.sidebar-link:hover {
  background-color: var(--color-background);
  color: var(--color-primary);
}

.sidebar-link.active {
  border-left-color: var(--color-primary);
  color: var(--color-primary);
  background-color: rgba(1, 117, 194, 0.08);
  font-weight: 500;
}

/* Main */
.site-main {
  padding: 2rem 3rem;
}

/* Footer */
footer {
  background-color: var(--color-surface);
  border-top: 1px solid var(--color-border);
  padding: 2rem;
}

footer > .row {
  max-width: 1400px;
  margin: 0 auto;
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
  max-width: 800px;
  margin: 0 auto;
}

.landing-page.column {
  text-align: center;
  padding: 4rem 2rem;
}

.landing-page.column h1 {
  font-size: 3rem;
  font-weight: 700;
  color: var(--color-text);
}

.landing-page .description {
  font-size: 1.25rem;
  color: var(--color-text-muted);
  max-width: 600px;
}

/* Buttons */
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  font-weight: 500;
  border-radius: 0.5rem;
  text-decoration: none;
  transition: all 0.2s;
  cursor: pointer;
  border: none;
}

.button-primary {
  background-color: var(--color-primary);
  color: white;
}

.button-primary:hover {
  filter: brightness(1.1);
}

/* Docs Content */
.docs-page {
  width: 100%;
}

.docs-content {
  max-width: 100%;
}

.docs-content h1 {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid var(--color-border);
}

.docs-content h2 {
  font-size: 1.75rem;
  font-weight: 600;
  margin-top: 2.5rem;
  margin-bottom: 1rem;
}

.docs-content h3 {
  font-size: 1.25rem;
  font-weight: 600;
  margin-top: 2rem;
  margin-bottom: 0.75rem;
}

.docs-content h4 {
  font-size: 1rem;
  font-weight: 600;
  margin-top: 1.5rem;
  margin-bottom: 0.5rem;
}

.docs-content p {
  margin-bottom: 1rem;
}

.docs-content ul, .docs-content ol {
  margin-bottom: 1rem;
  padding-left: 1.5rem;
}

.docs-content li {
  margin-bottom: 0.5rem;
}

.docs-content a {
  color: var(--color-primary);
  text-decoration: none;
}

.docs-content a:hover {
  text-decoration: underline;
}

.docs-content code {
  font-family: var(--font-family-mono);
  font-size: 0.875em;
  background-color: var(--color-code-background);
  padding: 0.2em 0.4em;
  border-radius: 0.25rem;
}

.docs-content pre {
  background-color: var(--color-code-background);
  padding: 1rem;
  border-radius: 0.5rem;
  overflow-x: auto;
  margin-bottom: 1rem;
}

.docs-content pre code {
  background: none;
  padding: 0;
  font-size: 0.875rem;
}

.docs-content blockquote {
  border-left: 4px solid var(--color-primary);
  padding-left: 1rem;
  margin: 1rem 0;
  color: var(--color-text-muted);
}

.docs-content table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}

.docs-content th, .docs-content td {
  padding: 0.75rem;
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
  border-radius: 0.5rem;
}

.docs-content hr {
  border: none;
  border-top: 1px solid var(--color-border);
  margin: 2rem 0;
}

/* Responsive */
@media (max-width: 1024px) {
  .sidebar {
    display: none;
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

/* ========== Component Styles ========== */

/* Callout Component */
.callout {
  padding: 1rem 1.25rem;
  margin: 1rem 0;
  border-radius: 0.5rem;
  border-left: 4px solid;
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
  background-color: rgba(59, 130, 246, 0.1);
  border-color: #3b82f6;
}

.callout-tip {
  background-color: rgba(34, 197, 94, 0.1);
  border-color: #22c55e;
}

.callout-warning {
  background-color: rgba(234, 179, 8, 0.1);
  border-color: #eab308;
}

.callout-danger {
  background-color: rgba(239, 68, 68, 0.1);
  border-color: #ef4444;
}

.callout-note {
  background-color: rgba(107, 114, 128, 0.1);
  border-color: #6b7280;
}

/* Tabs Component */
.tabs-container {
  margin: 1.5rem 0;
  border: 1px solid var(--color-border);
  border-radius: 0.5rem;
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
  border-bottom: 2px solid transparent;
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
  padding: 1.5rem;
  border: 1px solid var(--color-border);
  border-radius: 0.5rem;
  background-color: var(--color-surface);
  transition: all 0.15s;
}

.card:hover {
  border-color: var(--color-primary);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
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
  background-color: rgba(239, 68, 68, 0.1);
  border: 1px dashed #ef4444;
  border-radius: 0.5rem;
  color: #ef4444;
  font-size: 0.875rem;
}

/* Dark Mode for Components */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) .callout-info {
    background-color: rgba(59, 130, 246, 0.15);
  }

  :root:not([data-theme="light"]) .callout-tip {
    background-color: rgba(34, 197, 94, 0.15);
  }

  :root:not([data-theme="light"]) .callout-warning {
    background-color: rgba(234, 179, 8, 0.15);
  }

  :root:not([data-theme="light"]) .callout-danger {
    background-color: rgba(239, 68, 68, 0.15);
  }

  :root:not([data-theme="light"]) .callout-note {
    background-color: rgba(107, 114, 128, 0.2);
  }

  :root:not([data-theme="light"]) .card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  }
}

:root[data-theme="dark"] .callout-info {
  background-color: rgba(59, 130, 246, 0.15);
}

:root[data-theme="dark"] .callout-tip {
  background-color: rgba(34, 197, 94, 0.15);
}

:root[data-theme="dark"] .callout-warning {
  background-color: rgba(234, 179, 8, 0.15);
}

:root[data-theme="dark"] .callout-danger {
  background-color: rgba(239, 68, 68, 0.15);
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
  fill: currentColor;
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
  box-shadow: 0 0 0 3px rgba(1, 117, 194, 0.1);
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
    box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.2);
  }
}
'''
        : '';

    await Directory(webDir).create(recursive: true);
    await File(
      p.join(webDir, 'styles.css'),
    ).writeAsString(styles + versionSwitcherStyles);
  }
}
