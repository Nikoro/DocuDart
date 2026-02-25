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

### SidebarToggle (`navigation/sidebar_toggle.dart`)

`@client` component that toggles the mobile sidebar drawer from Dart.

```dart
SidebarToggle()
```

- Annotated with `@client` — hydrated client-side by Jaspr's `ClientApp`
- Renders an `IconButton(icon: Icon(MaterialSymbols.menu))` with an `onPressed` callback
- On click: calls `web.document.body.classList.toggle('sidebar-open')` via `universal_web`
- Uses `kIsWeb` guard so DOM access only runs in the browser
- No constructor params (serialization-free) — `super.key` is automatically excluded by `jaspr_builder`
- The generated Header template uses `context.screen.maybeWhen()` to show `SidebarToggle()` on mobile/tablet

### Sidebar Interactivity (vanilla JS in `theme.js`)

- **Collapsible categories**: `.expansion-tile[data-category]` click/keyboard toggle, CSS chevron rotation + `max-height` transition, state persisted in localStorage (`docudart-sidebar-state` key). `initCollapse()` suppresses transitions on page load to prevent visual flash.
- **Active link highlighting**: `.sidebar-link.active` class via JS matching `window.location.pathname` against `data-path`; left blue border accent + subtle background tint
- **SPA navigation**: monkey-patches `history.pushState`/`replaceState` → `docudart-navigate` event; MutationObserver re-applies collapse + active link if Jaspr re-renders
- **Auto-expand**: parent categories of active link automatically expand on navigation
- **Mobile drawer close** (`initMobileMenu()`): `.sidebar-backdrop` click or `.sidebar-link` click closes drawer by removing `body.sidebar-open`. The sidebar toggle itself is handled by the `@client` `SidebarToggle` component, not JS.

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
- Structure: `Column > [skip-link, header?, Expanded(Row > [sidebar?, body?]), footer?, sidebar-backdrop?]`
- Layout does NOT render the mobile menu button — that's the user's responsibility in their Header component using `context.screen` and `SidebarToggle`
- When sidebar is present: renders `.sidebar-backdrop` (full-screen overlay for closing drawer)
- Body: `.site-main` CSS class; inline flex styles
- Row always spans full viewport width (maxWidth 100%); header/footer also full-width (no max-width constraint)
- Generated `LayoutDelegate` delegates to this or to `config.layoutBuilder`
- Includes skip-to-content link (`<a class="skip-to-content" href="#main-content">`)

### Row / Column (`layout/row.dart`)

Flutter-like flex containers with inline styles. CSS classes kept as selector hooks only.

### Expanded / Flexible / Spacer / SizedBox (`layout/`)

Standard Flutter-like layout primitives. `SizedBox` named to avoid conflict with Jaspr's `Gap`.

## Interaction

### IconButton (`interaction/icon_button.dart`)

Flutter-like icon button. Renders `<button class="icon-button">` with an icon child.

```dart
IconButton(
  icon: Icon(MaterialSymbols.menu),
  tooltip: 'Open menu',
  onPressed: () { /* ... */ },
)
```

- `icon` (`Component`) — the icon widget to display
- `onPressed` (`VoidCallback?`) — optional click callback
- `tooltip` (`String?`) — maps to `title` and `aria-label` attributes
- CSS: `.icon-button` base styles (inline-flex, no border, hover state)

## Animation

### SlideTransition (`animation/slide_transition.dart`)

CSS transform-based slide animation with JS-driven trigger.

```dart
SlideTransition(
  direction: SlideDirection.left,
  trigger: 'body.sidebar-open',
  child: sidebar,
)
```

- `child` (`Component`) — content to slide in/out
- `direction` (`SlideDirection`) — slides FROM this direction when entering (`left`, `right`, `top`, `bottom`)
- `duration` (`Duration`) — CSS transition duration (default 300ms)
- `curve` (`Curve`) — timing curve (default `Curve.ease`; uses Jaspr's `Curve` class)
- `trigger` (`String?`) — CSS selector; when `document.querySelector(trigger)` matches, `data-slide-active` is set and child slides to natural position
- `classes` (`String?`) — additional CSS classes
- Uses Jaspr's typed `Transform.translate()` and `Transition()` for inline styles
- JS `initSlideTransitions()` in `theme.js` observes class changes on `<body>`/`<html>` to toggle `data-slide-active`

## Providers

### ProjectProvider (`providers/project_provider.dart`)

`InheritedComponent` providing `Project` data via the component tree.

- Generated `app.dart` wraps Router with `ProjectProvider`
- Extension `ProjectContext` on `BuildContext` adds `.project` getter
- Usage: `context.project.pubspec.name`, `context.project.docs`

## User-Owned Components (generated by ProjectGenerator)

These live in the user's `components/` directory, not in the library:

- **Header**: `Header(leading:, links:, trailing:, showSidebarToggle:)` → `header > Row` directly. Uses `?context.screen.maybeWhen(mobile:, tablet:)` to show `SidebarToggle()` on mobile/tablet (null on desktop, no spacing gap).
- **Footer**: `Footer(leading:, center:, trailing:)` → `footer > Row` directly
- **Button**: `Button(text:, href:, classes:)` with `.primary()` factory
- **Sidebar**: Wrapper around `DefaultSidebar`

## Screen Extension (`extensions/screen_extension.dart`)

Responsive rendering via CSS media queries. Renders all variants; CSS shows the matching one.

```dart
context.screen.when(
  mobile: () => MobileNav(),
  tablet: () => TabletNav(),
  desktop: () => DesktopNav(),
)

context.screen.maybeWhen(
  mobile: () => HamburgerMenu(),
  orElse: () => FullNav(),
)
```

- Breakpoints: mobile (0–768px), tablet (769–1024px), desktop (1025px+)
- Uses `display: contents` on `.screen-mobile`, `.screen-tablet`, `.screen-desktop` so wrappers are layout-invisible
- SSR-compatible: all variants rendered to DOM, CSS controls visibility
- `when()` requires all three callbacks; `maybeWhen()` has optional `orElse` — when omitted, unspecified breakpoints produce no DOM (returns `Component?`)
- Use `?context.screen.maybeWhen(mobile: ..., tablet: ...)` with null-aware `?` to conditionally include in children lists without leaving empty spacing gaps

## Gotchas

- **Inline styles override CSS** — properties needing `@media` overrides must stay in CSS
- `Row`/`Column` set flex inline; CSS classes are only selector hooks for contextual overrides
- `classes` takes `String` (space-separated), NOT `List<String>`
