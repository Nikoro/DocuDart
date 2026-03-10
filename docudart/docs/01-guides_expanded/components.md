---
title: Components
sidebar_position: 2
---

# Components

DocuDart provides a Flutter-like component API. You write familiar Dart code; DocuDart generates lean HTML/CSS.

## Layout components

### Row and Column

Flex containers that mirror Flutter:

```dart
Row(
  mainAxisAlignment: .spaceBetween,
  children: [Text('Left'), Text('Right')],
)

Column(
  crossAxisAlignment: .stretch,
  spacing: 1.rem,
  children: [header, content, footer],
)
```

### Container

Flutter-like container with decoration:

```dart
Container(
  width: 200,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: 0xFFF5F5F5,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Hello'),
)
```

### Padding

Merges padding directly onto the child element (no wrapper `<div>`):

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  child: Text('Padded content'),
)
```

`EdgeInsets` mirrors Flutter: `.all()`, `.symmetric()`, `.only()`, `.fromLTRB()`, `.zero`.

### Other layout components

- **`Expanded`** / **`Flexible`** — Flex control (merges styles onto child)
- **`SizedBox`** — Fixed dimensions (with child: applies styles; without: empty spacer)
- **`Spacer`** — Flexible empty space
- **`Center`** — Flex centering shorthand
- **`Wrap`** — Wrapping flow layout with `spacing` and `runSpacing`
- **`Divider`** — Horizontal `<hr>` with optional styling
- **`Card`** — Material card with elevation, border radius, hover effects
- **`Badge`** — Inline pill-shaped label

## Content components

### Text

```dart
Text('Hello, world!')
Text('Bold text', style: TextStyle(fontWeight: 700))
```

### Markdown

Renders markdown content at runtime:

```dart
Markdown(content: '# Hello\n\nSome **bold** text.')
```

## Interaction components

### IconButton

```dart
IconButton(
  icon: Icon(MaterialSymbols.menu),
  tooltip: 'Open menu',
  onPressed: () { /* ... */ },
)
```

### Tooltip

```dart
Tooltip(message: 'Delete this item', child: myWidget)
```

## Animation

### SlideTransition

CSS-based slide animation with a trigger:

```dart
SlideTransition(
  direction: SlideDirection.left,
  trigger: 'body.sidebar-open',
  duration: Duration(milliseconds: 300),
  child: sidebar,
)
```

## The `.apply()` extension

Merge element properties onto a component without adding a wrapper `<div>`:

```dart
myComponent.apply(
  id: 'main',
  classes: 'landing-page',
  styles: Styles(maxWidth: 800.px),
  attributes: {'data-page': 'home'},
)
```

### Shadowing constraint

Primitive components (`Padding`, `Flexible`, `Expanded`, `SizedBox` with child) use `.apply()` internally. Chaining `.apply()` on them will shadow the inner call — only the innermost applies.

```dart
// BAD: outer .apply() is lost
Padding(padding: EdgeInsets.all(16), child: Row(...))
    .apply(styles: Styles(overflow: Overflow.auto))

// GOOD: combine styles in one .apply()
Row(...).apply(styles: Styles(
  padding: EdgeInsets.all(16).toSpacing(),
  overflow: Overflow.auto,
))
```

**Safe to chain `.apply()` on**: `Row`, `Column`, `Container`, `Center`, `Wrap`, `Card`, `Text`, `Logo`, `Link`.

## Embedded components in Markdown

Use MDX-like syntax to embed components in documentation:

```markdown
<Callout type="warning">
This is a warning message.
</Callout>

<Tabs>
<Tab label="Dart">Dart example</Tab>
<Tab label="Python">Python example</Tab>
</Tabs>

<CardGrid>
<Card title="Feature A">Description</Card>
<Card title="Feature B">Description</Card>
</CardGrid>
```

Built-in embeddable components: `Callout`, `Tabs`, `Tab`, `CodeBlock`, `Card`, `CardGrid`.
