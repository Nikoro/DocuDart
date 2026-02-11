# CLI

Command-line interface for DocuDart. Entry point: `bin/docudart.dart`.

## Commands

### `docudart create [name]`

1. Validates folder name (`^[a-z][a-z0-9_]*$`, default: `'docudart'`)
2. Checks for existing `<name>/config.dart`
3. `ProjectGenerator.generate(folderName: name)` creates the project:
   - Loads pubspec.yaml for name, description, repository
   - HEAD request to pub.dev for package existence (5s timeout)
   - Resolves lint dependency from parent's pubspec.yaml
   - Generates config.dart, components/, pages/, docs/, labels.dart, assets/
   - If `CHANGELOG.md` exists: generates changelog page + header link
4. Runs `dart pub get` then `dart format .`

### `docudart build`

1. `WorkspaceResolver.resolve()` finds the website directory
2. `ConfigLoader.load(websiteDir)` + `loadParentPubspec()` + `loadParentChangelog()`
3. `SiteGenerator.generate()` creates managed Jaspr project in `.dart_tool/docudart/`
4. Runs `dart run jaspr build`
5. Copies output to `build/web/` (or `--output`)

### `docudart serve`

Same as build steps 1-3, then:

1. Starts `DocuDartFileWatcher` (watches: docs/, assets/, root `.dart` files, components/, pages/, parent pubspec.yaml, CHANGELOG.md)
2. Runs `dart run jaspr serve`
3. On file change: debounce 500ms -> `generate(fullClean: false)` -> browser auto-refreshes

### `docudart version` / `--version`

Detects global vs local install, checks pub.dev/GitHub for updates, prints upgrade suggestion.

### `docudart update`

Detects installation source (`hosted` vs `git`) and runs appropriate `dart pub global activate`.

## Services

### WorkspaceResolver (`services/workspace_resolver.dart`)

Auto-detects the website directory for build/serve commands.

- Checks if cwd IS the project dir (has config.dart + pubspec.yaml)
- Checks for `docudart/` subdirectory
- Legacy: supports old-style flat structure

### PackageResolver (`services/package_resolver.dart`)

Resolves docudart package path via `Isolate.resolvePackageUri`. Used for path dependency in generated pubspec.yaml.

### DocuDartFileWatcher (`services/file_watcher.dart`)

Watches user files for hot reload during `docudart serve`.

- Debounce + pending-regeneration queue for rapid edits
- Skips `assets.dart` inside assets/ to prevent infinite rebuild loops

## Live Reload

During `docudart serve`, a `live-reload.js` script is injected and `live-reload-version.txt` is written. The JS polls the version file every 1s. After regeneration, version is bumped and browser auto-refreshes. Only active during serve mode (`serveMode: true`).

## Log Filtering

Jaspr's internal build daemon produces transient SocketException errors during reload. `ServeCommand._shouldShowLog()` suppresses these while preserving user-facing output. Process output is piped (not `inheritStdio`) and filtered line-by-line.

## Command Pattern

```dart
class MyCommand extends Command<int> {
  @override
  Future<int> run() async {
    final websiteDir = WorkspaceResolver.resolve();
    if (websiteDir == null) {
      CliPrinter.exception(DocuDartErrors.configNotFound());
      return 1;
    }
    final config = await ConfigLoader.load(websiteDir);
    // ...
    return 0;
  }
}
```

## Error Handling

- `CliPrinter` in `errors.dart` — `success()`, `info()`, `warning()`, `error()` methods with colored output
- `DocuDartException` — typed exceptions for user-facing error messages
- All generators use `CliPrinter` (not bare `print()`)

## Version System

- `InstallationSource` — detects `git` vs `hosted` from pub-cache
- `VersionChecker` — pub.dev API + GitHub releases API
- `VersionPrinter` — shared by `--version` flag and `version` command
