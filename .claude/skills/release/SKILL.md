---
name: release
description: Prepare a release by bumping the version in pubspec.yaml, generating a changelog entry from commits, creating a git tag, and pushing. Validates everything before tagging.
---

When this skill is invoked with optional `$ARGUMENTS`:

## Steps

1. **Parse user input** — extract from `$ARGUMENTS`:
   - **Explicit version** (e.g., `/release 0.3.0`) — use this exact version
   - **Bump keyword** (`major`, `minor`, or `patch`) — apply this bump to the current version
   - **Empty** — auto-determine the bump type from commit analysis (step 4)

2. **Pre-flight checks** — run these before doing anything else. If any fail, **abort immediately** with a clear error message:
   1. **Clean working tree**: Run `git status --porcelain`. If there is any output, abort — tell the user to commit or stash their changes first.
   2. **On main branch**: Run `git branch --show-current`. If the result is not `main`, abort — tell the user to switch to `main`.
   3. **In sync with remote**: Run `git fetch origin main` then compare `git rev-parse HEAD` with `git rev-parse origin/main`. If they differ, abort — tell the user to pull or push first.
   4. **No duplicate tag**: No existing git tag `v<new_version>` (skip if version not yet determined).

3. **Quality gates** — ensure the package is releasable. If any fail, **abort** and ask the user to fix the issues first:
   1. `dart analyze` — must produce **zero** issues (errors, warnings, or infos)
   2. `dart test` — all tests must pass

4. **Analyze commits & determine version**:
   1. Get the latest git tag: `git describe --tags --abbrev=0`
   2. Get current version from `pubspec.yaml` (the `version:` field)
   3. List all commits since the latest tag: `git log <latest_tag>..HEAD --oneline`
   4. Parse each commit using Conventional Commits format (`type(scope): description`):
      - Extract the **type** (e.g., `feat`, `fix`, `refactor`)
      - Extract the **scope** if present
      - Extract the **description**
      - Check for breaking changes: `BREAKING CHANGE:` in body/footer or `!` after type (e.g., `feat!:`)
   5. **Determine version bump** (unless user provided explicit version or keyword):
      - Any breaking change → **major** bump
      - Any `feat` commit → **minor** bump
      - Only `fix`, `refactor`, `style`, `perf`, `docs` → **patch** bump
      - No user-facing commits (only `chore`, `test`, `ci`, `build`) → ask whether to proceed with a **patch** release or abort
   6. If user provided a bump keyword, apply it to the current version
   7. If user provided an explicit version, validate it is higher than the current version
   8. Verify no existing git tag `v<new_version>` (if not already checked in step 2)

5. **Generate changelog entry** — map commits to [Keep a Changelog](https://keepachangelog.com/) categories:

   | Commit type | Changelog category | Include? |
   |-------------|--------------------|----------|
   | `feat`      | **Added**          | Yes      |
   | `fix`       | **Fixed**          | Yes      |
   | `refactor`  | **Changed**        | Yes      |
   | `style`     | **Changed**        | Yes      |
   | `perf`      | **Changed**        | Yes      |
   | `docs`      | —                  | Skip     |
   | `chore`     | —                  | Skip     |
   | `test`      | —                  | Skip     |
   | `ci`        | —                  | Skip     |
   | `build`     | —                  | Skip     |

   Rules:
   - **Only include categories that have actual entries.** Do NOT add empty categories.
   - Write **human-friendly descriptions**, not raw commit messages.
   - Group related commits when appropriate (e.g., multiple fixes for the same feature).

6. **Review & confirm** — present a summary before making any file changes:

   ```
   Release Summary
   ───────────────
   Current version: A.B.C
   New version:     X.Y.Z (BUMP_TYPE bump)

   Commits since last release: N total (M user-facing, K skipped)

   Changelog preview:
   ──────────────────
   ## X.Y.Z - YYYY-MM-DD

   ### Added
   - ...

   ### Fixed
   - ...
   ```

   Ask: "Does this release summary look correct? Should I proceed?"
   Allow the user to request edits to the changelog content before proceeding.

7. **Update files**:
   1. **`pubspec.yaml`**: Replace `version: <old>` with `version: <new>`
   2. **`CHANGELOG.md`**: Replace `## Unreleased` with `## Unreleased\n\n## <new_version> - <YYYY-MM-DD>` followed by the generated changelog entry. This leaves an empty Unreleased section and adds the new version below it.

8. **Commit & tag**:
   - `git add pubspec.yaml CHANGELOG.md`
   - `git commit -m "release: v<new_version>"`
   - `git tag -a v<new_version> -m "Release v<new_version>"`

9. **Push** — **pushing the tag triggers the `release.yaml` CI workflow, which publishes to pub.dev. This is irreversible.**
   - Ask: "Ready to push? This will trigger pub.dev publishing and create a GitHub release."
   - If confirmed: `git push origin main --follow-tags`
   - After pushing, inform the user:
     - The `release.yaml` workflow has been triggered
     - It will: validate the version, run checks, publish to pub.dev, and create a GitHub release
     - They can monitor progress at: `https://github.com/Nikoro/DocuDart/actions`
   - If something goes wrong after push, provide rollback instructions:
     ```bash
     git push origin :refs/tags/vX.Y.Z   # delete remote tag
     git tag -d vX.Y.Z                    # delete local tag
     git revert HEAD                       # revert release commit
     git push origin main
     ```
     Note: if the package was already published to pub.dev, the version cannot be unpublished.

10. **Report**:
    - Print the new version, tag name, and changelog URL
