# Contributing to DocuDart

Thank you for your interest in contributing to DocuDart!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/<your-username>/docudart.git`
3. Install dependencies: `dart pub get`
4. Create a branch: `git checkout -b my-feature`

## Development

```bash
# Run the CLI locally
dart run bin/docudart.dart --help

# Analyze code
dart analyze lib bin

# Run tests
dart test

# Test with the example project
cd example
dart run ../bin/docudart.dart create --full
dart run ../bin/docudart.dart build
```

## Pull Requests

- Keep PRs focused on a single change
- Run `dart analyze` and `dart test` before submitting
- Add tests for new functionality
- Update documentation if behavior changes

## Reporting Issues

Use [GitHub Issues](https://github.com/Nikoro/docudart/issues) to report bugs or request features. Include:

- DocuDart version (`docudart version`)
- Dart SDK version (`dart --version`)
- Steps to reproduce
- Expected vs actual behavior

## Code Style

- Follow the existing code conventions
- Run `dart format .` before committing
- Keep the public API surface minimal (export only what users need)

## License

By contributing, you agree that your contributions will be licensed under the project's license.
