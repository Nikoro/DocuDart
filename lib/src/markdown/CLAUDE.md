# Markdown

Markdown processing pipeline. Converts `.md` files with YAML frontmatter into highlighted HTML with embedded component support.

## Files

| File | Class | Purpose |
|------|-------|---------|
| `markdown_processor.dart` | `MarkdownProcessor` | Orchestrates the full pipeline: frontmatter → components → HTML → TOC → headings → highlighting |
| `opal_highlighter.dart` | `OpalHighlighter` | Build-time syntax highlighting via `opal` package (same engine as dart.dev) |
| `frontmatter_handler.dart` | `FrontmatterHandler`, `PageMeta` | YAML frontmatter parsing + structured metadata model |
| `component_parser.dart` | `ComponentParser` | MDX-like `<Component prop="value" />` extraction from markdown |

## MarkdownProcessor Pipeline

```
Input: raw markdown string
  1. FrontmatterHandler.parseWithMeta() → (PageMeta, markdown)
  2. ComponentParser.parse() → (content with placeholders, List<EmbeddedComponent>)
  3. markdown package (GitHubWeb extension set, encodeHtml: false) → raw HTML
  3b. _escapeInlineCode() → escape <> in inline `code` (not <pre><code>)
  4. _extractTableOfContents() → List<TocEntry> from h1–h6
  5. _addHeadingIds() → inject id="" attributes on headings
  6. _replaceComponentPlaceholders() → swap placeholders with rendered HTML
  7. OpalHighlighter.highlightHtml() → syntax-highlighted code blocks
Output: ProcessedMarkdown(meta, html, components, tableOfContents)
```

## OpalHighlighter

Tokenizes code blocks at build time. Produces inline-styled `<span>` elements with dual color values for light/dark mode.

```html
<span style="color: rgba(r,g,b,1.0); --dd-dark-color: rgba(r,g,b,1.0);">token</span>
```

- Takes `lightTheme` and `darkTheme` (`CodeTheme` objects) — maps opal `Tag` hierarchy to color pairs
- Dark mode toggled by CSS: `:root[data-theme="dark"] pre.opal span[style] { color: var(--dd-dark-color) !important; }`
- Tag matching walks parent chain via `_matchesRoot()` — opal uses hierarchical tags (e.g., `var` → parent `keyword`)
- Unsupported languages render as plain `<pre class="opal"><code>` without spans
- Regex-based: finds `<pre><code class="language-X">` blocks in HTML string

## FrontmatterHandler

Static utility class. Parses `---` delimited YAML frontmatter.

- `parse(content)` → `FrontmatterResult(data: Map, content: String)`
- `parseWithMeta(content)` → `(PageMeta, String)` — structured metadata
- `generate(data)` → frontmatter string for writing back
- Normalizes CRLF → LF before parsing

### PageMeta Fields

`title`, `description`, `image`, `canonical`, `noIndex`, `sidebarPosition`, `sidebarTitle`, `showInSidebar`, `tags`, `slug`

- `sidebarPosition` overrides filename-based ordering
- `noIndex` → `<meta name="robots" content="noindex">`
- `image` → Open Graph image path
- `canonical` → canonical URL override (auto-generated from `siteUrl` + path when null)

## ComponentParser

Extracts MDX-like component syntax from markdown before markdown-to-HTML conversion.

- Self-closing: `<Component prop="value" />`
- With children: `<Component prop="value">children</Component>`
- Props: `prop="string"`, `prop={expression}`, `prop=plain`
- Replaces components with `<div data-component="___COMPONENT_N___">` placeholders
- Built-in components: `Callout`, `Tabs`, `Tab`, `CodeBlock`, `Card`, `CardGrid`
- Rendered by `ComponentRegistry` (in `components/content/component_registry.dart`)

### Limitations

- No escaped quotes in string props (`prop="value with \" quote"`)
- No nested braces (`prop={{nested}}`)
