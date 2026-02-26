# Processing

Content processing pipeline. Transforms raw docs and README files into structured data for site generation.

## Files

| File | Class | Purpose |
|------|-------|---------|
| `content_processor.dart` | `ContentProcessor` | Processes all docs/ markdown files into `DocPage`/`DocFolder` tree |
| `readme_parser.dart` | `ReadmeParser` | Splits README.md into sections for seeding initial docs |
| `version_manager.dart` | `VersionManager` | Manages versioned documentation sets |

## ContentProcessor

Core processor called by `SiteGenerator`. Takes `Config`, creates `MarkdownProcessor` with `OpalHighlighter` (using theme's code themes).

### Pipeline

```
docs/ directory
  ├─ processAll() → recursively walks docs/
  │   ├─ For each .md file: MarkdownProcessor.process() → DocPage
  │   ├─ For each subdirectory: recurse → DocFolder
  │   └─ Sort by order (numeric prefix or frontmatter sidebarPosition)
  └─ Returns: (List<DocPage>, DocFolder)
```

### URL Generation

`_generateUrlPath(relativePath)`:
- Strips `.md` extension
- Removes `_expanded` suffix from path segments
- Removes numeric prefixes (`01-`, `02_`, etc.)
- Handles `index.md` → parent path (not `/docs/.../index`)
- Prefixes with `/docs/`

### Ordering

`_extractOrder(filename)`:
- Numeric prefix: `01-getting-started` → 1
- `index`/`intro`/`introduction` → 0
- Default: 999
- Frontmatter `sidebar_position` overrides filename-based order

### Folder Name

`_folderName(relativePath)`: Strips `_expanded` suffix and numeric prefix, converts `kebab-case`/`snake_case` to Title Case.

## ReadmeParser

Static utility. Splits a README.md into `ReadmeSection` objects for seeding initial documentation via `docudart create`.

- Splits on `## ` headings (level 2) — H3-H6 are kept within their parent section
- H1 is treated as project title (skipped)
- Content before first heading → "Introduction" section (filename: `index`)
- Skips: license, contributing, contributors, authors, acknowledgements, changelog, support, sponsors, backers
- Strips badge lines (shield.io patterns) from introduction
- Each section gets: `title`, `content`, `level`, `filename`, `position`

## VersionManager

Manages versioned documentation for multi-version sites.

### Directory Structure

```
docs/           # Current/latest version
versions/
  v1/           # Older version
  v2/           # Another version
```

### Behavior

- Controlled by `Config.versioning` (`VersioningConfig`)
- When disabled (default): processes `docs/` as single "latest" version
- When enabled: processes each version directory with its own `ContentProcessor`
- Latest version uses `/docs/...` URLs; older versions use `/v1/docs/...`
- Default version can differ from latest (configurable)
- Provides `getVersionSwitcherItems()` for UI dropdown data
