---
name: audit-example
description: Regenerate the example project, build it, serve it, and use Playwright to take screenshots verifying the generated site renders correctly.
---

When this skill is invoked (e.g., `/audit-example`):

## Steps

1. **Regenerate the example project**:
   - Remove `example/docudart/` if it exists
   - Run `cd example && dart run ../bin/docudart.dart create --full`
   - Verify exit code is 0

2. **Build the example**:
   - Run `cd example && dart run ../bin/docudart.dart build`
   - Verify exit code is 0

3. **Analyze the generated code**:
   - Run `dart analyze example/docudart/` to verify the generated project has no analysis issues

4. **Serve and take screenshots**:
   - Start the server: `cd example && dart run ../bin/docudart.dart serve &`
   - Wait for the server to be ready (poll `http://localhost:8080` until it responds, max 60s)
   - Use the Playwright skill to take full-page screenshots of key pages:

   **Pages to screenshot** (both light and dark mode):
   - `/` — Landing page (hero section, CTA button)
   - `/docs` — First doc page (sidebar, content, active link highlighting)
   - `/docs/getting-started` — A doc page with sidebar navigation
   - `/changelog` — Changelog page (if it exists)

   **For each page**:
   - Take a light mode screenshot (default)
   - Click `.theme-toggle` to switch to dark mode
   - Take a dark mode screenshot
   - Verify key elements exist in the DOM

   **Key elements to verify**:
   - `header` element exists with logo and nav links
   - `.sidebar` exists on `/docs` pages
   - `.sidebar-link.active` exists (active link highlighting works)
   - `footer` element exists
   - `.theme-toggle` button exists and is clickable
   - `.landing-page` section on `/` has title and CTA button
   - `.skip-to-content` link exists (accessibility)

5. **Stop the server**:
   - `pkill -f "docudart.dart serve"; pkill -f "jaspr"`

6. **Report**:
   - Show all screenshots to the user (read the screenshot files)
   - List any missing elements or visual issues found
   - Summarize: PASS (all checks passed) or FAIL (with details)
