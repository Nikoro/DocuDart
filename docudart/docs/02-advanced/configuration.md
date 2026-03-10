---
title: Advanced Configuration
sidebar_position: 1
---

# Advanced Configuration

## Site URL and SEO

Setting `siteUrl` enables a suite of SEO features:

```dart
siteUrl: 'https://my-docs.dev',
```

When set, DocuDart generates:

- **Canonical URLs** — `<link rel="canonical">` on every page
- **Open Graph tags** — `og:title`, `og:description`, `og:url`, `og:image`
- **JSON-LD structured data** — `Article` schema on doc pages, `WebSite` schema on the home page
- **sitemap.xml** — lists all pages for search engine crawlers
- **robots.txt** — references the sitemap

## Custom doc page layout

Use `docsBuilder` to replace the default doc page body (content + table of contents):

```dart
Config configure(BuildContext context) => Config(
  docsBuilder: (page) => Row(
    children: [
      Expanded(child: page.content),
      // Custom sidebar instead of default TOC
      MyCustomSidebar(title: page.title, toc: page.toc),
    ],
  ),
);
```

The `DocPageInfo` parameter provides:

| Field | Type | Description |
|-------|------|-------------|
| `content` | `Component` | Rendered HTML content |
| `toc` | `List<TocEntry>` | Table of contents entries |
| `title` | `String` | Page title from frontmatter |
| `urlPath` | `String` | Page URL path |
| `description` | `String?` | Page description |
| `tags` | `List<String>` | Page tags |

When `docsBuilder` is `null` (default), DocuDart renders the content with a table of contents sidebar and scroll spy on desktop.

## Custom layout

Use `layoutBuilder` to fully replace the default page layout:

```dart
Config configure(BuildContext context) => Config(
  layoutBuilder: ({header, footer, sidebar, body}) => Column(
    children: [
      ?header,
      Row(children: [
        ?sidebar,
        ?body.let((b) => Expanded(child: b)),
      ]),
      ?footer,
    ],
  ),
);
```

The function receives the header, footer, sidebar, and body as optional `Component?` values, giving you full control over their arrangement.
