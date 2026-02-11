---
name: improvements
description: Audit the entire DocuDart project for code quality, consistency, test coverage, documentation gaps, and open-source readiness. Produces a prioritized report of actionable findings.
---

# DocuDart Project Audit

You are performing a comprehensive audit of the DocuDart project. Your goal is to find concrete, actionable improvements — not vague suggestions. Every finding must include the specific file path, the issue, and a recommended fix.

## Process

### Step 0: Check for existing plan

**Before doing anything else**, check if `IMPROVEMENT_PLAN.md` already exists in the project root directory.

- **If it exists**: Read it. This file is your source of truth from a previous audit session. Do NOT re-audit from scratch. Instead:
  1. Review which findings are marked `[x]` (completed) and which are `[ ]` (pending)
  2. Resume working on the next pending finding
  3. After completing each finding, update `IMPROVEMENT_PLAN.md` — mark it `[x]` and add a brief note of what was done
  4. Continue until all findings are addressed
  5. When ALL findings are marked `[x]`, ask the user for confirmation before deleting `IMPROVEMENT_PLAN.md`

- **If it does NOT exist**: Proceed with the full audit below (Steps 1-6), then write the plan file.

### Step 1: Audit

1. **Read CLAUDE.md and MEMORY.md** to understand the project architecture and conventions before auditing.
2. **Explore systematically** — read every non-generated Dart file in `lib/src/`, all test files, all configuration files, the README, CHANGELOG, pubspec.yaml, CI workflows, and the example project structure.
3. **Skip generated icon data files** (`lucide_icons.dart`, `material_icons.dart`, `material_symbols.dart`, `tabler_icons.dart`, `fluent_icons.dart`, `font_awesome_icons.dart`, `remix_icons.dart` in `lib/src/icons/`) — they are machine-generated. DO audit the hand-written icon files (`icon.dart`, `helpers.dart`, `icons.dart`).
4. **Audit each category below** in order. For each finding, record the severity, file path, and specific recommendation.
5. **Produce a single structured report** at the end (see Output Format below).

### Step 2: Write `IMPROVEMENT_PLAN.md`

After producing the audit report, **write the complete report to `IMPROVEMENT_PLAN.md` in the project root directory**. This file serves as persistent state across conversation sessions.

Add a checklist prefix to every finding so progress can be tracked:

```
### [ ] [C1] Title
### [ ] [H1] Title
### [x] [H2] Title  ← completed: removed unused import in commit abc123
```

**Rules for `IMPROVEMENT_PLAN.md`**:
- Write it to the project root: `./IMPROVEMENT_PLAN.md`
- Every finding MUST have a `[ ]` or `[x]` checkbox prefix
- When you complete a finding, change `[ ]` to `[x]` and append a brief note of what was done
- NEVER delete this file yourself — only delete it after ALL findings are `[x]` AND the user explicitly confirms deletion
- This file is the single source of truth — if context is lost between sessions, this file tells you exactly where you left off

---

## Audit Categories

Work through these categories in order. For each one, read the relevant files and analyze thoroughly.

### 1. Code Quality & Consistency [High Priority]

**Scope**: Every `.dart` file in `lib/src/` (excluding generated icon data files).

Check for:
- **Naming inconsistencies**: Do file names match their primary class? Are naming conventions consistent across similar files?
- **Import style**: Are imports consistent? (relative vs package imports, ordering)
- **Error handling patterns**: Is error handling consistent across CLI commands, generators, and processors? Are there bare `catch (e)` blocks that swallow errors? Are there `print()` calls that should use `CliPrinter`?
- **Code duplication**: Repeated patterns between `SiteGenerator` and `ProjectGenerator` (file copying, directory creation, pubspec generation). Duplicated string-building logic in template generation methods.
- **Dart idioms**: Are modern Dart features used consistently? (sealed classes, records, pattern matching, null-aware elements, enhanced enums)
- **Dead code**: Unused imports, unreachable branches, unused parameters, methods never called.
- **Magic strings/numbers**: Hardcoded values that should be constants (port numbers, default paths, CSS class names, version strings).
- **Const correctness**: Classes that could use `const` constructors. Fields that should be `final`. Collections that should be unmodifiable.

