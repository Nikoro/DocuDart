/// A class for generating greetings.
class Greeter {
  /// The name to greet.
  final String name;

  /// Creates a new [Greeter] with the given [name].
  Greeter(this.name);

  /// Returns a friendly greeting.
  String greet() => 'Hello, $name!';

  /// Returns a formal greeting.
  String greetFormal() => 'Good day, $name.';
}
