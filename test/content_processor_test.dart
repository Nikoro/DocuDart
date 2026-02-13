import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:docudart/docudart.dart';
import 'package:docudart/src/processing/content_processor.dart';

void main() {
  late Directory tempDir;
  late String docsPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('content_processor_test_');
    docsPath = p.join(tempDir.path, 'docs');
    Directory(docsPath).createSync();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  ContentProcessor makeProcessor() {
    return ContentProcessor(Config(docsDir: docsPath));
  }

  Future<void> writeDoc(String relativePath, String content) async {
    final file = File(p.join(docsPath, relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  group('processAll', () {
    test('returns empty results for non-existent docs directory', () async {
      final processor = ContentProcessor(
        Config(docsDir: p.join(tempDir.path, 'nonexistent')),
      );
      final (pages, rootFolder) = await processor.processAll();

      expect(pages, isEmpty);
      expect(rootFolder.name, equals('Docs'));
    });

    test('returns empty results for empty docs directory', () async {
      final processor = makeProcessor();
      final (pages, rootFolder) = await processor.processAll();

      expect(pages, isEmpty);
      expect(rootFolder.pages, isEmpty);
    });

    test('processes a single markdown file', () async {
      await writeDoc('intro.md', '# Introduction\n\nWelcome to the docs.');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages, hasLength(1));
      expect(pages.first.urlPath, equals('/docs/intro'));
      expect(pages.first.html, contains('Introduction'));
    });

    test('processes multiple files sorted by order', () async {
      await writeDoc('02-guide.md', '# Guide');
      await writeDoc('01-intro.md', '# Intro');
      await writeDoc('03-api.md', '# API');

      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages, hasLength(3));
      expect(pages[0].order, equals(1));
      expect(pages[1].order, equals(2));
      expect(pages[2].order, equals(3));
    });

    test('skips hidden files', () async {
      await writeDoc('.hidden.md', '# Hidden');
      await writeDoc('visible.md', '# Visible');

      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages, hasLength(1));
      expect(pages.first.html, contains('Visible'));
    });
  });

  group('URL path generation', () {
    test('simple file gets /docs/name path', () async {
      await writeDoc('getting-started.md', '# Getting Started');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.urlPath, equals('/docs/getting-started'));
    });

    test('index file maps to /docs', () async {
      await writeDoc('index.md', '# Index');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.urlPath, equals('/docs'));
    });

    test('intro file maps to /docs/intro', () async {
      await writeDoc('intro.md', '# Intro');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      // intro is only special-cased for order (0), not for URL
      expect(pages.first.urlPath, equals('/docs/intro'));
    });

    test('numeric prefix is stripped from URL', () async {
      await writeDoc('01-getting-started.md', '# Getting Started');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.urlPath, equals('/docs/getting-started'));
    });

    test('nested file gets /docs/folder/name path', () async {
      await writeDoc('guides/setup.md', '# Setup');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.urlPath, equals('/docs/guides/setup'));
    });

    test('index file in subfolder maps to /docs/folder', () async {
      await writeDoc('guides/index.md', '# Guides');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.urlPath, equals('/docs/guides'));
    });

    test('numeric prefix stripped from folder names in URL', () async {
      await writeDoc('01-guides/setup.md', '# Setup');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.urlPath, equals('/docs/guides/setup'));
    });

    test('_expanded suffix stripped from folder names in URL', () async {
      await writeDoc('guides_expanded/setup.md', '# Setup');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.urlPath, equals('/docs/guides/setup'));
    });

    test('path containing "index" as substring is preserved', () async {
      await writeDoc('indexing-guide.md', '# Indexing Guide');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.urlPath, equals('/docs/indexing-guide'));
    });
  });

  group('order extraction', () {
    test('numeric prefix determines order', () async {
      await writeDoc('05-advanced.md', '# Advanced');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.order, equals(5));
    });

    test('intro/index files get order 0', () async {
      await writeDoc('intro.md', '# Intro');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.order, equals(0));
    });

    test('files without prefix get order 999', () async {
      await writeDoc('random-page.md', '# Random');
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.order, equals(999));
    });

    test('frontmatter sidebar_position overrides file order', () async {
      await writeDoc(
        '05-advanced.md',
        '---\nsidebar_position: 2\n---\n# Advanced',
      );
      final processor = makeProcessor();
      final (pages, _) = await processor.processAll();

      expect(pages.first.order, equals(2));
    });
  });

  group('folder structure', () {
    test('subfolder becomes DocFolder with correct name', () async {
      await writeDoc('getting-started/install.md', '# Install');
      final processor = makeProcessor();
      final (_, rootFolder) = await processor.processAll();

      expect(rootFolder.folders, hasLength(1));
      expect(rootFolder.folders.first.name, equals('Getting Started'));
    });

    test('folder with _expanded suffix is marked expanded', () async {
      await writeDoc('guides_expanded/setup.md', '# Setup');
      final processor = makeProcessor();
      final (_, rootFolder) = await processor.processAll();

      expect(rootFolder.folders, hasLength(1));
      expect(rootFolder.folders.first.expanded, isTrue);
      expect(rootFolder.folders.first.name, equals('Guides'));
    });

    test('folder without _expanded suffix is not expanded', () async {
      await writeDoc('guides/setup.md', '# Setup');
      final processor = makeProcessor();
      final (_, rootFolder) = await processor.processAll();

      expect(rootFolder.folders.first.expanded, isFalse);
    });

    test('numeric prefix determines folder order', () async {
      await writeDoc('02-advanced/page.md', '# Page');
      await writeDoc('01-basics/page.md', '# Page');
      final processor = makeProcessor();
      final (_, rootFolder) = await processor.processAll();

      expect(rootFolder.folders, hasLength(2));
      expect(rootFolder.folders[0].order, equals(1));
      expect(rootFolder.folders[1].order, equals(2));
    });

    test('numeric prefix stripped from folder display name', () async {
      await writeDoc('01-getting-started/intro.md', '# Intro');
      final processor = makeProcessor();
      final (_, rootFolder) = await processor.processAll();

      expect(rootFolder.folders.first.name, equals('Getting Started'));
    });
  });

  group('processFile', () {
    test('returns null for non-existent file', () async {
      final processor = makeProcessor();
      final result = await processor.processFile(
        p.join(docsPath, 'nonexistent.md'),
      );

      expect(result, isNull);
    });

    test('processes a single file correctly', () async {
      await writeDoc('guide.md', '# Guide\n\nSome content here.');
      final processor = makeProcessor();
      final result = await processor.processFile(
        p.join(docsPath, 'guide.md'),
      );

      expect(result, isNotNull);
      expect(result!.urlPath, equals('/docs/guide'));
      expect(result.html, contains('Guide'));
      expect(result.html, contains('Some content here'));
    });
  });
}
