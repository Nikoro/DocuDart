---
name: test
description: Run the full test suite, static analysis, and format check. Reports results and suggests fixes for any failures.
---

When this skill is invoked (e.g., `/test`):

## Steps

1. **Run all three checks in parallel**:

   a. **Tests**: `dart test`
   b. **Analysis**: `dart analyze lib bin test`
   c. **Formatting**: `dart format --set-exit-if-changed lib bin test`

2. **Report results** for each check:
   - If all pass: print a single success summary with counts (e.g., "All 42 tests passed, 0 analysis issues, formatting OK")
   - If any fail:
     - Show the failing output
     - For test failures: identify the failing test file and test name
     - For analysis issues: list each issue with file path and line number
     - For format issues: list the files that need formatting

3. **Offer to fix** (only if there are fixable issues):
   - Format issues: ask "Run `dart format .` to fix formatting?" and fix if confirmed
   - Analysis issues: if they are auto-fixable (`dart fix`), offer to run `dart fix --apply`
   - Test failures: do NOT auto-fix — instead suggest what to investigate

4. **Summary line**:
   - `PASS` or `FAIL` with counts for each category
