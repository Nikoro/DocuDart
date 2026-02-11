---
name: add-icon-family
description: Scaffold a new icon family into DocuDart's icon system. Guides through repo URL, SVG path, naming, and runs the generator.
---

When this skill is invoked (e.g., `/add-icon-family`):

## Steps

1. **Gather information** — ask the user:
   - Icon family name (e.g., `heroicons`) — used for class name (`HeroIcons`) and file name (`hero_icons.dart`)
   - Git repository URL (e.g., `https://github.com/tailwindlabs/heroicons`)
   - SVG directory path within the repo (e.g., `src/24/outline`)
   - Whether the family has style variants (e.g., `outline`, `solid`, `mini`) — if so, gather the SVG subdirectory and suffix for each variant
   - Root SVG attributes: does the family use `stroke` (like Lucide) or `fill` (like Material Icons) or neither?

2. **Read the existing generator** at `tool/generate_icons.dart` to understand the current family configuration pattern.

3. **Add the new family configuration** to `tool/generate_icons.dart`:
   - Add a new entry to the families map/list following the existing pattern
   - Include: family name, repo URL, SVG paths, class name, file name, root attributes, variant suffixes

4. **Run the generator** for just the new family:
   ```bash
   dart run tool/generate_icons.dart <family-name>
   ```

5. **Update the barrel file** `lib/src/icons/icons.dart`:
   - Add `export '<family_name>_icons.dart';`

6. **Verify**:
   - Run `dart analyze lib/src/icons/` to check the generated file compiles
   - Count the generated icons and report to the user

7. **Update documentation**:
   - Update the Icon System table in `CLAUDE.md` with the new family
   - Update the Icon System table in `MEMORY.md` with the new family
   - Add the new family to the table in `lib/src/icons/CLAUDE.md` if it exists

8. **Report**:
   - Print: family name, icon count, file size, class name
   - Remind the user to commit the changes
