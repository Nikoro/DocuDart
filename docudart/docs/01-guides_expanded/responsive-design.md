---
title: Responsive Design
sidebar_position: 4
---

# Responsive Design

DocuDart provides CSS-based responsive rendering through `context.screen`. All variants are rendered to the DOM; CSS media queries control visibility.

## Breakpoints

| Name | Range | CSS class |
|------|-------|-----------|
| Mobile | 0–768px | `.screen-mobile` |
| Tablet | 769–1024px | `.screen-tablet` |
| Desktop | 1025px+ | `.screen-desktop` |

## `when()` — all breakpoints required

```dart
context.screen.when(
  mobile: () => MobileNav(),
  tablet: () => TabletNav(),
  desktop: () => DesktopNav(),
)
```

Returns a `Component`. All three callbacks are required.

## `maybeWhen()` — optional breakpoints

```dart
// With fallback
context.screen.maybeWhen(
  mobile: () => HamburgerMenu(),
  orElse: () => FullNav(),
)

// Without fallback — returns Component?
?context.screen.maybeWhen(
  mobile: () => SidebarToggle(),
  tablet: () => SidebarToggle(),
)
```

Use the `?` prefix when including in a `children` list to conditionally render without leaving gaps.

Unspecified breakpoints with no `orElse` produce no DOM for that breakpoint.

## How it works

The `screen` extension renders all variants into the DOM and wraps each in a `<div>` with the matching CSS class (`.screen-mobile`, `.screen-tablet`, `.screen-desktop`). CSS media queries hide non-matching variants using `display: none` and show the active one with `display: contents` (layout-invisible wrapper).

This is SSR-compatible — all variants are server-rendered, so the page displays correctly before JavaScript loads.

## Example: responsive header

```dart
Header(
  leading: Logo(title: 'My Project'),
  links: [
    .path('/docs', label: 'Docs'),
    ?context.screen.maybeWhen(
      mobile: () => SidebarToggle(),
      tablet: () => SidebarToggle(),
    ),
  ],
)
```
