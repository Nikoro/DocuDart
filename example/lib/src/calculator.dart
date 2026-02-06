/// A simple calculator for basic operations.
class Calculator {
  /// Adds two numbers.
  int add(int a, int b) => a + b;

  /// Subtracts [b] from [a].
  int subtract(int a, int b) => a - b;

  /// Multiplies two numbers.
  int multiply(int a, int b) => a * b;

  /// Divides [a] by [b].
  ///
  /// Throws [ArgumentError] if [b] is zero.
  double divide(int a, int b) {
    if (b == 0) throw ArgumentError('Cannot divide by zero');
    return a / b;
  }
}
