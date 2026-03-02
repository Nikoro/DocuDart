# Components

Library-level components re-exported via `docudart.dart`. Users import these through `package:docudart/docudart.dart`.

## Component Design Principles

1. **Public API mirrors Flutter** — users write `Padding(padding: EdgeInsets.all(16), child: ...)` just like Flutter
2. **Lean HTML output** — primitives use `.apply()` to merge styles onto children instead of wrapping in extra `<div>` elements
3. **Components that ARE containers keep their `<div>`** — `Row`, `Column`, `Container`, `Center`, `Wrap` need their element for flexbox layout
4. **Components that MODIFY children use `.apply()`** — `Padding`, `Flexible`, `Expanded`, `SizedBox` (with child) merge styles onto the child's root element
5. **No CSS class hooks on primitives** — `Row`, `Column`, `Spacer` use pure inline styles (no `.row`/`.column` CSS classes). Theme CSS uses semantic classes (`.header-main-row`, `.landing-page`) where needed.

### `.apply()` Shadowing Constraint

Jaspr's `Component.wrapElement()` creates `_WrappingDomComponent` (extends `InheritedComponent`). The inherited map is keyed by `runtimeType` — nested `.apply()` calls **shadow** each other (only innermost applies). Consequences:

- Never chain `.apply()` on `Padding`, `Flexible`, `Expanded`, or `SizedBox` (with child)
- Combine styles into a single `.apply()` on the target element instead

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

- `ThemeToggle(light: Component, dark: Component, tooltip: String)` — renders both in DOM
- `tooltip` defaults to `'Toggle theme'` — maps to `title` and `aria-label` attributes
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

### TableOfContents (`navigation/table_of_contents.dart`)

Server-rendered "On this page" sidebar listing heading links from page content.

```dart
TableOfContents(entries: context.project.changelog?.toc ?? [])
TableOfContents(entries: toc, title: 'Contents', minLevel: 2, maxLevel: 4)
```

- `entries` (`List<TocEntry>`) — required; TOC items extracted by `MarkdownProcessor`
- `title` (`String`, default `'On this page'`) — heading above the list
- `minLevel` / `maxLevel` (`int`, default 2/3) — filter entries by heading level
- Renders: `aside.toc` > `nav.toc-nav[aria-label]` > `.toc-title` + `ul.toc-list` > `li.toc-item.toc-level-{N}` > `a.toc-link[href][data-toc-id]`
- `data-toc-id` attributes link to heading IDs — consumed by `TocScrollSpy` for active highlighting
- Hidden at ≤1024px via CSS media query; sticky on desktop

### TocScrollSpy (`navigation/toc_scroll_spy.dart`)

`@client` component that highlights the active TOC link based on scroll position.

```dart
Row(children: [
  Expanded(child: div(classes: 'docs-content', [RawText(html)])),
  TableOfContents(entries: toc),
  TocScrollSpy(),
])
```

- Annotated with `@client` — hydrated client-side by Jaspr's `ClientApp`
- Renders `Component.fragment([])` on server (invisible)
- On client (`initState` with `kIsWeb` guard):
  1. Queries `.toc-link[data-toc-id]` elements via `web.document.querySelectorAll()`
  2. Collects matching heading elements by ID
  3. Creates `IntersectionObserver` with `rootMargin: '-64px 0px -80% 0px'`
  4. Toggles `.active` class on corresponding TOC link
  5. Fallback: activates last heading above viewport when none intersecting
