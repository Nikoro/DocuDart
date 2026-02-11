import 'dart:io';

/// Custom exception for DocuDart errors with helpful messages.
class DocuDartException implements Exception {
  const DocuDartException(this.message, {this.hint, this.command});
  final String message;
  final String? hint;
  final String? command;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Error: $message');
    if (hint != null) {
      buffer.writeln('');
      buffer.writeln('Hint: $hint');
    }
    if (command != null) {
      buffer.writeln('');
      buffer.writeln('Try: $command');
    }
    return buffer.toString();
  }
}

/// Error types for common issues.
class DocuDartErrors {
  DocuDartErrors._();

  /// Config file not found.
  static DocuDartException configNotFound() {
    return const DocuDartException(
      'DocuDart project not found.',
      hint:
          'Make sure you are in a project with a docudart/ directory, '
          'or inside the docudart/ directory itself.',
      command: 'docudart create',
    );
  }

  /// Docs directory not found.
  static DocuDartException docsNotFound(String docsDir) {
    return DocuDartException(
      'Documentation directory "$docsDir" not found.',
      hint: 'Create the directory or update docsDir in config.dart.',
    );
  }

  /// No markdown files found.
  static DocuDartException noDocsFound(String docsDir) {
    return DocuDartException(
      'No markdown files found in "$docsDir".',
      hint: 'Add .md files to your docs directory.',
    );
  }

  /// Version directory not found.
  static DocuDartException versionNotFound(String version, String versionDir) {
    return DocuDartException(
      'Version "$version" directory not found at "$versionDir".',
      hint: 'Create the version directory or remove it from config.dart.',
    );
  }

  /// Build failed.
  static DocuDartException buildFailed(String error) {
    return DocuDartException(
      'Build failed.',
      hint: error.isNotEmpty ? error : 'Check the output above for details.',
    );
  }

  /// Dependency not found.
  static DocuDartException dependencyNotFound(String dependency) {
    return DocuDartException(
      'Required dependency "$dependency" not found.',
      hint: 'Make sure $dependency is installed and available in PATH.',
    );
  }

  /// Invalid config.
  static DocuDartException invalidConfig(String details) {
    return DocuDartException(
      'Invalid configuration in config.dart.',
      hint: details,
    );
  }

  /// Port in use.
  static DocuDartException portInUse(int port) {
    return DocuDartException(
      'Port $port is already in use.',
      hint: 'Try a different port.',
      command: 'docudart serve --port ${port + 1}',
    );
  }

  /// File read error.
  static DocuDartException fileReadError(String path, String error) {
    return DocuDartException('Failed to read file: $path', hint: error);
  }

  /// Markdown parse error.
  static DocuDartException markdownParseError(String path, String error) {
    return DocuDartException(
      'Failed to parse markdown file: $path',
      hint: error,
    );
  }

  /// Invalid frontmatter.
  static DocuDartException invalidFrontmatter(String path, String error) {
    return DocuDartException('Invalid YAML frontmatter in: $path', hint: error);
  }
}

/// Utility class for printing styled CLI messages.
class CliPrinter {
  CliPrinter._();

  /// Print an error message.
  static void error(String message) {
    stderr.writeln('❌ $message');
  }

  /// Print a success message.
  static void success(String message) {
    print('✅ $message');
  }

  /// Print an info message.
  static void info(String message) {
    print('ℹ️  $message');
  }

  /// Print a warning message.
  static void warning(String message) {
    print('⚠️  $message');
  }

  /// Print a step message.
  static void step(String message) {
    print('→ $message');
  }

  /// Print a DocuDartException with formatting.
  static void exception(DocuDartException e) {
    error(e.message);
    if (e.hint != null) {
      print('');
      print('   Hint: ${e.hint}');
    }
    if (e.command != null) {
      print('');
      print('   Try: ${e.command}');
    }
  }

  /// Print a progress indicator.
  static void progress(String message) {
    stdout.write('$message... ');
  }

  /// Complete a progress indicator.
  static void done() {
    print('done');
  }

  /// Print a blank line.
  static void blank() {
    print('');
  }

  /// Print a divider.
  static void divider() {
    print('─' * 40);
  }

  /// Print a header.
  static void header(String title) {
    print('');
    print('═══ $title ═══');
    print('');
  }
}
