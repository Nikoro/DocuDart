# Components

Library-level components re-exported via `docudart.dart`. Users import these through `package:docudart/docudart.dart`.

## Navigation

### Link (`navigation/link.dart`)

Self-rendering navigation link (`StatelessComponent`) with optional leading/trailing icon components and label.

```dart
Link.path('/docs', label: 'Docs', leading: Icon(MaterialSymbols.docs))
Link.url('https://github.com', label: 'GitHub', leading: Icon(FontAwesomeIcons.github_brand), trailing: Icon(MaterialIcons.open_in_new))
```

- Renders `<a class="{classes}">` wrapping a `Row(mainAxisSize: .min, spacing: 0.375.em)`
- `label` (`String?`), `leading` (`Component?`), `trailing` (`Component?`) — at least one required
- `classes` defaults to `'nav-link'`; icon wrappers use `'{classes}-icon'`
- External: `target="_blank" rel="noopener noreferrer"`; internal: `data-path` for JS active highlighting
- Private fields `_path`/`_url`; public: `.href`, `.isExternal`
- `toJson()` uses `'label'` key, skips `leading`/`trailing`; `fromJson()` accepts legacy `'title'` key
- **Dart keyword gotcha**: `external`/`internal` are reserved — constructors are `.url()`/`.path()`

### ExpansionTile (`navigation/expansion_tile.dart`)

General-purpose collapsible tile with animated chevron header and expandable content.

```dart
ExpansionTile(id: 'guides', title: 'Guides', expanded: true, children: [...])
```

- `id` — unique identifier for collapse state persistence (localStorage)
- Renders: `div.expansion-tile[data-category][data-collapsed]` > header + content
- Chevron via CSS `::before` pseudo-element with rotation transition
- Content collapse via `max-height`/`opacity` CSS transition
- Has `aria-expanded` attribute for accessibility

### DefaultSidebar (`navigation/sidebar.dart`)

Collapsible navigation tree from docs structure using `Column` + `ExpansionTile`.

- `DefaultSidebar(items: List<Doc>)` — pattern matches on sealed `Doc` hierarchy
- Uses `Column(crossAxisAlignment: .stretch, mainAxisSize: .min)` (not `<ul>/<li>`)
- Renders `data-path` attributes on links for active page highlighting (left blue border accent)

### ThemeToggle (`navigation/theme_toggle.dart`)

CSS-driven light/dark icon swap — no JS text manipulation.

- `ThemeToggle(light: Component, dark: Component)` — renders both in DOM
- CSS uses `:root[data-theme="dark"]` and `@media (prefers-color-scheme: dark)` for visibility toggle
- Reuses `.theme-toggle` click handler in `theme.js`

### Sidebar Interactivity (vanilla JS in `theme.js`)

- **Collapsible categories**: `.expansion-tile[data-category]` click/keyboard toggle, CSS chevron rotation + `max-height` transition, state persisted in localStorage (`docudart-sidebar-state` key). `initCollapse()` suppresses transitions on page load to prevent visual flash.
- **Active link highlighting**: `.sidebar-link.active` class via JS matching `window.location.pathname` against `data-path`; left blue border accent + subtle background tint
- **SPA navigation**: monkey-patches `history.pushState`/`replaceState` → `docudart-navigate` event; MutationObserver re-applies collapse + active link if Jaspr re-renders
- **Auto-expand**: parent categories of active link automatically expand on navigation

## Content

### Markdown (`content/markdown.dart`)

Runtime markdown-to-HTML renderer component.

```dart
Markdown(content: '# Hello\n\nSome **bold** text.')
Markdown(content: context.project.changelog ?? '', classes: 'changelog-content')
```

- Uses `MarkdownProcessor` (pure Dart, no dart:io — works in browser)
- Supports embedded components via `ComponentRegistry`
- Default `classes: 'docs-content'`

## Branding

### Logo (`branding/logo.dart`)

```dart
Logo(image: img(src: Assets.logo.logo_webp, alt: 'Logo'), title: 'My Project')
```

- `image` (`Component?`), `title` (`String?`), `href` (`String`, default `"/"`)
- At least one of `image`/`title` required (assert)
- CSS: `.logo` (inline-flex, no link decoration), `.logo-image` (1.75rem), `.logo-title` (1.25rem semibold)

### Copyright / BuiltWithDocuDart (`branding/`)

- `Copyright(text:)` — renders `<p>` with `(c) {year} {text}`
- `BuiltWithDocuDart()` — renders `<p class="built-with">` with DocuDart link

### Socials (`branding/socials.dart`)

- `Socials(links: List<Link>)` — row of social media icon links; spreads Links directly
- CSS: `.socials` (flex row), `.socials .nav-link` (contextual overrides)

### Topics (`branding/topics.dart`)

- `Topics(title: String?, links: List<Link>)` — compact grid of topic tag links
- CSS: `.topics-grid .nav-link` (outline pill style)

## Layout

### Layout (`layout/layout.dart`)

Page layout arranging header, sidebar, body, and footer.

```dart
Layout(header: myHeader, sidebar: mySidebar, body: content, footer: myFooter)
```

- All 4 params optional `Component?`; `const`-constructible
- Structure: `Column > [header?, Expanded(Row > [sidebar?, body?]), footer?]`
- Body: `.site-main` CSS class; inline flex/maxWidth styles based on sidebar presence
- Sidebar presence controls Row maxWidth (1400px with sidebar, 100% without) and alignment
- Generated `LayoutDelegate` delegates to this or to `config.layoutBuilder`
- Includes skip-to-content link (`<a class="skip-to-content" href="#main-content">`)

### Row / Column (`layout/row.dart`)

Flutter-like flex containers with inline styles. CSS classes kept as selector hooks only.

### Expanded / Flexible / Spacer / SizedBox (`layout/`)

Standard Flutter-like layout primitives. `SizedBox` named to avoid conflict with Jaspr's `Gap`.

## Providers

### ProjectProvider (`providers/project_provider.dart`)

`InheritedComponent` providing `Project` data via the component tree.

- Generated `app.dart` wraps Router with `ProjectProvider`
- Extension `ProjectContext` on `BuildContext` adds `.project` getter
- Usage: `context.project.pubspec.name`, `context.project.docs`

## User-Owned Components (generated by ProjectGenerator)

These live in the user's `components/` directory, not in the library:

- **Header**: `Header(leading:, links:, trailing:)` → `header > Row` directly
- **Footer**: `Footer(leading:, center:, trailing:)` → `footer > Row` directly
- **Button**: `Button(text:, href:, classes:)` with `.primary()` factory
- **Sidebar**: Wrapper around `DefaultSidebar`

## Gotchas

- **Inline styles override CSS** — properties needing `@media` overrides must stay in CSS
- `Row`/`Column` set flex inline; CSS classes are only selector hooks for contextual overrides
- `classes` takes `String` (space-separated), NOT `List<String>`
