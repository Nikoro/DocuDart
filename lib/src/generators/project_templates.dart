import 'dart:io';

import 'package:path/path.dart' as p;

import '../cli/errors.dart';
import '../processing/readme_parser.dart';

/// Generates template files (components, config, labels, pages, docs)
/// for new DocuDart projects.
class ProjectTemplates {
  /// Generate wrapper components in [websiteDir]/components/.
  Future<void> generateComponents(String websiteDir, String title) async {
    final componentsDir = p.join(websiteDir, 'components');

    // Header component
    await File(p.join(componentsDir, 'header.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// Site header component.
///
/// Customize this component to change the header layout.
/// The [leading] slot is typically a [Logo].
///
/// Uses [context.screen] to show a [SidebarToggle] on mobile/tablet
/// when [showSidebarToggle] is true (e.g., on pages with a sidebar).
///
/// On desktop, nav links appear inline in the main row.
/// On mobile/tablet, they appear in a second scrollable row below.
class Header extends StatelessComponent {
  const Header({
    this.leading,
    this.links,
    this.trailing,
    this.showSidebarToggle = false,
    super.key,
  });

  final Component? leading;
  final List<Link>? links;
  final Component? trailing;

  /// Whether to show the sidebar toggle button on mobile/tablet.
  final bool showSidebarToggle;

  @override
  Component build(BuildContext context) {
    return header([
      Column(crossAxisAlignment: .stretch, children: [
        // Main row: hamburger + logo + spacer + desktop links + trailing
        Row(
          crossAxisAlignment: .center,
          spacing: 1.5.rem,
          children: [
            // Show hamburger menu on mobile/tablet when sidebar is present
            if (showSidebarToggle)
              ?context.screen.maybeWhen(
                mobile: () => SidebarToggle(),
                tablet: () => SidebarToggle(),
              ),
            ?leading,
            Spacer(),
            // Nav links only on desktop — inline in main row
            ?context.screen.maybeWhen(
              desktop: () => Row(
                spacing: 1.5.rem,
                mainAxisSize: MainAxisSize.min,
                children: [...?links],
              ),
            ),
            ?trailing,
          ],
        ),
        // Mobile/tablet nav row — below the main header row
        if (links != null && links!.isNotEmpty)
          ?context.screen.maybeWhen(
            mobile: () => Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(spacing: 1.rem, children: [...?links]),
            ).apply(styles: Styles(overflow: Overflow.only(x: Overflow.auto))),
            tablet: () => Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(spacing: 1.rem, children: [...?links]),
            ).apply(styles: Styles(overflow: Overflow.only(x: Overflow.auto))),
          ),
      ]),
    ]);
  }
}
''');

    // Footer component
    await File(p.join(componentsDir, 'footer.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// Site footer component.
///
/// Customize this component to change the footer layout.
///
/// Uses [context.screen] to switch between horizontal (desktop) and
/// vertical (mobile/tablet) layout.
class Footer extends StatelessComponent {
  const Footer({this.leading, this.center, this.trailing, super.key});

  final Component? leading;
  final Component? center;
  final Component? trailing;

  @override
  Component build(BuildContext context) {
    return footer([
      context.screen.when(
        desktop: () => Row(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .center,
          children: [?leading, ?center, ?trailing],
        ),
        tablet: () => Column(
          spacing: 1.5.rem,
          children: [?center, ?leading, ?trailing],
        ),
        mobile: () => Column(
          spacing: 1.5.rem,
          children: [?center, ?leading, ?trailing],
        ),
      ),
    ]);
  }
}
''');