### 2. Public API Surface [High Priority]

**Scope**: `lib/docudart.dart` (barrel file) and every file it exports.

Check for:
- **Over-exposure**: Are internal implementation details exported that users should never touch? (e.g., `ConfigLoader`, `SiteGenerator`, `ContentProcessor`, `VersionManager` — should these be part of the public API?)
- **Under-exposure**: Are there useful types users might need but that are not exported?
- **API naming**: Are exported class names clear and non-conflicting? Could any names clash with common Dart/Flutter types? (e.g., `Page` is very generic)
- **Documentation on public APIs**: Do all exported classes and methods have doc comments? Are they accurate?
- **Breaking change risk**: Identify public API surfaces likely to change that should perhaps stay hidden behind `src/` imports until stable.

### 3. Test Coverage & Quality [High Priority]

**Scope**: All files in `test/`.

Check for:
- **Missing test coverage**: Which `lib/src/` directories have ZERO test coverage? List them explicitly. Prioritize by importance:
  - CLI commands (`cli/commands/`) — do they handle errors correctly?
  - Generators (`generators/`) — do they produce correct output?
  - Services (`services/`) — do WorkspaceResolver, PackageResolver, FileWatcher work correctly?
  - Components (`components/`) — do they at minimum construct without errors?
- **Test quality**: For each existing test file:
  - Do tests verify meaningful behavior, or just check that constructors work?
  - Are edge cases tested? (empty inputs, null values, malformed data, file-not-found)
  - Are error paths tested?
  - Are there tests that are essentially `expect(x, isNotNull)` without checking the actual value?
- **Missing test utilities**: Would test helpers, fixtures, or mocks reduce duplication?
- **Integration test gap**: Is there any integration test that runs `create → build` end-to-end?

### 4. Folder Structure & Organization [Medium Priority]

**Scope**: Full `lib/src/` directory tree.

Check for:
- **Misplaced files**: Files in directories where they don't logically belong. (e.g., are `DocPage`/`DocFolder` in `content_processor.dart` in `processing/` when they should be in `models/`?)
- **Barrel file gaps**: Missing barrel files (e.g., `models/models.dart`, `cli/cli.dart`) that would simplify imports.
- **Inconsistent nesting depth**: Some directories flat, others deeply nested — is it justified?
- **File size red flags**: Non-generated files over 500 lines that should be split. (Check `site_generator.dart` and `project_generator.dart` especially.)

### 5. Comments & Documentation Accuracy [Medium Priority]

**Scope**: All hand-written `.dart` files in `lib/src/`.

Check for:
- **Stale comments**: Comments describing behavior that no longer matches the code.
- **Misleading doc comments**: Class/method documentation that is inaccurate or incomplete.
- **Missing doc comments**: Public classes, methods, or fields without documentation.
- **TODO/FIXME/HACK comments**: List all of them. Are they still relevant?
- **CLAUDE.md accuracy**: Does the root CLAUDE.md accurately reflect the current codebase? Are there sections that are outdated or describe classes/patterns that no longer exist?
- **Icons CLAUDE.md accuracy**: Does `lib/src/icons/CLAUDE.md` reflect the current state of the icon system?

### 6. Dependency Health [Medium Priority]

**Scope**: `pubspec.yaml`, `pubspec.lock`.

Check for:
- **Unused dependencies**: Are all declared dependencies actually imported somewhere in `lib/`?
- **Missing dependencies**: Are there imports used in `lib/` that are not declared in `pubspec.yaml`?
- **Version constraints**: Too tight (prevents updates) or too loose (allows breaking changes)?
- **Dev dependency leakage**: Are any dev_dependencies imported in `lib/`?
- **Dependency count**: Is the footprint reasonable for the project's scope?

### 7. Generated Code Quality [Medium Priority]

**Scope**: Template strings in `_generate*()` methods in `site_generator.dart` and `project_generator.dart`.

