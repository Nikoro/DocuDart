import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

/// A client-side component that highlights the active TOC link based on scroll.
///
/// Uses Jaspr's `@client` annotation for client-side hydration.
/// On the client, sets up an [IntersectionObserver] to watch heading elements
/// and toggles the `active` class on corresponding `.toc-link` elements.
///
/// Renders nothing on the server — the visual TOC is rendered by
/// [TableOfContents]. Place this component alongside [TableOfContents]:
///
/// ```dart
/// Row(children: [
///   Expanded(child: div(classes: 'docs-content', [RawText(html)])),
///   TableOfContents(entries: toc),
///   TocScrollSpy(),
/// ])
/// ```
@client
class TocScrollSpy extends StatefulComponent {
  const TocScrollSpy({super.key});

  @override
  State<TocScrollSpy> createState() => _TocScrollSpyState();
}

class _TocScrollSpyState extends State<TocScrollSpy> {
  web.IntersectionObserver? _observer;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _setupScrollSpy();
    }
  }

  void _setupScrollSpy() {
    final nodeList = web.document.querySelectorAll('.toc-link[data-toc-id]');
    if (nodeList.length == 0) return;

    // Collect TOC link elements and their target heading IDs.
    final tocLinks = <web.Element>[];
    final headingIds = <String>[];
    for (var i = 0; i < nodeList.length; i++) {
      final node = nodeList.item(i);
      if (node == null) continue;
      final element = node as web.Element;
      final id = element.getAttribute('data-toc-id');
      if (id != null) {
        tocLinks.add(element);
        headingIds.add(id);
      }
    }

    if (tocLinks.isEmpty) return;

    // Collect corresponding heading elements.
    final headings = <web.Element>[];
    for (final id in headingIds) {
      final heading = web.document.getElementById(id);
      if (heading != null) headings.add(heading);
    }

    if (headings.isEmpty) return;

    String? currentActive;

    void setActive(String id) {
      if (currentActive == id) return;
      currentActive = id;
      for (final link in tocLinks) {
        if (link.getAttribute('data-toc-id') == id) {
          link.classList.add('active');
        } else {
          link.classList.remove('active');
        }
      }
    }

    // IntersectionObserver callback: find the topmost visible heading
    // or fall back to the last heading scrolled past.
    void onIntersection(
      JSArray<web.IntersectionObserverEntry> entries,
      web.IntersectionObserver observer,
    ) {
      // Check for any intersecting heading.
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        if (entry.isIntersecting) {
          setActive(entry.target.getAttribute('id') ?? '');
          return;
        }
      }

      // No heading is intersecting — activate the last heading above viewport.
      web.Element? lastAbove;
      for (final h in headings) {
        if (h.getBoundingClientRect().top < 100) {
          lastAbove = h;
        }
      }
      if (lastAbove != null) {
        setActive(lastAbove.getAttribute('id') ?? '');
      }
    }

    _observer = web.IntersectionObserver(
      onIntersection.toJS,
      web.IntersectionObserverInit(rootMargin: '-64px 0px -80% 0px'),
    );

    for (final h in headings) {
      _observer!.observe(h);
    }
  }

  @override
  void dispose() {
    _observer?.disconnect();
    _observer = null;
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return Component.fragment([]);
  }
}
