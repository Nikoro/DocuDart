---
name: add-component
description: Scaffold a new library-level component in lib/src/components/ with StatelessComponent boilerplate, export it via docudart.dart, and update documentation.
---

When this skill is invoked with a component name (e.g., `/add-component Badge`):

## Steps

1. **Determine the component details**:
   - If no argument provided, ask the user for the component name (PascalCase, e.g., `Badge`)
   - Ask which subdirectory under `lib/src/components/` it belongs in:
     - `navigation/` — navigation-related (links, sidebar, toggles)
     - `content/` — content rendering (markdown, code blocks)
     - `branding/` — brand/identity (logo, copyright, socials)
     - `layout/` — layout primitives (row, column, spacer)
     - `providers/` — context/state providers
     - Or a new subdirectory
   - Ask for the component's constructor parameters (name, type, required/optional, default value)

2. **Read existing components** in the target subdirectory to understand conventions:
   - Import style (`package:docudart/docudart.dart` vs relative)
   - Class structure (StatelessComponent with `build()` returning single `Component`)
   - Naming patterns, doc comment style

3. **Create the component file** at `lib/src/components/<subdir>/<snake_case_name>.dart`:
   - Import `package:docudart/docudart.dart`
   - `class <Name> extends StatelessComponent` with `const` constructor (if possible)
   - Doc comment explaining what the component does
   - `build()` method with a basic placeholder implementation
   - Follow existing patterns: Jaspr HTML elements (lowercase constructors), `classes` as `String`

4. **Export from `docudart.dart`**:
   - Add `export 'src/components/<subdir>/<snake_case_name>.dart';` in the appropriate section
   - Maintain alphabetical ordering within the section

5. **Verify**:
   - Run `dart analyze lib/src/components/<subdir>/<snake_case_name>.dart` to check it compiles

6. **Update CLAUDE.md**:
   - Add a section documenting the new component's API under the Key Classes section
   - Follow the existing format (constructor, fields, CSS classes, usage examples)

7. **Report**:
   - Print the file path and a summary of the component
   - Remind the user to implement the `build()` method and add CSS styles if needed
