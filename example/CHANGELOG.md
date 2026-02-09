# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Streaming API** for processing large datasets without loading everything into memory.

  ```dart
  final stream = greeter.greetStream(names);
  await for (final greeting in stream) {
    print(greeting); // Hello, Alice! Hello, Bob! ...
  }
  ```

- Support for `Calculator.chain()` to fluently compose operations:

  ```dart
  final result = Calculator()
      .chain(5)
      .add(3)
      .multiply(2)
      .subtract(1)
      .value; // 15
  ```

### Changed

- `Greeter.greet()` now returns a `Greeting` object instead of a raw `String`.

  > **Migration**: Replace `greeter.greet()` with `greeter.greet().text` for the previous behavior.

### Deprecated

- `Calculator.compute()` — use `Calculator.evaluate()` instead. Will be removed in v3.0.0.

---

## [2.1.0] - 2026-01-15

### Added

- Custom greeting templates with **interpolation support**:

  ```dart
  final greeter = Greeter(
    'World',
    template: 'Howdy, {{name}}! Welcome to {{place}}.',
    variables: {'place': 'Dart Town'},
  );
  print(greeter.greet()); // Howdy, World! Welcome to Dart Town.
  ```

- New `GreeterConfig` class for centralized configuration:

  | Field | Type | Default | Description |
  |-------|------|---------|-------------|
  | `locale` | `String` | `'en'` | Greeting language |
  | `formal` | `bool` | `false` | Use formal greetings |
  | `prefix` | `String?` | `null` | Optional title prefix |
  | `suffix` | `String?` | `null` | Optional suffix |

- `Calculator` now supports **bitwise operations**:

  ```dart
  final calc = Calculator();
  calc.bitwiseAnd(0xFF, 0x0F); // 15
  calc.bitwiseOr(0xF0, 0x0F);  // 255
  calc.shiftLeft(1, 8);         // 256
  ```

- Added `@immutable` annotation to all value classes.

### Changed

- Improved error messages for `Calculator.divide()` — now includes both operands:

  ```
  // Before:
  CalculatorException: Division by zero

  // After:
  CalculatorException: Cannot divide 42 by 0 — division by zero is undefined.
  ```

- **Performance**: `Greeter.greetAll()` is now ~3x faster for lists over 1,000 names, using `StringBuffer` internally instead of string concatenation.

### Fixed

- Fixed `Calculator.modulo()` returning incorrect results for *negative* dividends.

  ```dart
  // Before (incorrect):
  Calculator().modulo(-7, 3); // -1

  // After (correct, follows Dart semantics):
  Calculator().modulo(-7, 3); // 2
  ```

- Fixed `Greeter` not respecting `locale` when using formal mode. Previously, `formal: true` always produced English output regardless of the `locale` setting.

- Resolved a memory leak in `GreeterPool` when connections were abandoned without calling `.dispose()`.

### Security

