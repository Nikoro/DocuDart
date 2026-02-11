---
name: regenerate
description: Removes the website/ directory in a target folder and re-runs docudart create --full to regenerate it. Accepts an optional directory argument (defaults to "example").
---

When this skill is invoked:

1. Determine the target directory from the argument:
   - If an argument is provided (e.g., `/regenerate example`), use that as the target directory
   - If no argument is provided, default to `example`

2. Validate the target directory exists at `<project_root>/<target>/`:
   - If it does NOT exist, report an error: "Directory '<target>/' does not exist."
   - If it exists, continue

3. Remove `<target>/website/` if it exists

4. Run `docudart create --full` from the target directory:
   ```
   cd <target> && dart run ../bin/docudart.dart create --full
   ```

5. Report the result to the user
