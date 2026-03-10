---
title: Customizing Layout
sidebar_position: 5
---

# Customizing Layout

DocuDart's layout is built from four sections: header, sidebar, body, and footer. Each is a component you control through `config.dart`.

## Header

The generated header includes a logo, navigation links, and a theme toggle:

```dart
header: () => Header(
  showSidebarToggle: context.url.contains('/docs'),
  leading: Logo(
    image: context.project.assets.logo.logo_webp(alt: 'Logo'),
    title: 'My Project',
  ),
  links: [
    .path('/docs', label: 'Docs', leading: Icon(MaterialSymbols.docs)),
    .path('/changelog', label: 'Changelog'),
    .url('https://github.com/user/repo', label: 'GitHub',
      leading: Icon(FontAwesomeIcons.github_brand),
      trailing: Icon(MaterialIcons.open_in_new),
    ),
  ],
  trailing: ThemeToggle(
    light: Icon(MaterialIcons.light_mode),
    dark: Icon(MaterialIcons.dark_mode),
  ),
),
```

### Link types

- **`.path('/docs', label: 'Docs')`** — internal link (no external icon)
- **`.url('https://...', label: 'GitHub')`** — external link (opens in new tab with `rel="noopener noreferrer"`)

Both support `leading` and `trailing` icon components.

### Logo

```dart
Logo(
  image: context.project.assets.logo.logo_webp(alt: 'Logo'),
  title: 'My Project',
  href: '/',  // default
)
```

At least one of `image` or `title` is required.

### Theme toggle

```dart
ThemeToggle(
  light: Icon(MaterialIcons.light_mode),
  dark: Icon(MaterialIcons.dark_mode),
  tooltip: 'Toggle theme',  // default
)
```

Both icons are rendered to the DOM; CSS toggles their visibility based on the active theme.

### Sidebar toggle

When `showSidebarToggle` is `true`, the header shows a hamburger menu button on mobile and tablet that opens the sidebar drawer.

## Footer

The generated footer has three sections:

```dart
footer: () => Footer(
  leading: Topics(
    title: 'Topics',
    links: [
      .url('https://pub.dev/packages?q=topic%3Adart', label: '#dart'),
    ],
  ),
  center: Column(children: [
    Copyright(text: 'My Project'),
    BuiltWithDocuDart(),
  ]),
  trailing: Socials(
    links: [
      .url('https://github.com/user', leading: Icon(FontAwesomeIcons.github_brand)),
    ],
  ),
),
```

The footer is responsive — `Row` on desktop, `Column` on mobile/tablet.

## Sidebar

```dart
sidebar: () => context.url.contains('/docs') ? Sidebar() : null,
```

The default `Sidebar` wraps `DefaultSidebar(items: context.project.docs)`, rendering a collapsible navigation tree from your docs directory structure.

- Active page is highlighted with a left border accent
- Collapse state is persisted in localStorage
- Parent categories auto-expand when an active page is inside them
- Hidden on mobile (≤1024px), replaced by a slide-out drawer
