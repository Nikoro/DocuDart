import 'package:test/test.dart';
import 'package:docudart/src/processing/readme_parser.dart';

void main() {
  group('ReadmeParser', () {
    test('parses empty content', () {
      final sections = ReadmeParser.parse('');
      expect(sections, isEmpty);
    });

    test('parses content with no headings as introduction', () {
      final sections = ReadmeParser.parse(
        'This is some content without headings.',
      );

      expect(sections.length, equals(1));
      expect(sections.first.title, equals('Introduction'));
      expect(sections.first.content, contains('without headings'));
    });

    test('parses level 2 headings as sections', () {
      final content = '''
## Getting Started

Getting started content.

## Installation

Installation content.

## Usage

Usage content.
''';

      final sections = ReadmeParser.parse(content);

      expect(sections.length, equals(3));
      expect(sections[0].title, equals('Getting Started'));
      expect(sections[1].title, equals('Installation'));
      expect(sections[2].title, equals('Usage'));
    });

    test('skips license and contributing sections', () {
      final content = '''
## Features

Feature list.

## License

MIT

## Contributing

How to contribute.
''';

      final sections = ReadmeParser.parse(content);

      expect(sections.length, equals(1));
      expect(sections.first.title, equals('Features'));
    });

    test('parses content after H1 as section', () {
      final content = '''
# My Project

This is my project description.

## Features

Cool features here.
''';

      final sections = ReadmeParser.parse(content);

      // Should have Features section
      expect(sections.any((e) => e.title == 'Features'), isTrue);
    });

    test('generates correct filenames', () {
      final content = '''
## Getting Started

Content.

## API Reference

API docs.

## FAQ & Troubleshooting

Help content.
''';

      final sections = ReadmeParser.parse(content);

      expect(sections[0].filename, equals('index'));
      expect(sections[1].filename, equals('api-reference'));
      expect(sections[2].filename, equals('faq-troubleshooting'));
    });

    test('assigns correct positions', () {
      final content = '''
## First

Content 1.

## Second

Content 2.

## Third

Content 3.
''';

      final sections = ReadmeParser.parse(content);

      expect(sections[0].position, equals(1));
      expect(sections[1].position, equals(2));
      expect(sections[2].position, equals(3));
    });

    test('preserves subsections within main sections', () {
      final content = '''
## Installation

Main installation content.

### Prerequisites

You need Node.js.

### Steps

1. Clone the repo
2. Install dependencies
''';

      final sections = ReadmeParser.parse(content);

      // All subsections should be part of the Installation section
      expect(sections.first.title, equals('Installation'));
      expect(sections.first.content, contains('Prerequisites'));
      expect(sections.first.content, contains('Steps'));
    });
  });
}