- Updated `crypto` dependency to `^3.0.6` to address [CVE-2026-XXXX](https://example.com).

---

## [2.0.0] - 2025-11-01

### Added

- **Null safety migration** — all public APIs now leverage sound null safety.

- `Greeter.greetFormal()` for professional/business contexts:

  ```dart
  final greeter = Greeter('Dr. Smith');
  greeter.greetFormal(); // "Good day, Dr. Smith."
  ```

- Extension methods on `String` for quick greeting generation:

  ```dart
  import 'package:example_project/extensions.dart';

  'Alice'.greet();       // "Hello, Alice!"
  'Bob'.greetFormal();   // "Good day, Bob."
  ```

- `Calculator.history` getter to retrieve a log of all operations:

  ```dart
  final calc = Calculator();
  calc.add(2, 3);
  calc.multiply(4, 5);

  for (final entry in calc.history) {
    print('${entry.operation}: ${entry.result}');
    // add: 5
    // multiply: 20
  }
  ```

- **JSON serialization** for `Greeting` objects:

  ```dart
  final json = greeting.toJson();
  // {"text": "Hello, World!", "timestamp": "2025-11-01T12:00:00Z", "locale": "en"}

  final restored = Greeting.fromJson(json);
  assert(restored == greeting);
  ```

### Changed

- **BREAKING**: `Greeter` constructor now requires a *named* `name` parameter:

  ```dart
  // Before (v1.x):
  final greeter = Greeter('World');

  // After (v2.0):
  final greeter = Greeter(name: 'World');
  ```

- **BREAKING**: `Calculator` methods now throw `CalculatorException` instead of returning `null` on invalid input:

  ```dart
  try {
    Calculator().divide(1, 0);
  } on CalculatorException catch (e) {
    print(e.message); // "Cannot divide 1 by 0"
    print(e.code);    // ErrorCode.divisionByZero
  }
  ```

- Minimum Dart SDK constraint raised to `^3.0.0`.

- `Greeter.greet()` now includes a timestamp in the returned `Greeting` object.

### Removed

- ~~`Greeter.greetLoud()`~~ — use `greeter.greet().text.toUpperCase()` instead.
- ~~`Calculator.unsafeCompute()`~~ — all operations now validate input by default.
- Removed deprecated `v1` JSON format support.

### Migration Guide

1. Update all `Greeter` constructor calls to use named parameters.
2. Replace `greetLoud()` calls with `.greet().text.toUpperCase()`.
3. Wrap `Calculator` calls in try-catch blocks or check inputs beforehand.
4. Update any JSON deserialization code to use the new `Greeting.fromJson()` factory.

---

## [1.2.0] - 2025-08-20

### Added

- `Greeter.greetAll()` for batch greeting generation:

  ```dart
  final greeter = Greeter('Team');
  final greetings = greeter.greetAll(['Alice', 'Bob', 'Charlie']);
  // ["Hello, Alice!", "Hello, Bob!", "Hello, Charlie!"]
  ```

- `Calculator.power()` and `Calculator.sqrt()` methods:

  ```dart
  final calc = Calculator();
  calc.power(2, 10);  // 1024
  calc.sqrt(144);     // 12.0
  ```

- Logging support via the `logging` package. Enable with:

  ```dart
  import 'package:logging/logging.dart';

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);
  ```

### Fixed

- Fixed `Calculator.subtract()` swapping operand order when both values were negative.
- Fixed `Greeter` trimming whitespace from names containing intentional spaces (e.g., `"Mary Jane"`).

---

## [1.1.0] - 2025-06-10

### Added

- `Calculator.modulo()` for remainder operations.
- `Greeter` now accepts an optional `greeting` parameter to customize the prefix:

  ```dart
  final greeter = Greeter('World', greeting: 'Ahoy');
  greeter.greet(); // "Ahoy, World!"
  ```

### Changed

- Internal refactoring: extracted validation logic into `_InputValidator` mixin.
- Improved dartdoc coverage to **100%** for all public APIs.

### Fixed

- Fixed `Calculator.divide()` returning `double.infinity` instead of throwing when dividing by zero.

---

## [1.0.1] - 2025-05-01

### Fixed

- Fixed `Greeter.greet()` throwing a `FormatException` when the name contained Unicode emoji characters (e.g., `"World 🌍"`).
- Fixed package score on pub.dev by adding missing `example/example.dart`.

---

## [1.0.0] - 2025-04-15

### Added

- Initial release with core functionality:
  - `Greeter` class with `greet()` method
  - `Calculator` class with `add()`, `subtract()`, `multiply()`, `divide()`
- Full test coverage (98.7%)
- CI/CD pipeline with GitHub Actions
- Documentation site powered by **DocuDart**

---

[Unreleased]: https://github.com/example/example-project/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/example/example-project/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/example/example-project/compare/v1.2.0...v2.0.0
[1.2.0]: https://github.com/example/example-project/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/example/example-project/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/example/example-project/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/example/example-project/releases/tag/v1.0.0
