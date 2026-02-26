# Services

Infrastructure services used by CLI commands. Not user-facing — internal to the build/serve pipeline.

## Files

| File | Class | Purpose |
|------|-------|---------|
| `workspace_resolver.dart` | `WorkspaceResolver` | Auto-detects the website directory for build/serve |
| `package_resolver.dart` | `PackageResolver` | Resolves docudart package path via `Isolate.resolvePackageUri` |
| `file_watcher.dart` | `DocuDartFileWatcher` | Watches user files for hot reload during `docudart serve` |

## WorkspaceResolver

Static `resolve([workingDirectory])` method. Returns the absolute path to the website directory, or `null`.

### Search Strategy

1. If cwd IS the website dir (has `config.dart` + `pubspec.yaml`) → use cwd
2. If cwd has a `docudart/` subdirectory with `config.dart` + `pubspec.yaml` → use that
3. Legacy: if cwd has `config.dart` directly (old-style flat project) → use cwd

### Example Project Gotcha

The `example/` directory has both old-style (flat: `config.dart` + `pubspec.yaml` at root) and new-style (`docudart/` subdirectory). The resolver matches old-style first (step 1), so `_copyUserFiles()` copies from `example/components/` not `example/docudart/components/`. Both locations must be kept in sync.

## PackageResolver

Resolves the docudart package installation path for generating `pubspec.yaml` path dependencies.

- `resolveDocudartPath()` → absolute path to package root (via `Isolate.resolvePackageUri`)
- `relativePathTo(fromDir)` → relative path from a given directory to the package root

## DocuDartFileWatcher

Watches user files during `docudart serve` and triggers site regeneration on changes.

### Watched Paths

- `docs/` directory (markdown files)
- `assets/` directory (images, etc.)
- `versions/` directory (if versioning enabled)
- Root-level `.dart` files (config.dart, labels.dart, etc.)
- `components/` directory
- `pages/` directory
- Parent project's `pubspec.yaml` and `CHANGELOG.md`

### Behavior

- 500ms debounce on file changes
- Pending-regeneration queue: if a change arrives during regeneration, queues one more run
- Filters by extension: `.md`, `.dart`, `.yaml`, `.yml`, image formats (`.png`, `.jpg`, `.svg`, `.webp`, etc.)
- Uses `package:watcher` (`DirectoryWatcher` for dirs, `FileWatcher` for individual files)