    // Button component
    await File(p.join(componentsDir, 'button.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// A clickable button component.
class Button extends StatelessComponent {
  final String text;
  final String href;
  final String classes;

  const Button({required this.text, required this.href, this.classes = 'button', super.key});

  const Button.primary({required this.text, required this.href, super.key})
      : classes = 'button button-primary';

  @override
  Component build(BuildContext context) {
    return a(href: href, classes: classes, [.text(text)]);
  }
}
''');

    // Sidebar component
    await File(p.join(componentsDir, 'sidebar.dart')).writeAsString('''
import 'package:docudart/docudart.dart';

/// Site sidebar component.
///
/// Customize this component to change the sidebar layout.
/// The [DefaultSidebar] renders a navigation tree from the docs structure.
/// The [items] are auto-generated from your docs/ folder.
class Sidebar extends StatelessComponent {
  const Sidebar({super.key});

  @override
  Component build(BuildContext context) {
    return DefaultSidebar(items: context.project.docs);
  }
}
''');
  }

  /// Generate config.dart in [websiteDir].
  Future<void> generateConfig(
    String websiteDir,
    String title,
    String description,
    String pubDevUrl, {
    bool hasChangelog = false,
  }) async {
    final changelogLink = hasChangelog
        ? "      .path('/changelog', label: Labels.changelog),\n"
        : '';

    final configContent =
        "import 'package:docudart/docudart.dart';\n"
        "import 'components/header.dart';\n"
        "import 'components/footer.dart';\n"
        "import 'components/sidebar.dart';\n"
        "import 'labels.dart';\n"
        "import 'pages/landing_page.dart';\n"
        '\n'
        'Config configure(BuildContext context) => Config(\n'
        '  title: context.project.pubspec.name,\n'
        '  description: context.project.pubspec.description,\n'
        "  // siteUrl: 'https://my-project.dev', // Uncomment for SEO (canonical URLs, Open Graph, sitemap)\n"
        '  themeMode: .system,\n'
        '  theme: .classic(),\n'
        "  // Home page component. Set to null to redirect '/' to '/docs'.\n"
        '  home: () => LandingPage(),\n'
        '  // Header, footer, and sidebar are components.\n'
        '  // Set to null to hide any section.\n'
        '  header: () => Header(\n'
        "    showSidebarToggle: context.url.contains('/docs'),\n"
        "    leading: Logo(\n"
        r"      image: context.project.assets.logo.logo_webp(alt: '${context.project.pubspec.name} logo'),"
        "\n"
        '      title: context.project.pubspec.name,\n'
        '    ),\n'
        '    links: [\n'
        "      .path('/docs', label: Labels.docs, leading: Icon(MaterialSymbols.docs)),\n"
        '$changelogLink'
        "      ?context.project.pubspec.repository.let(\n"
        "        (repository) => .url(\n"
        "          repository.link,\n"
        "          label: repository.label,\n"
        "          leading: repository.icon,\n"
        "          trailing: Icon(MaterialIcons.open_in_new),\n"
        "        ),\n"
        "      ),\n"
        "      .url(\n"
        "        '$pubDevUrl',\n"
        "        label: Labels.pubDev,\n"
        "        leading: Icon(FontAwesomeIcons.dart_lang_brand),\n"
        "        trailing: Icon(MaterialIcons.open_in_new),\n"
        "      ),\n"
        '    ],\n'
        '    trailing: ThemeToggle(\n'
        '      light: Icon(MaterialIcons.light_mode),\n'
        '      dark: Icon(MaterialIcons.dark_mode),\n'
        '    ),\n'
        '  ),\n'
        '  footer: () => context.project.pubspec.let(\n'
        '    (pubspec) => Footer(\n'
        '      leading: pubspec.topics.let(\n'
        '        (topics) => Topics(\n'
        '          title: Labels.topics,\n'
        '          links: [\n'
        "            for (final topic in topics)\n"
        r"              .url('https://pub.dev/packages?q=topic%3A$topic', label: '#$topic'),"
        '\n'
        '          ],\n'
        '        ),\n'
        '      ),\n'
        '      center: Column(\n'
        '        children: [\n'
        '          Copyright(text: context.project.license?.holder ?? pubspec.name),\n'
        '          BuiltWithDocuDart(),\n'
        '        ],\n'
        '      ),\n'
        '      trailing: Socials(\n'
        '        links: [\n'
        "          .url('https://youtube.com', leading: Icon(FontAwesomeIcons.youtube_brand)),\n"
        "          .url('https://discord.com', leading: Icon(FontAwesomeIcons.discord_brand)),\n"
        "          .url('https://x.com', leading: Icon(FontAwesomeIcons.x_twitter_brand)),\n"
        '        ],\n'
        '      ),\n'
        '    ),\n'
        '  ),\n'
        "  sidebar: () => context.url.contains('/docs') ? Sidebar() : null,\n"
        ');\n';

    await File(p.join(websiteDir, 'config.dart')).writeAsString(configContent);
  }

  /// Generate labels.dart in [websiteDir].
  Future<void> generateLabels(String websiteDir) async {
    await File(p.join(websiteDir, 'labels.dart')).writeAsString('''
/// Label constants for use in navigation links and components.
///
/// Use these instead of hardcoded strings to keep labels consistent
/// and easy to update across your site.
abstract class Labels {
  Labels._();

  // --- Code Hosting ---

  static const bitbucket = 'Bitbucket';
  static const github = 'GitHub';
  static const gitlab = 'GitLab';

  // --- Social Media ---

  static const discord = 'Discord';
  static const instagram = 'Instagram';
  static const linkedin = 'LinkedIn';
  static const medium = 'Medium';
  static const reddit = 'Reddit';
  static const slack = 'Slack';
  static const tiktok = 'TikTok';
  static const xTwitter = 'X';
  static const youtube = 'YouTube';

  // --- Developer / Ecosystem ---

  static const pubDev = 'pub.dev';
  static const changelog = 'Changelog';
  static const docs = 'Docs';
  static const topics = 'Topics';
}
''');
  }

  /// Generate landing page in [websiteDir]/pages/.
  Future<void> generateLandingPage(
    String websiteDir,
    String title,
    String description,
  ) async {
    final landingContent = '''
import 'package:docudart/docudart.dart';

import '../components/button.dart';

/// Landing page component.
class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    final title = context.project.pubspec.name;
    final description = context.project.pubspec.description;
    return Column(
      mainAxisAlignment: .center,
      spacing: 1.5.rem,
      children: [
        Logo(image: context.project.assets.logo.logo_webp()),
        ?title.let((t) => h1([.text(t)])),
        ?description.let((d) => p(classes: 'description', [.text(d)])),
        Button.primary(text: 'Get Started', href: '/docs'),
      ],
    ).apply(classes: 'landing-page');
  }
}
''';

    await File(
      p.join(websiteDir, 'pages', 'landing_page.dart'),
    ).writeAsString(landingContent);
  }

  /// Generate changelog page in [websiteDir]/pages/.
  Future<void> generateChangelogPage(String websiteDir) async {
    await File(
      p.join(websiteDir, 'pages', 'changelog_page.dart'),
    ).writeAsString('''
import 'package:docudart/docudart.dart';
import 'package:jaspr/dom.dart';

class ChangelogPage extends StatelessComponent {
  const ChangelogPage({super.key});

