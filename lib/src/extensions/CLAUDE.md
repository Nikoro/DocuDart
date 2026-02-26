# Extensions

Utility extensions re-exported via `docudart.dart`. Barrel: `extensions.dart`.

## `.let()` (`object_extensions.dart`)

Kotlin-style null-safe scoping on `T?`. If receiver is null, returns null; otherwise applies block.

```dart
final name = user?.name.let((n) => 'Hello, $n');
```

- Extension name: `OptionalAnyObjectExtensions` — users can `hide` it to avoid conflicts with their own `.let()`

## `.apply()` (`component_extensions.dart`)

Merges element properties onto a component's root element **without adding a wrapper div**. Uses Jaspr's `Component.wrapElement()`.

```dart
myComponent.apply(
  id: 'main',
  classes: 'landing-page',
  styles: Styles(maxWidth: 800.px),
  attributes: {'data-page': 'home'},
  events: {'click': handler},
)
```

- All parameters optional: `id`, `classes`, `styles`, `attributes`, `events`
- Critical for the responsive template pattern: `Padding(...).apply(styles: Styles(overflow: ...))`

## Screen (`screen_extension.dart`)

CSS-based responsive rendering. All variants are rendered to DOM; CSS media queries control visibility via `display: contents` / `display: none`.

### Breakpoints

| Name | Range | CSS class |
|------|-------|-----------|
| Mobile | 0–768px | `.screen-mobile` |
| Tablet | 769–1024px | `.screen-tablet` |
| Desktop | 1025px+ | `.screen-desktop` |

### `when()` — all three required

```dart
context.screen.when(
  mobile: () => MobileNav(),
  tablet: () => TabletNav(),
  desktop: () => DesktopNav(),
)
```

Returns `Component`. Renders: `div[display:contents] > [div.screen-mobile, div.screen-tablet, div.screen-desktop]`.

### `maybeWhen()` — optional callbacks

```dart
// With orElse fallback:
context.screen.maybeWhen(
  mobile: () => HamburgerMenu(),
  orElse: () => FullNav(),
)

// Without orElse — returns Component? (use ? prefix in children lists):
?context.screen.maybeWhen(
  mobile: () => SidebarToggle(),
  tablet: () => SidebarToggle(),
)
```

- Unspecified breakpoints with no `orElse` produce no DOM for that breakpoint
- Returns `null` if all callbacks are null and no `orElse`

### DOM Structure Gotcha

`maybeWhen` wraps children in `div[display:contents] > div.screen-mobile > [content]`. The `display:contents` wrapper is layout-invisible but **visible to CSS selectors** like `:last-child`, `:first-child`. This means CSS selectors targeting direct children of a parent won't match the inner content — use component-level styling (`.apply()`, `Padding`) instead of CSS selector hacks.

### Access

Extension `ScreenContext` on `BuildContext` provides `context.screen` getter (returns `const Screen()`).
