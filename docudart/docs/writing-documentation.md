---
title: Writing Documentation
sidebar_position: 3
---

# Writing Documentation

Documentation pages are Markdown files in the `docs/` directory. Each file can include YAML frontmatter for metadata and configuration.

## Frontmatter

Add YAML frontmatter between `---` delimiters at the top of your markdown file:

```yaml
---
title: My Page Title
description: A brief description for SEO
sidebar_position: 3
---
```

### Available fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | `String` | Page title (browser tab, sidebar) |
| `description` | `String` | SEO meta description and Open Graph description |
| `sidebar_position` | `int` | Sort order in sidebar (lower = higher) |
| `sidebar_title` | `String` | Override the title shown in sidebar |
| `sidebar` | `bool` | Set to `false` to hide from sidebar |
| `image` | `String` | Open Graph image path (relative to assets/) |
| `canonical` | `String` | Override canonical URL |
| `no_index` | `bool` | Add `noindex` robots meta tag |
| `tags` | `List<String>` | Page tags for categorization |
| `slug` | `String` | Custom URL slug override |

## Sidebar ordering

Pages and categories are ordered by these rules (in priority order):

1. **`sidebar_position` frontmatter** — explicitly set the position
2. **Numeric filename prefix** — `01-guides/`, `02-advanced/`
3. **Special filenames** — `index.md` and `intro.md` default to position 0
4. **Default** — pages without a position default to 999

### Expandable categories

Append `_expanded` to a folder name to make it start open in the sidebar:

```
docs/
  01-guides_expanded/    # Starts open, displays as "Guides"
    components.md
    theming.md
  02-advanced/           # Starts collapsed, displays as "Advanced"
    deployment/
      github-pages.md
```

The `_expanded` suffix is stripped from the display name and URL.

## Markdown features

DocuDart supports standard GitHub-flavored Markdown:

- Headings (`#` through `######`)
- Bold, italic, strikethrough
- Links and images
- Code blocks with syntax highlighting
- Tables
- Ordered and unordered lists
- Blockquotes
- Horizontal rules

## Syntax highlighting

Code blocks are highlighted at build time using [Opal](https://pub.dev/packages/opal), the same syntax highlighting engine used by dart.dev.

Specify the language after the opening backticks:

````markdown
```dart
void main() {
  print('Hello, DocuDart!');
}
```
````

### Supported languages

Opal supports 18 languages including Dart, JavaScript, TypeScript, Python, JSON, YAML, HTML, CSS, Bash, SQL, Go, Rust, Java, Kotlin, Swift, C, C++, and XML.

Unsupported languages render as plain text without highlighting.

## Heading anchors

Headings automatically get anchor IDs for linking. The `## My Section` heading generates the anchor `#my-section`. Unicode characters are supported.

A table of contents is automatically generated from page headings and displayed in the right sidebar on desktop.

## Embedded components

You can embed custom components directly in markdown using an MDX-like syntax:

```markdown
<Callout type="warning">
This is a warning message.
</Callout>

<Tabs>
<Tab label="Dart">Dart code here</Tab>
<Tab label="JavaScript">JS code here</Tab>
</Tabs>
```

Built-in embeddable components: `Callout`, `Tabs`, `Tab`, `CodeBlock`, `Card`, `CardGrid`.

### Component props

Props support three formats:

- String: `prop="value"`
- Expression: `prop={expression}`
- Plain: `prop=value`
