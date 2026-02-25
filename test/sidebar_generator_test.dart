import 'package:test/test.dart';
import 'package:docudart/src/generators/sidebar_generator.dart';
import 'package:docudart/src/models/doc.dart';
import 'package:docudart/src/models/doc_content.dart';
import 'package:docudart/src/markdown/frontmatter_handler.dart';

void main() {
  group('SidebarGenerator', () {
    test('empty root folder returns empty list', () {
      final root = DocFolder(
        relativePath: '',
        name: 'Docs',
        order: 0,
        pages: [],
        folders: [],
      );

      final result = SidebarGenerator.generate(rootFolder: root);

      expect(result, isEmpty);
    });

    test('pages become DocLink items with correct name, path, order', () {
      final root = DocFolder(
        relativePath: '',
        name: 'Docs',
        order: 0,
        pages: [
          DocPage(
            relativePath: 'getting-started.md',
            urlPath: '/docs/getting-started',
            meta: const PageMeta(title: 'Getting Started'),
            html: '<p>Content</p>',
            toc: const [],
            order: 1,
          ),
          DocPage(
            relativePath: 'installation.md',
            urlPath: '/docs/installation',
            meta: const PageMeta(title: 'Installation'),
            html: '<p>Content</p>',
            toc: const [],
            order: 2,
          ),
        ],
        folders: [],
      );

      final result = SidebarGenerator.generate(rootFolder: root);

      expect(result.length, equals(2));

      final DocLink(:name, :path, :order) = result[0] as DocLink;
      expect(name, equals('Getting Started'));
      expect(path, equals('/docs/getting-started'));
      expect(order, equals(1));

      final DocLink(name: secondName, path: secondPath, order: secondOrder) =
          result[1] as DocLink;
      expect(secondName, equals('Installation'));
      expect(secondPath, equals('/docs/installation'));
      expect(secondOrder, equals(2));
    });

    test('subfolders become DocCategory items with children', () {
      final root = DocFolder(
        relativePath: '',
        name: 'Docs',
        order: 0,
        pages: [],
        folders: [
          DocFolder(
            relativePath: 'guides',
            name: 'Guides',
            order: 1,
            pages: [
              DocPage(
                relativePath: 'guides/intro.md',
                urlPath: '/docs/guides/intro',
                meta: const PageMeta(title: 'Intro'),
                html: '<p>Content</p>',
                toc: const [],
                order: 0,
              ),
            ],
            folders: [],
          ),
        ],
      );

      final result = SidebarGenerator.generate(rootFolder: root);

      expect(result.length, equals(1));

      final category = result[0] as DocCategory;
      expect(category.name, equals('Guides'));
      expect(category.children.length, equals(1));

      final child = category.children[0] as DocLink;
      expect(child.name, equals('Intro'));
      expect(child.path, equals('/docs/guides/intro'));
    });

    test('pages with showInSidebar false are excluded', () {
      final root = DocFolder(
        relativePath: '',
        name: 'Docs',
        order: 0,
        pages: [
          DocPage(
            relativePath: 'visible.md',
            urlPath: '/docs/visible',
            meta: const PageMeta(title: 'Visible'),
            html: '<p>Content</p>',
            toc: const [],
            order: 1,
          ),
          DocPage(
            relativePath: 'hidden.md',
            urlPath: '/docs/hidden',
            meta: const PageMeta(title: 'Hidden', showInSidebar: false),
            html: '<p>Content</p>',
            toc: const [],
            order: 2,
          ),
        ],
        folders: [],
      );

      final result = SidebarGenerator.generate(rootFolder: root);

      expect(result.length, equals(1));
      expect((result[0] as DocLink).name, equals('Visible'));
    });

    test('nested folders create nested DocCategory', () {
      final root = DocFolder(
        relativePath: '',
        name: 'Docs',
        order: 0,
        pages: [],
        folders: [
          DocFolder(
            relativePath: 'advanced',
            name: 'Advanced',
            order: 1,
            pages: [],
            folders: [
              DocFolder(
                relativePath: 'advanced/deployment',
                name: 'Deployment',
                order: 1,
                pages: [
                  DocPage(
                    relativePath: 'advanced/deployment/github-pages.md',
                    urlPath: '/docs/advanced/deployment/github-pages',
                    meta: const PageMeta(title: 'GitHub Pages'),
                    html: '<p>Content</p>',
                    toc: const [],
                    order: 1,
                  ),
                ],
                folders: [],
              ),
            ],
          ),
        ],
      );

      final result = SidebarGenerator.generate(rootFolder: root);

      expect(result.length, equals(1));

      final outerCategory = result[0] as DocCategory;
      expect(outerCategory.name, equals('Advanced'));
      expect(outerCategory.children.length, equals(1));

      final innerCategory = outerCategory.children[0] as DocCategory;
      expect(innerCategory.name, equals('Deployment'));
      expect(innerCategory.children.length, equals(1));

      final leaf = innerCategory.children[0] as DocLink;
      expect(leaf.name, equals('GitHub Pages'));
    });

    test('expanded flag propagates from DocFolder to DocCategory', () {
      final root = DocFolder(
        relativePath: '',
        name: 'Docs',
        order: 0,
        pages: [],
        folders: [
          DocFolder(
            relativePath: 'guides',
            name: 'Guides',
            order: 1,
            expanded: true,
            pages: [
              DocPage(
                relativePath: 'guides/intro.md',
                urlPath: '/docs/guides/intro',
                meta: const PageMeta(title: 'Intro'),
                html: '',
                toc: const [],
                order: 0,
              ),
            ],
            folders: [],
          ),
          DocFolder(
            relativePath: 'advanced',
            name: 'Advanced',
            order: 2,
            expanded: false,
            pages: [
              DocPage(
                relativePath: 'advanced/config.md',
                urlPath: '/docs/advanced/config',
                meta: const PageMeta(title: 'Config'),
                html: '',
                toc: const [],
                order: 0,
              ),
            ],
            folders: [],
          ),
        ],
      );

      final result = SidebarGenerator.generate(rootFolder: root);

      expect(result.length, equals(2));

      final guidesCategory = result[0] as DocCategory;
      expect(guidesCategory.name, equals('Guides'));
      expect(guidesCategory.expanded, isTrue);

      final advancedCategory = result[1] as DocCategory;
      expect(advancedCategory.name, equals('Advanced'));
      expect(advancedCategory.expanded, isFalse);
    });

    test('empty subfolders are excluded', () {
      final root = DocFolder(
        relativePath: '',
        name: 'Docs',
        order: 0,
        pages: [
          DocPage(
            relativePath: 'index.md',
            urlPath: '/docs',
            meta: const PageMeta(title: 'Home'),
            html: '',
            toc: const [],
            order: 0,
          ),
        ],
        folders: [
          DocFolder(
            relativePath: 'empty',
            name: 'Empty',
            order: 1,
            pages: [],
            folders: [],
          ),
        ],
      );

      final result = SidebarGenerator.generate(rootFolder: root);

      // Only the page should be present, not the empty folder
      expect(result.length, equals(1));
      expect(result[0], isA<DocLink>());
    });

    test('uses sidebarTitle from meta when available', () {
      final root = DocFolder(
        relativePath: '',
        name: 'Docs',
        order: 0,
        pages: [
          DocPage(
            relativePath: 'long-page-name.md',
            urlPath: '/docs/long-page-name',
            meta: const PageMeta(
              title: 'Very Long Page Name',
              sidebarTitle: 'Short',
            ),
            html: '',
            toc: const [],
            order: 1,
          ),
        ],
        folders: [],
      );

      final result = SidebarGenerator.generate(rootFolder: root);

      // sidebarTitle should be used as the DocLink name
      final link = result[0] as DocLink;
      expect(link.name, equals('Short'));
    });
  });
}
