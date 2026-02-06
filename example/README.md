# Example Project

A sample Dart library demonstrating DocuDart documentation generation.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  example_project: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Usage

Import the library and use the greeting function:

```dart
import 'package:example_project/example_project.dart';

void main() {
  final greeter = Greeter('World');
  print(greeter.greet()); // Hello, World!
}
```

## API Reference

### Greeter Class

The main class for generating greetings.

```dart
final greeter = Greeter('Alice');
greeter.greet(); // Returns "Hello, Alice!"
greeter.greetFormal(); // Returns "Good day, Alice."
```

### Calculator Class

A simple calculator for basic operations.

```dart
final calc = Calculator();
calc.add(2, 3); // Returns 5
calc.multiply(4, 5); // Returns 20
```

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

MIT License - see LICENSE file for details.
