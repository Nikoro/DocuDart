---
name: release
description: Prepare a release by bumping the version in pubspec.yaml, moving Unreleased changelog entries to a new version section, creating a git tag, and pushing. Validates everything before tagging.
---

When this skill is invoked with an optional version argument (e.g., `/release 0.1.0`):

## Steps

1. **Determine the new version**:
   - If an argument is provided (e.g., `/release 0.1.0`), use it as the new version
   - If no argument, read the current version from `pubspec.yaml` and ask the user which bump to apply:
     - **patch** (0.0.1 -> 0.0.2)
     - **minor** (0.0.1 -> 0.1.0)
     - **major** (0.0.1 -> 1.0.0)

2. **Validate preconditions** (abort with a clear message if any fail):
   - Working tree is clean (`git status --porcelain` is empty)
   - Current branch is `main`
   - `CHANGELOG.md` has an `## Unreleased` section with at least one entry beneath it
   - The new version is greater than the current version
   - No existing git tag `v<new_version>`

3. **Update `pubspec.yaml`**:
   - Replace `version: <old>` with `version: <new>`

4. **Update `CHANGELOG.md`**:
   - Replace `## Unreleased` with `## Unreleased\n\n## <new_version> - <YYYY-MM-DD>`
   - This moves all entries under the new version heading and leaves an empty Unreleased section

5. **Show the diff and ask for confirmation**:
   - Run `git diff` and show it to the user
   - Ask: "Ready to commit and tag v<new_version>?"
   - Only proceed if the user confirms

6. **Commit and tag**:
   - `git add pubspec.yaml CHANGELOG.md`
   - `git commit -m "release: v<new_version>"`
   - `git tag v<new_version>`

7. **Push** (only if user confirms):
   - Ask: "Push to remote (branch + tag)?"
   - If yes: `git push && git push --tags`

8. **Report**:
   - Print the new version, tag name, and changelog URL (if repository is known)
