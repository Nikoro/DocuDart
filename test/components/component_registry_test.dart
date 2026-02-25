import 'package:docudart/src/components/content/component_registry.dart';
import 'package:docudart/src/markdown/component_parser.dart';
import 'package:test/test.dart';

void main() {
  group('ComponentRegistry', () {
    test('register and hasComponent', () {
      final registry = ComponentRegistry();
      expect(registry.hasComponent('Custom'), isFalse);

      registry.register('Custom', (props, children) => '<div>custom</div>');
      expect(registry.hasComponent('Custom'), isTrue);
    });

    test('registeredNames returns all registered names', () {
      final registry = ComponentRegistry();
      registry.register('A', (_, _) => '');
      registry.register('B', (_, _) => '');
      expect(registry.registeredNames, equals({'A', 'B'}));
    });

    test('buildComponent returns null for unregistered component', () {
      final registry = ComponentRegistry();
      final component = EmbeddedComponent(
        name: 'Unknown',
        props: {},
        placeholderId: 'p0',
        position: 0,
      );
      expect(registry.buildComponent(component), isNull);
    });

    test('buildComponent calls factory with props and children', () {
      final registry = ComponentRegistry();
      registry.register('Test', (props, children) {
        return 'name=${props['name']},children=$children';
      });

      final component = EmbeddedComponent(
        name: 'Test',
        props: {'name': 'hello'},
        children: 'world',
        placeholderId: 'p0',
        position: 0,
      );
      expect(
        registry.buildComponent(component),
        equals('name=hello,children=world'),
      );
    });

    group('withBuiltIns', () {
      late ComponentRegistry registry;

      setUp(() {
        registry = ComponentRegistry.withBuiltIns();
      });

      test('registers all 6 built-in components', () {
        expect(
          registry.registeredNames,
          containsAll([
            'Callout',
            'Tabs',
            'Tab',
            'CodeBlock',
            'Card',
            'CardGrid',
          ]),
        );
      });

      group('Callout', () {
        EmbeddedComponent callout({
          Map<String, dynamic> props = const {},
          String? children,
        }) => .new(
          name: 'Callout',
          props: props,
          children: children,
          placeholderId: 'p0',
          position: 0,
        );

        test('renders with default type info', () {
          final html = registry.buildComponent(callout())!;
          expect(html, contains('callout-info'));
          expect(html, contains('ℹ️'));
        });

        test('renders with warning type', () {
          final html = registry.buildComponent(
            callout(props: {'type': 'warning'}),
          )!;
          expect(html, contains('callout-warning'));
          expect(html, contains('⚠️'));
        });

        test('renders with danger type', () {
          final html = registry.buildComponent(
            callout(props: {'type': 'danger'}),
          )!;
          expect(html, contains('callout-danger'));
          expect(html, contains('🚨'));
        });

        test('renders with tip type', () {
          final html = registry.buildComponent(
            callout(props: {'type': 'tip'}),
          )!;
          expect(html, contains('callout-tip'));
          expect(html, contains('💡'));
        });

        test('renders with note type', () {
          final html = registry.buildComponent(
            callout(props: {'type': 'note'}),
          )!;
          expect(html, contains('callout-note'));
          expect(html, contains('📝'));
        });

        test('unknown type falls back to info icon', () {
          final html = registry.buildComponent(
            callout(props: {'type': 'unknown'}),
          )!;
          expect(html, contains('callout-unknown'));
          expect(html, contains('ℹ️'));
        });

        test('renders title when provided', () {
          final html = registry.buildComponent(
            callout(props: {'title': 'Important'}),
          )!;
          expect(html, contains('callout-title'));
          expect(html, contains('Important'));
        });

        test('renders icon-only when no title', () {
          final html = registry.buildComponent(callout())!;
          expect(html, contains('callout-icon'));
          expect(html, isNot(contains('callout-title')));
        });

        test('renders children content', () {
          final html = registry.buildComponent(
            callout(children: 'Some content'),
          )!;
          expect(html, contains('Some content'));
          expect(html, contains('callout-content'));
        });
      });

      group('Tab', () {
        test('renders with label prop', () {
          final html = registry.buildComponent(
            EmbeddedComponent(
              name: 'Tab',
              props: {'label': 'JavaScript'},
              children: 'code here',
              placeholderId: 'p0',
              position: 0,
            ),
          )!;
          expect(html, contains('data-tab-id="javascript"'));
          expect(html, contains('data-tab-label="JavaScript"'));
          expect(html, contains('code here'));
        });

        test('defaults label to Tab', () {
          final html = registry.buildComponent(
            EmbeddedComponent(
              name: 'Tab',
              props: {},
              placeholderId: 'p0',
              position: 0,
            ),
          )!;
          expect(html, contains('data-tab-id="tab"'));
          expect(html, contains('data-tab-label="Tab"'));
        });

        test('slugifies label with spaces', () {
          final html = registry.buildComponent(
            EmbeddedComponent(
              name: 'Tab',
              props: {'label': 'My Tab'},
              placeholderId: 'p0',
              position: 0,
            ),
          )!;
          expect(html, contains('data-tab-id="my-tab"'));
        });
      });

      group('CodeBlock', () {
        EmbeddedComponent codeBlock({
          Map<String, dynamic> props = const {},
          String? children,
        }) => .new(
          name: 'CodeBlock',
          props: props,
          children: children,
          placeholderId: 'p0',
          position: 0,
        );

        test('renders with language class', () {
          final html = registry.buildComponent(
            codeBlock(props: {'language': 'dart'}),
          )!;
          expect(html, contains('language-dart'));
        });

        test('renders with title', () {
          final html = registry.buildComponent(
            codeBlock(props: {'title': 'example.dart'}),
          )!;
          expect(html, contains('code-block-title'));
          expect(html, contains('example.dart'));
        });

        test('renders without title by default', () {
          final html = registry.buildComponent(codeBlock())!;
          expect(html, isNot(contains('code-block-title')));
        });

        test('adds line-numbers class when enabled', () {
          final html = registry.buildComponent(
            codeBlock(props: {'lineNumbers': true}),
          )!;
          expect(html, contains('line-numbers'));
        });

        test('no line-numbers class by default', () {
          final html = registry.buildComponent(codeBlock())!;
          expect(html, isNot(contains('line-numbers')));
        });

        test('renders code from children', () {
          final html = registry.buildComponent(
            codeBlock(children: 'print("hello")'),
          )!;
          expect(html, contains('print("hello")'));
        });

        test('prefers code prop over children', () {
          final html = registry.buildComponent(
            codeBlock(props: {'code': 'from prop'}, children: 'from children'),
          )!;
          expect(html, contains('from prop'));
          expect(html, isNot(contains('from children')));
        });

        test('includes copy button with aria-label', () {
          final html = registry.buildComponent(codeBlock())!;
          expect(html, contains('copy-button'));
          expect(html, contains('aria-label="Copy code"'));
        });
      });

      group('Card', () {
        EmbeddedComponent card({
          Map<String, dynamic> props = const {},
          String? children,
        }) => .new(
          name: 'Card',
          props: props,
          children: children,
          placeholderId: 'p0',
          position: 0,
        );

        test('renders with title', () {
          final html = registry.buildComponent(
            card(props: {'title': 'My Card'}),
          )!;
          expect(html, contains('card-title'));
          expect(html, contains('My Card'));
        });

        test('renders with icon', () {
          final html = registry.buildComponent(card(props: {'icon': '🚀'}))!;
          expect(html, contains('card-icon'));
          expect(html, contains('🚀'));
        });

        test('renders without optional elements', () {
          final html = registry.buildComponent(card())!;
          expect(html, isNot(contains('card-title')));
          expect(html, isNot(contains('card-icon')));
        });

        test('wraps in link when href provided', () {
          final html = registry.buildComponent(
            card(props: {'href': '/docs/intro'}),
          )!;
          expect(html, contains('href="/docs/intro"'));
          expect(html, contains('card-link'));
        });

        test('no link wrapper without href', () {
          final html = registry.buildComponent(card())!;
          expect(html, isNot(contains('card-link')));
          expect(html, isNot(contains('href=')));
        });

        test('renders children content', () {
          final html = registry.buildComponent(
            card(children: 'Card body text'),
          )!;
          expect(html, contains('card-content'));
          expect(html, contains('Card body text'));
        });
      });

      group('CardGrid', () {
        test('defaults to 2 columns', () {
          final html = registry.buildComponent(
            EmbeddedComponent(
              name: 'CardGrid',
              props: {},
              children: '<div>cards</div>',
              placeholderId: 'p0',
              position: 0,
            ),
          )!;
          expect(html, contains('--card-grid-cols: 2'));
        });

        test('uses custom column count', () {
          final html = registry.buildComponent(
            EmbeddedComponent(
              name: 'CardGrid',
              props: {'cols': 3},
              children: '<div>cards</div>',
              placeholderId: 'p0',
              position: 0,
            ),
          )!;
          expect(html, contains('--card-grid-cols: 3'));
        });
      });

      group('Tabs', () {
        test('renders tabs container', () {
          final html = registry.buildComponent(
            EmbeddedComponent(
              name: 'Tabs',
              props: {},
              children: '<div>tab content</div>',
              placeholderId: 'p0',
              position: 0,
            ),
          )!;
          expect(html, contains('tabs-container'));
          expect(html, contains('tabs-list'));
          expect(html, contains('role="tablist"'));
          expect(html, contains('tabs-content'));
          expect(html, contains('tab content'));
        });
      });
    });
  });
}