Check for:
- **String template maintainability**: Are multi-line template strings readable? Could any be extracted?
- **Generated code correctness**: Would generated Dart files pass `dart analyze`?
- **Import correctness**: Do generated files import the right packages? Are there hardcoded paths that could break?
- **Escaping issues**: Could user input (project name, description, paths with special characters) break generated code? Are strings properly escaped?
- **Consistency between generators**: Do `SiteGenerator` and `ProjectGenerator` produce compatible outputs?

### 8. Error Handling & Robustness [Medium Priority]

**Scope**: All CLI commands, generators, and services.

Check for:
- **Unhandled exceptions**: `Process.run()` calls without exit code checks.
- **File system assumptions**: Code assuming directories exist without checking. Missing permission error handling.
- **Network error handling**: HTTP requests (pub.dev check, version checker) — do they have timeouts? Graceful failure?
- **User input validation**: Is folder name validation in `CreateCommand` sufficient? Other unvalidated inputs?
- **Graceful degradation**: When optional features fail (theme loading, changelog parsing), does the tool continue or crash?

### 9. Security Review [Medium Priority]

**Scope**: All generators (template code), CLI commands (user input handling), and services (network calls).

Check for:
- **Template injection**: Could user-provided values (project name, description, repository URL) in `pubspec.yaml` inject arbitrary Dart code into generated files? Are strings quoted/escaped properly in templates?
- **Path traversal**: Could a malicious folder name or docs path escape the project directory? Are paths sanitized before use?
- **Dependency confusion**: Could the path dependency resolution in `PackageResolver` be tricked into resolving a different package?
- **Network trust**: Are HTTPS URLs enforced for external requests? Is certificate validation in place?
- **Sensitive data exposure**: Could the generated site accidentally include `.env` files, secrets, or source code that shouldn't be public?

### 10. Open Source Readiness [Medium Priority]

**Scope**: `README.md`, `CHANGELOG.md`, `LICENSE`, `pubspec.yaml`, `.github/`.