- No constructor params (serialization-free) — same pattern as `SidebarToggle`
- Uses `universal_web` for DOM access (`web.document`, `IntersectionObserver`)
- `dispose()` disconnects the observer

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
Markdown(content: context.project.changelog?.raw ?? '', classes: 'changelog-content')
```

- Uses `MarkdownProcessor` (pure Dart, no dart:io — works in browser)
- Supports embedded components via `ComponentRegistry`
- Default `classes: 'docs-content'`

### Text (`content/text_widget.dart`)

Flutter-like `Text` widget. Renders `<span>` with optional `TextStyle` inline styles.

```dart
Text('Hello, world!')
Text('Bold text', style: TextStyle(fontWeight: 700))
```

- Shadows Jaspr's `Text` class (hidden from barrel export)
- `data` (`String`) — the text to display
- `style` (`TextStyle?`) — optional inline styles via `toCssProperties()`

## Branding

### Logo (`branding/logo.dart`)

```dart
Logo(image: context.project.assets.logo.logo_webp(alt: 'Logo'), title: 'My Project')
```

- `image` (`Component?`), `title` (`String?`), `href` (`String`, default `"/"`)
- At least one of `image`/`title` required (assert)
- CSS: `.logo` (inline-flex, no link decoration), `.logo-image` (1.75rem), `.logo-title` (1.25rem semibold)

### Copyright / BuiltWithDocuDart (`branding/`)

- `Copyright(text:, year:)` — renders `<p>` with `© {year} {text}`. `year` defaults to `DateTime.now().year`
- `BuiltWithDocuDart(prefix:, label:, href:)` — renders `<p class="built-with">` with link. Defaults: `'Built with'`, `'DocuDart'`, pub.dev URL

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
- Structure: `Column(.apply(minHeight: 100vh)) > [skip-link, header?, Row(.apply(flex+height+maxWidth+margin)) > [sidebar?, body?], footer?, sidebar-backdrop?]`
- Layout does NOT render the mobile menu button — that's the user's responsibility in their Header component using `context.screen` and `SidebarToggle`
- When sidebar is present: renders `.sidebar-backdrop` (full-screen overlay for closing drawer)
- Body: `.site-main` CSS class; inline flex styles
- Row always spans full viewport width (maxWidth 100%); header/footer also full-width (no max-width constraint)
- Generated `LayoutDelegate` delegates to this or to `config.layoutBuilder`
- Includes skip-to-content link (`<a class="skip-to-content" href="#main-content">`)

### Row / Column (`layout/row.dart`)

Flutter-like flex containers. Each renders a single `<div>` with inline flexbox styles. No CSS class hooks — all styling is inline.

### Expanded / Flexible (`layout/expanded.dart`, `layout/flexible.dart`)

Flutter-like flex control primitives. Use `.apply()` to merge flex styles directly onto the child — no wrapper `<div>`. `Expanded` delegates to `Flexible(fit: FlexFit.tight)`.

**Important**: Do not chain `.apply()` on `Expanded` or `Flexible`. Combine flex styles with other styles in a single `.apply()` call.

### Spacer (`layout/spacer.dart`)

Empty `<div>` with flex — cannot use `.apply()` (no child to apply to). No CSS class.

### SizedBox (`layout/sized_box.dart`)

With child: uses `.apply()` to merge width/height onto child (no wrapper). Without child: renders empty `<div>` as spacer.

### Padding (`layout/padding.dart`) + EdgeInsets (`layout/edge_insets.dart`)

Flutter-like padding component. Uses `.apply()` to merge padding directly onto the child — no wrapper `<div>`. Shadows Jaspr's `Padding` typedef (which is `Spacing`).

**Important**: Do not chain `.apply()` on `Padding`. Combine all styles in a single `.apply()` on the child instead.

```dart
Padding(padding: EdgeInsets.all(16), child: Text('Hello'))
Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: child)
```

- `EdgeInsets` mirrors Flutter: `.all()`, `.symmetric()`, `.only()`, `.fromLTRB()`, `.zero`
- Converts to Jaspr's `Spacing` internally via `toSpacing()`
- `docudart.dart` hides Jaspr's `Padding` typedef — users who need raw `Spacing` import `package:jaspr/dom.dart`

### Container (`layout/container.dart`) + BoxDecoration (`layout/box_decoration.dart`)

Flutter-like container with `width`, `height`, `padding`, `margin`, `color`, `decoration`, `alignment`, `constraints`.

```dart
Container(width: 200, padding: EdgeInsets.all(16), decoration: BoxDecoration(
  color: 0xFFF5F5F5, borderRadius: BorderRadius.circular(8),
), child: child)
```

- Supporting classes: `BoxDecoration`, `BorderRadius`, `Border`, `BorderSide`, `BoxShadow`, `Alignment`, `BoxConstraints`
- `docudart.dart` hides Jaspr's `Border`, `BorderSide`, `BorderRadius`, `BoxShadow` to avoid conflicts

### Center (`layout/center.dart`)

Shorthand for flex centering. Renders `div` with `display: flex; justify-content: center; align-items: center;`.

### Wrap (`layout/wrap.dart`)

Wrapping flow layout. Renders `div` with `flex-wrap: wrap` and optional `spacing`/`runSpacing`.

### Divider (`layout/divider.dart`)

Horizontal line. Renders `<hr>` with optional `height`, `thickness`, `color`, `indent`, `endIndent`.

### Card (`layout/card.dart`)

Material card with `.card` CSS class. Optional `elevation`, `borderRadius`, `color` overrides.

### Badge (`layout/badge.dart`)

Inline status label with `label`, `color`, `textColor`. Pill-shaped with inline styles.

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

### Tooltip (`interaction/tooltip.dart`)

Wraps a child with native browser tooltip via HTML `title` attribute.

```dart
Tooltip(message: 'Delete this item', child: IconButton(icon: Icon(Icons.delete)))
```

- `message` (`String`) — tooltip text
- `child` (`Component`) — the wrapped widget
- Uses DocuDart's `.apply()` extension to merge `title` attribute onto child

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
- `offset` (`double`) — slide distance in percent (default 100%)
- `trigger` (`String?`) — CSS selector; when `document.querySelector(trigger)` matches, `data-slide-active` is set and child slides to natural position
- `classes` (`String?`) — additional CSS classes
- Uses Jaspr's typed `Transform.translate()` and `Transition()` for inline styles
- JS `initSlideTransitions()` in `theme.js` observes class changes on `<body>`/`<html>` to toggle `data-slide-active`

## Providers

### ProjectProvider (`providers/project_provider.dart`)

`InheritedComponent` providing `Project` data via the component tree.

- Generated `app.dart` wraps Router with `ProjectProvider` and `ThemeProvider`
- Extension `ProjectContext` on `BuildContext` adds `.project` getter
- Usage: `context.project.pubspec.name`, `context.project.docs`

### ThemeProvider (`providers/theme_provider.dart`)

`InheritedComponent` providing `Theme` data via the component tree.

- Generated `app.dart` wraps Router: `ProjectProvider` → `Builder` → `ThemeProvider` → `Router`
- The `Builder` gets a context with `ProjectProvider`, then calls `configure(context)` to get the `Config.theme`
- Extension `ThemeContext` on `BuildContext` adds `.theme` getter
- Falls back to `Theme.classic()` if no `ThemeProvider` is found
- Usage: `context.theme.sidebarTheme`, `context.theme.cardTheme`, `context.theme.buttonTheme`

## User-Owned Components (generated by ProjectGenerator)

These live in the user's `components/` directory, not in the library:

- **Header**: `Header(leading:, links:, trailing:, showSidebarToggle:)` → `header > Column(crossAxisAlignment: .stretch)` with two rows: main row (`Row` with logo/hamburger/spacer/desktop-links/trailing, `.apply(classes: 'header-main-row')`) + mobile nav row (`Row(...).apply(styles: combined padding+overflow)`, only on mobile/tablet via `context.screen.maybeWhen`). Uses `?context.screen.maybeWhen(mobile:, tablet:)` to show `SidebarToggle()` on mobile/tablet.
- **Footer**: `Footer(leading:, center:, trailing:)` → `footer` with `context.screen.when()`: `Row(mainAxisAlignment: .spaceBetween)` on desktop, `Column(spacing: 1.5.rem)` on mobile/tablet
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
- `classes` takes `String` (space-separated), NOT `List<String>`