  @override
  Component build(BuildContext context) {
    final changelog = context.project.changelog;
    if (changelog == null || changelog.isEmpty) {
      return div(classes: 'docs-content', []);
    }
    return div(classes: 'docs-content', [RawText(changelog)]);
  }
}
''');
  }

  /// Generate documentation files from README.md or example templates.
  Future<void> generateDocs(
    String websiteDir,
    String projectDir,
    bool isFull,
  ) async {
    final docsDir = Directory(p.join(websiteDir, 'docs'));

    // Check if docs already has .md files
    final existingMdFiles = await docsDir
        .list()
        .where((e) => e is File && e.path.endsWith('.md'))
        .toList();

    if (existingMdFiles.isNotEmpty) {
      CliPrinter.info('Using existing documentation files in docs/');
      return;
    }

    // Try to parse README.md from project root
    final readmeFile = File(p.join(projectDir, 'README.md'));
    if (readmeFile.existsSync()) {
      await _generateDocsFromReadme(websiteDir, readmeFile);
    } else {
      await _generateExampleDocs(websiteDir);
    }

    // For full template, always add example subfolders to showcase sidebar features
    if (isFull) {
      await _generateFullTemplateSubfolders(websiteDir);
    }
  }

  Future<void> _generateDocsFromReadme(
    String websiteDir,
    File readmeFile,
  ) async {
    final sections = await ReadmeParser.parseFile(readmeFile.path);

    if (sections.isEmpty) {
      // Just copy README as index
      final content = await readmeFile.readAsString();
      await File(p.join(websiteDir, 'docs', 'index.md')).writeAsString('''
---
title: Introduction
sidebar_position: 1
---

$content
''');
      return;
    }

    // Generate a file for each section
    for (final section in sections) {
      final ReadmeSection(:title, :content, :filename, :position) = section;
      final mdContent =
          '''
---
title: $title
sidebar_position: $position
---

$content
''';
      await File(
        p.join(websiteDir, 'docs', '$filename.md'),
      ).writeAsString(mdContent);
    }

    CliPrinter.info(
      'Generated ${sections.length} documentation files from README.md',
    );
  }

  Future<void> _generateExampleDocs(String websiteDir) async {
    // Index page
    await File(p.join(websiteDir, 'docs', 'index.md')).writeAsString('''
---
title: Introduction
description: Welcome to your documentation site powered by DocuDart.
sidebar_position: 1
---

# Welcome to Your Documentation

This is your documentation site powered by DocuDart.

## Getting Started

Edit the files in the `docs/` folder to add your content.

## Features

- **Markdown Support**: Write your docs in Markdown with YAML frontmatter
- **Component Embedding**: Embed custom Jaspr components in your docs
- **Theming**: Customize the look and feel with themes
- **Dark Mode**: Built-in dark mode support
''');

    // Getting started page
    await File(p.join(websiteDir, 'docs', 'getting-started.md')).writeAsString(
      '''
---
title: Getting Started
description: Learn how to set up and write documentation with DocuDart.
sidebar_position: 2
---

# Getting Started

Learn how to use this documentation site.

## Writing Documentation

Create `.md` files in the `docs/` folder. Each file becomes a page.

### Frontmatter

Add YAML frontmatter at the top of each file:

```yaml
---
title: Page Title
sidebar_position: 1
description: Page description for SEO
---
```

### Markdown Features

- **Bold** and *italic* text
- [Links](https://example.com)
- Code blocks with syntax highlighting
- Tables, lists, and more

## Building Your Site

Run `docudart build` to generate static files.

## Development Server

Run `docudart serve` to start a local development server with hot reload.
''',
    );
  }

  /// Generate example subfolders for the full template.
  /// Showcases the `_expanded` suffix and deeply nested categories.
  Future<void> _generateFullTemplateSubfolders(String websiteDir) async {
    // Guides folder — uses _expanded suffix so it starts open in the sidebar
    final guidesDir = p.join(websiteDir, 'docs', '01-guides_expanded');
    await Directory(guidesDir).create(recursive: true);

    await File(p.join(guidesDir, 'components.md')).writeAsString('''
---
title: Custom Components
sidebar_position: 1
---

# Custom Components

You can embed custom Jaspr components in your Markdown files.

## Creating a Component

Create a Dart file in the `components/` folder:

```dart
import 'package:docudart/docudart.dart';

class MyComponent extends StatelessComponent {
  final String title;

  const MyComponent({required this.title, super.key});

  @override
  Component build(BuildContext context) {
    return div([.text(title)]);
  }
}
```

## Using Components in Markdown

Reference your component in Markdown:

```markdown
<MyComponent title="Hello World" />
```

The component will be rendered in place.
''');

    await File(p.join(guidesDir, 'theming.md')).writeAsString('''
---
title: Theming
sidebar_position: 2
---

# Theming

Customize the look and feel of your documentation site.

## Default Theme

DocuDart comes with a default theme inspired by Flutter docs.

## Customizing Colors

Edit `config.dart` to change the primary color:

```dart
theme: Theme.classic(seedColor: Colors.indigo),
```

## Theme Mode

Control dark mode behavior via the `themeMode` field in `config.dart`:

- `ThemeMode.system` - Follow system preference (default)
- `ThemeMode.light` - Always light mode
- `ThemeMode.dark` - Always dark mode

## Custom Themes

Create a custom theme using `Theme()` or customize a preset with `copyWith`.
''');

    // Advanced folder — collapsed by default, with a nested subfolder
    final advancedDir = p.join(websiteDir, 'docs', '02-advanced');
    await Directory(advancedDir).create(recursive: true);

    await File(p.join(advancedDir, 'configuration.md')).writeAsString('''
---
title: Configuration
sidebar_position: 1
---

# Configuration

All site settings live in `config.dart`.

## Config Fields

- `title` — Site title displayed in the header
- `description` — SEO description
- `themeMode` — `system`, `light`, or `dark`
- `header` / `footer` / `sidebar` — Layout component functions (set to `null` to hide)

## Disabling a Section

```dart
Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: null,    // No footer
  sidebar: null,   // No sidebar
);
```
''');

    // Deeply nested: advanced/deployment/
    final deploymentDir = p.join(advancedDir, 'deployment');
    await Directory(deploymentDir).create(recursive: true);

    await File(p.join(deploymentDir, 'github-pages.md')).writeAsString('''
---
title: GitHub Pages
sidebar_position: 1
---

# Deploy to GitHub Pages

Run `docudart build` and deploy the `build/web/` directory.

## GitHub Actions

Add a workflow file at `.github/workflows/docs.yml` to automate deployment on every push.
''');

    await File(p.join(deploymentDir, 'netlify.md')).writeAsString('''
---
title: Netlify
sidebar_position: 2
---

# Deploy to Netlify

Connect your repository and set the build command to `docudart build` with the publish directory set to `build/web/`.
''');

    // Dart language introduction page (content from dart.dev/language)
    // A content-rich page useful for comparing rendering with dart.dev
    await File(p.join(websiteDir, 'docs', 'dart-language.md')).writeAsString('''
---
title: Introduction to Dart
description: A brief introduction to the Dart language through samples of its main features.
sidebar_position: 10
---

# Introduction to Dart

A brief introduction to the Dart language through samples of its main features.

## Hello World

Every app requires a top-level `main()` function where execution starts. Functions without explicit return values have the `void` return type.

```dart
void main() {
  print('Hello, World!');
}
```

Read more about the `main()` function in Dart, including optional parameters for command-line arguments.

## Variables

Even in type-safe Dart code, you can declare most variables without explicitly specifying their type using `var`. Thanks to type inference, these variables' types are determined by their initial values:

```dart
var name = 'Voyager I';
var year = 1977;
var antennaDiameter = 3.7;
var flybyObjects = ['Jupiter', 'Saturn', 'Uranus', 'Neptune'];
var image = {
  'tags': ['saturn'],
  'url': '//path/to/saturn.jpg',
};
```

Read more about variables in Dart, including default values, the `final` and `const` keywords, and static types.

## Control flow statements

Dart supports the usual control flow statements:

```dart
if (year >= 2001) {
  print('21st century');
} else if (year >= 1901) {
  print('20th century');
}

for (final object in flybyObjects) {
  print(object);
}

for (int month = 1; month <= 12; month++) {
  print(month);
}

while (year < 2016) {
  year += 1;
}
```

Read more about control flow statements in Dart, including `break` and `continue`, `switch` and `case`, and `assert`.

## Functions

We recommend specifying the types of each function's arguments and return value:

```dart
int fibonacci(int n) {
  if (n == 0 || n == 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

var result = fibonacci(20);
```

A shorthand `=>` (*arrow*) syntax is handy for functions that contain a single statement. This syntax is especially useful when passing anonymous functions as arguments:

```dart
flybyObjects.where((name) => name.contains('turn')).forEach(print);
```

Besides showing an anonymous function (the argument to `where()`), this code shows that you can use a function as an argument: the top-level `print()` function is an argument to `forEach()`.

Read more about functions in Dart, including optional parameters, default parameter values, and lexical scope.

## Comments

Dart comments usually start with `//`.

```dart
// This is a normal, one-line comment.

/// This is a documentation comment, used to document libraries,
/// classes, and their members. Tools like IDEs and dartdoc treat
/// doc comments specially.

/* Comments like these are also supported. */
```

Read more about comments in Dart, including how the documentation tooling works.

## Imports

To access APIs defined in other libraries, use `import`.

```dart
// Importing core libraries
import 'dart:math';

// Importing libraries from external packages
import 'package:test/test.dart';

// Importing files
import 'path/to/my_other_file.dart';
```

Read more about libraries and visibility in Dart, including library prefixes, `show` and `hide`, and lazy loading through the `deferred` keyword.

## Classes

Here's an example of a class with three properties, two constructors, and a method. One of the properties can't be set directly, so it's defined using a getter method (instead of a variable). The method uses string interpolation to print variables' string equivalents inside of string literals.

```dart
class Spacecraft {
  String name;
  DateTime? launchDate;

  // Read-only non-final property
  int? get launchYear => launchDate?.year;

  // Constructor, with syntactic sugar for assignment to members.
  Spacecraft(this.name, this.launchDate) {
    // Initialization code goes here.
  }

  // Named constructor that forwards to the default one.
  Spacecraft.unlaunched(String name) : this(name, null);

  // Method.
  void describe() {
    print('Spacecraft: \$name');
    // Type promotion doesn't work on getters.
    var launchDate = this.launchDate;
    if (launchDate != null) {
      int years = DateTime.now().difference(launchDate).inDays ~/ 365;
      print('Launched: \$launchYear (\$years years ago)');
    } else {
      print('Unlaunched');
    }
  }
}
```

Read more about strings, including string interpolation, literals, expressions, and the `toString()` method.

You might use the `Spacecraft` class like this:

```dart
var voyager = Spacecraft('Voyager I', DateTime(1977, 9, 5));
voyager.describe();

var voyager3 = Spacecraft.unlaunched('Voyager III');
voyager3.describe();
```

Read more about classes in Dart, including initializer lists, optional `new` and `const`, redirecting constructors, `factory` constructors, getters, setters, and much more.

## Enums

Enums are a way of enumerating a predefined set of values or instances in a way which ensures that there cannot be any other instances of that type.

Here is an example of a simple `enum` that defines a simple list of predefined planet types:

```dart
enum PlanetType { terrestrial, gas, ice }
```

Here is an example of an enhanced enum declaration of a class describing planets, with a defined set of constant instances, namely the planets of our own solar system.

```dart
/// Enum that enumerates the different planets in our solar system
/// and some of their properties.
enum Planet {
  mercury(planetType: PlanetType.terrestrial, moons: 0, hasRings: false),
  venus(planetType: PlanetType.terrestrial, moons: 0, hasRings: false),
  // ···
  uranus(planetType: PlanetType.ice, moons: 27, hasRings: true),
  neptune(planetType: PlanetType.ice, moons: 14, hasRings: true);

  /// A constant generating constructor
  const Planet({
    required this.planetType,
    required this.moons,
    required this.hasRings,
  });

  /// All instance variables are final
  final PlanetType planetType;
  final int moons;
  final bool hasRings;

  /// Enhanced enums support getters and other methods
  bool get isGiant =>
      planetType == PlanetType.gas || planetType == PlanetType.ice;
}
```

You might use the `Planet` enum like this:

```dart
final yourPlanet = Planet.earth;

if (!yourPlanet.isGiant) {
  print('Your planet is not a "giant planet".');
}
```

Read more about enums in Dart, including enhanced enum requirements, automatically introduced properties, accessing enumerated value names, switch statement support, and much more.

## Inheritance

Dart has single inheritance.

```dart
class Orbiter extends Spacecraft {
  double altitude;

  Orbiter(super.name, DateTime super.launchDate, this.altitude);
}
```

Read more about extending classes, the optional `@override` annotation, and more.

## Mixins

Mixins are a way of reusing code in multiple class hierarchies. The following is a mixin declaration:

```dart
mixin Piloted {
  int astronauts = 1;

  void describeCrew() {
    print('Number of astronauts: \$astronauts');
  }
}
```

To add a mixin's capabilities to a class, just extend the class with the mixin.

```dart
class PilotedCraft extends Spacecraft with Piloted {
  // ···
}
```

`PilotedCraft` now has the `astronauts` field as well as the `describeCrew()` method.

Read more about mixins.

## Interfaces and abstract classes

All classes implicitly define an interface. Therefore, you can implement any class.

```dart
class MockSpaceship implements Spacecraft {
  // ···
}
```

Read more about implicit interfaces, or about the explicit `interface` keyword.

You can create an abstract class to be extended (or implemented) by a concrete class. Abstract classes can contain abstract methods (with empty bodies).

```dart
abstract class Describable {
  void describe();

  void describeWithEmphasis() {
    print('=========');
    describe();
    print('=========');
  }
}
```

Any class extending `Describable` has the `describeWithEmphasis()` method, which calls the extender's implementation of `describe()`.

Read more about abstract classes and methods.

## Async

Avoid callback hell and make your code much more readable by using `async` and `await`.

```dart
const oneSecond = Duration(seconds: 1);
// ···
Future<void> printWithDelay(String message) async {
  await Future.delayed(oneSecond);
  print(message);
}
```

The method above is equivalent to:

```dart
Future<void> printWithDelay(String message) {
  return Future.delayed(oneSecond).then((_) {
    print(message);
  });
}
```

As the next example shows, `async` and `await` help make asynchronous code easy to read.

```dart
Future<void> createDescriptions(Iterable<String> objects) async {
  for (final object in objects) {
    try {
      var file = File('\$object.txt');
      if (await file.exists()) {
        var modified = await file.lastModified();
        print(
          'File for \$object already exists. It was modified on \$modified.',
        );
        continue;
      }
      await file.create();
      await file.writeAsString('Start describing \$object in this file.');
    } on IOException catch (e) {
      print('Cannot create description for \$object: \$e');
    }
  }
}
```

You can also use `async*`, which gives you a nice, readable way to build streams.

```dart
Stream<String> report(Spacecraft craft, Iterable<String> objects) async* {
  for (final object in objects) {
    await Future.delayed(oneSecond);
    yield '\${craft.name} flies by \$object';
  }
}
```

Read more about asynchrony support, including `async` functions, `Future`, `Stream`, and the asynchronous loop (`await for`).

## Exceptions

To raise an exception, use `throw`:

```dart
if (astronauts == 0) {
  throw StateError('No astronauts.');
}
```

To catch an exception, use a `try` statement with `on` or `catch` (or both):

```dart
Future<void> describeFlybyObjects(List<String> flybyObjects) async {
  try {
    for (final object in flybyObjects) {
      var description = await File('\$object.txt').readAsString();
      print(description);
    }
  } on IOException catch (e) {
    print('Could not describe object: \$e');
  } finally {
    flybyObjects.clear();
  }
}
```

Note that the code above is asynchronous; `try` works for both synchronous and asynchronous code in an `async` function.

Read more about exceptions, including stack traces, `rethrow`, and the difference between `Error` and `Exception`.

## Important concepts

As you continue to learn about the Dart language, keep these facts and concepts in mind:

- Everything you can place in a variable is an *object*, and every object is an instance of a *class*. Even numbers, functions, and `null` are objects. With the exception of `null` (if sound null safety is enabled), all objects inherit from the `Object` class.

- Although Dart is strongly typed, type annotations are optional because Dart can infer types. In `var number = 101`, `number` is inferred to be of type `int`.

- Variables can't contain `null` unless you say they can. You can make a variable nullable by putting a question mark (`?`) at the end of its type. For example, a variable of type `int?` might be an integer, or it might be `null`. If you know that an expression never evaluates to `null` but Dart disagrees, you can add `!` to assert that it isn't null (and to throw an exception if it is). An example: `int x = nullableButNotNullInt!`

- When you want to explicitly say that any type is allowed, use the type `Object?` (if null safety is enabled), `Object`, or — if you must defer type checking until runtime — the special type `dynamic`.

- Dart supports generic types, like `List<int>` (a list of integers) or `List<Object>` (a list of objects of any type).

- Dart supports top-level functions (such as `main()`), as well as functions tied to a class or object (*static* and *instance methods*, respectively). You can also create functions within functions (*nested* or *local functions*).

- Similarly, Dart supports top-level *variables*, as well as variables tied to a class or object (static and instance variables). Instance variables are sometimes known as *fields* or *properties*.

- Unlike Java, Dart doesn't have the keywords `public`, `protected`, and `private`. If an identifier starts with an underscore (`_`), it's private to its library.

- *Identifiers* can start with a letter or underscore (`_`), followed by any combination of those characters plus digits.

- Dart has both *expressions* (which have runtime values) and *statements* (which don't). For example, the conditional expression `condition ? expr1 : expr2` has a value of `expr1` or `expr2`. Compare that to an if-else statement, which has no value. A statement often contains one or more expressions, but an expression can't directly contain a statement.

- Dart tools can report two kinds of problems: *warnings* and *errors*. Warnings are just indications that your code might not work, but they don't prevent your program from executing. Errors can be either compile-time or run-time. A compile-time error prevents the code from executing at all; a run-time error results in an exception being raised while the code executes.

## Additional resources

You can find more documentation and code samples in the core library documentation and the Dart API reference. This site's code follows the conventions in the Dart style guide.
''');
  }

  /// Generate README.md in [websiteDir].
  Future<void> generateReadme(String websiteDir, String title) async {
    final readme =
        '''
# $title - Documentation Site

This documentation site is powered by [DocuDart](https://github.com/docudart/docudart).

## Quick Start

```bash
# Build the static site
docudart build

# Start a development server with hot reload
docudart serve
```

## Project Structure

```
docudart/
  config.dart        # Site configuration (title, theme, layout components)
  docs/              # Markdown documentation files
  pages/             # Custom page components (Dart/Jaspr)
  components/        # Layout components (header, footer, sidebar)
    header.dart      # Header component
    footer.dart      # Footer component
    sidebar.dart     # Sidebar component wrapping DefaultSidebar
  assets/            # Static files (images, fonts, etc.)
  themes/            # Custom theme implementations
```

## Writing Documentation

Add Markdown files to the `docs/` directory. Each file becomes a page on your site.

Every doc file should start with YAML frontmatter:

```markdown
---
title: Page Title
sidebar_position: 1
description: Optional description for SEO
---

# Page Title

Your content here.
```

- **`title`** - Displayed in the sidebar and browser tab.
- **`sidebar_position`** - Controls ordering in the sidebar (lower numbers appear first).
- **`description`** - Used for SEO meta tags.

### Organizing Docs

Create subdirectories inside `docs/` to group related pages. The folder structure is reflected in the sidebar.

## Customizing Layout

The header, footer, and sidebar are components defined in `components/`. Edit them to customize your site's layout.

### Disabling a Section

Set any layout section to `null` in `config.dart` to hide it:

```dart
Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: null,    // No footer
  sidebar: null,   // No sidebar
);
```

## Configuration

All site settings live in `config.dart`:

```dart
import 'package:docudart/docudart.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'components/sidebar.dart';

Config configure(BuildContext context) => Config(
  title: context.project.pubspec.name,
  description: context.project.pubspec.description,

  // Theme
  themeMode: ThemeMode.system,  // system | light | dark
  theme: Theme.classic(
    seedColor: Colors.blue,     // accepts Colors.xxx or Color.value(0xAARRGGBB)
  ),

  // Layout components (set to null to hide)
  header: () => Header(leading: Logo(title: context.project.pubspec.name)),
  footer: () => Footer(center: Copyright(text: context.project.pubspec.name)),
  sidebar: () => Sidebar(),
);
```

## Build Output

Running `docudart build` generates static files in `build/web/`. You can deploy this directory to any static hosting provider (GitHub Pages, Netlify, Vercel, Firebase Hosting, etc.).
''';

    await File(p.join(websiteDir, 'README.md')).writeAsString(readme);
  }
}