Check for:
- **README completeness**: Installation instructions, quick start, feature list, screenshot/demo, badges (CI status, pub.dev version, license), contributing section, license mention.
- **CHANGELOG quality**: Following [Keep a Changelog](https://keepachangelog.com/) format? Detailed enough?
- **pubspec.yaml for pub.dev**: All recommended fields present? (`description` length 60-180 chars, `repository`, `issue_tracker`, `topics`, `screenshots`, `funding`)
- **Contributing guide**: Is there a `CONTRIBUTING.md`? Should there be?
- **Issue/PR templates**: Are there GitHub issue templates (`.github/ISSUE_TEMPLATE/`)? PR template?
- **Code of conduct**: Is there a `CODE_OF_CONDUCT.md`?
- **License**: Is it present and appropriate for the project?
- **Example project quality**: Does `example/` serve as good documentation for new users?

### 11. CI/CD Pipeline [Low Priority]

**Scope**: `.github/workflows/`.

Check for:
- **CI completeness**: Does CI run `dart analyze`, `dart format --set-exit-if-changed`, and `dart test`? Multiple Dart SDK versions or OS?
- **Build integration test**: Should CI run `docudart create && docudart build` as a smoke test?
- **Release pipeline**: Is publishing secure (OIDC, not plain secrets)? Version consistency verification?
- **Cache optimization**: Are Dart pub caches cached for faster CI runs?

### 12. Performance [Low Priority]

**Scope**: Generators, content processing, file watching.

Check for:
- **Generator efficiency**: Are there unnecessary file reads, redundant directory scans, or serial operations that could be parallelized?
- **File I/O patterns**: Is `writeAsString` vs `writeAsBytes` used appropriately? Are large files read into memory unnecessarily?
- **Watch mode overhead**: Does the file watcher debounce correctly? Could rapid edits cause excessive regeneration?
- **Build time bottlenecks**: Is `dart pub get` called more often than necessary? Are there redundant `dart format` calls?

### 13. Accessibility of Generated Sites [Low Priority]

**Scope**: Generated HTML templates in `site_generator.dart`, component `build()` methods, and CSS in `_generateStyles()`.

Check for:
- **Semantic HTML**: Are proper elements used? (`<nav>`, `<main>`, `<article>`, `<aside>`, `<header>`, `<footer>`)
- **ARIA attributes**: Do interactive elements (ExpansionTile, ThemeToggle, sidebar links) have proper ARIA roles, labels, and states?
- **Keyboard navigation**: Can all interactive elements be reached and operated via keyboard?
- **Color contrast**: Do default theme colors meet WCAG AA contrast ratios?
- **Skip links**: Is there a "skip to content" link for keyboard users?
- **Alt text**: Are images (logo, icons) given meaningful alt text or marked as decorative?

### 14. Suggested New Claude Skills [Low Priority]

Based on your understanding of the project, suggest 3-5 additional Claude skills that would be useful. For each, provide:
- **Skill name** (slash command)
- **One-line description**
- **What it would do** (brief)
- **Why it would be valuable**

Consider skills for: releasing a new version, adding a new icon family, creating a new library-level component, running the full test suite, auditing the example project output, scaffolding a new CLI command, etc.

---

## Output Format

Structure your report exactly as follows:

```
# DocuDart Audit Report

## Summary
- Total findings: N
- Critical: N | High: N | Medium: N | Low: N
- Top 3 priorities: [brief list]

## Critical Findings
(Issues that could cause bugs, data loss, or security problems)

### [C1] Title
- **File**: `path/to/file.dart:LINE`
- **Issue**: [specific description]
- **Recommendation**: [specific fix]

## High Priority Findings
(Issues that significantly impact code quality, maintainability, or user experience)

### [H1] Title
- **File**: `path/to/file.dart:LINE`
- **Issue**: [specific description]
- **Recommendation**: [specific fix]

## Medium Priority Findings
(Improvements that would meaningfully improve the codebase)

### [M1] Title
...

## Low Priority Findings
(Nice-to-haves and polish items)

### [L1] Title
...

## Test Coverage Gap Analysis

| Directory | Files | Test Coverage | Priority |
|-----------|-------|---------------|----------|
| cli/commands/ | N | None/Partial/Full | High/Medium/Low |
| generators/ | N | None/Partial/Full | High/Medium/Low |
| ... | ... | ... | ... |

## Suggested New Skills

| Skill | Description |
|-------|-------------|
| `/skill-name` | What it does and why it's valuable |
| ... | ... |

## Suggested Documentation Additions

| File | Purpose |
|------|---------|
| `path/to/NEW_FILE.md` | Why it's needed |
| ... | ... |
```

---

## Rules

1. **Be specific** — never say "consider improving X". Say exactly what is wrong, where, and how to fix it.
2. **Include file paths** — every finding must reference at least one concrete file path from the project root.
3. **Don't suggest rewriting the world** — focus on incremental, practical improvements that preserve existing architecture.
4. **Respect existing conventions** — if the project consistently does something a certain way, flag it once as a systemic issue rather than flagging every instance.
5. **Skip generated icon data files** — do not audit `lucide_icons.dart`, `material_icons.dart`, `material_symbols.dart`, `tabler_icons.dart`, `fluent_icons.dart`, `font_awesome_icons.dart`, `remix_icons.dart`. They are machine-generated.
6. **Read before judging** — always read the actual code before making a finding. Do not guess based on file names alone.
7. **Check CLAUDE.md accuracy** — the root CLAUDE.md and `lib/src/icons/CLAUDE.md` are living documentation. Verify they match the actual code and flag discrepancies.
8. **Prioritize ruthlessly** — Critical = bugs/security/data-loss. High = significant quality/maintainability impact. Medium = meaningful improvement. Low = polish/nice-to-have.
9. **Update `IMPROVEMENT_PLAN.md` after every completed finding** — mark `[x]`, add a brief note. This is critical for cross-session continuity.
10. **Never delete `IMPROVEMENT_PLAN.md` without user confirmation** — when all findings are `[x]`, ask: "All findings are complete. Should I delete `IMPROVEMENT_PLAN.md`?" Only delete if the user says yes.
