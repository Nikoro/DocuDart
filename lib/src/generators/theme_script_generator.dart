import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/docudart_config.dart';

/// Generates theme.js, live-reload.js, and manages the live-reload version file.
class ThemeScriptGenerator {
  ThemeScriptGenerator(this.config, this.managedDir);

  final Config config;
  final String managedDir;

  /// Generate theme.js in the given [webDir].
  Future<void> generateThemeScript(String webDir) async {
    final mode = config.themeMode.name; // 'system', 'light', or 'dark'

    final themeScript =
        '''
(function() {
  var forcedMode = '$mode'; // from config.themeMode

  // Apply initial theme: forced mode overrides localStorage
  if (forcedMode === 'light' || forcedMode === 'dark') {
    document.documentElement.setAttribute('data-theme', forcedMode);
  } else {
    var stored = localStorage.getItem('docudart-theme');
    if (stored) {
      document.documentElement.setAttribute('data-theme', stored);
    }
  }

  function updateToggleAria(theme) {
    var btn = document.querySelector('.theme-toggle');
    if (!btn) return;
    var label = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
    btn.setAttribute('aria-label', label);
    btn.setAttribute('title', label);
  }

  // Set initial ARIA label based on resolved theme
  function initToggleAria() {
    var current = document.documentElement.getAttribute('data-theme');
    if (!current) {
      current = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }
    updateToggleAria(current);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initToggleAria);
  } else {
    initToggleAria();
  }

  document.addEventListener('click', function(e) {
    var btn = e.target.closest('.theme-toggle');
    if (!btn) return;

    var current = document.documentElement.getAttribute('data-theme');
    var isDark;
    if (current === 'dark') {
      isDark = false;
    } else if (current === 'light') {
      isDark = true;
    } else {
      isDark = !window.matchMedia('(prefers-color-scheme: dark)').matches;
    }

    var next = isDark ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('docudart-theme', next);
    updateToggleAria(next);
  });
})();

// Sidebar: collapsible categories + active link highlighting
(function() {
  var STORAGE_KEY = 'docudart-sidebar-state';

  function loadState() {
    try {
      var stored = localStorage.getItem(STORAGE_KEY);
      return stored ? JSON.parse(stored) : {};
    } catch(e) { return {}; }
  }

  function saveState(state) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch(e) {}
  }

  function initCollapse() {
    var state = loadState();
    var categories = document.querySelectorAll('.expansion-tile[data-category]');

    // Suppress transitions during state restoration to prevent visual flash
    categories.forEach(function(cat) {
      var content = cat.querySelector('.expansion-tile-content');
      if (content) content.style.transition = 'none';
    });

    categories.forEach(function(cat) {
      var id = cat.getAttribute('data-category');
      if (state.hasOwnProperty(id)) {
        cat.setAttribute('data-collapsed', state[id] ? 'true' : 'false');
      }
    });

    // Force reflow then re-enable transitions
    void document.body.offsetHeight;
    categories.forEach(function(cat) {
      var content = cat.querySelector('.expansion-tile-content');
      if (content) content.style.transition = '';
    });
  }

  // Click handler for expansion tile headers
  document.addEventListener('click', function(e) {
    var title = e.target.closest('.expansion-tile-header');
    if (!title) return;

    var cat = title.closest('.expansion-tile');
    if (!cat) return;

    var id = cat.getAttribute('data-category');
    var isCollapsed = cat.getAttribute('data-collapsed') === 'true';

    cat.setAttribute('data-collapsed', isCollapsed ? 'false' : 'true');

    var currentState = loadState();
    currentState[id] = !isCollapsed;
    saveState(currentState);
  });

  // Keyboard accessibility for expansion tile headers
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' || e.key === ' ') {
      var title = e.target.closest('.expansion-tile-header');
      if (title) {
        e.preventDefault();
        title.click();
      }
    }
  });

  // Active link highlighting
  function expandParents(element) {
    var state = loadState();
    var parent = element.closest('.expansion-tile');
    while (parent) {
      parent.setAttribute('data-collapsed', 'false');
      var id = parent.getAttribute('data-category');
      if (id) state[id] = false;
      var grandparent = parent.parentElement;
      parent = grandparent ? grandparent.closest('.expansion-tile') : null;
    }
    saveState(state);
  }

  function updateActiveLink() {
    var path = window.location.pathname;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.slice(0, -1);
    }

    var links = document.querySelectorAll('.sidebar-link[data-path]');
    var found = false;
    links.forEach(function(link) {
      var linkPath = link.getAttribute('data-path');
      if (linkPath && linkPath.length > 1 && linkPath.endsWith('/')) {
        linkPath = linkPath.slice(0, -1);
      }

      if (linkPath === path) {
        link.classList.add('active');
        expandParents(link);
        found = true;
      } else {
        link.classList.remove('active');
      }
    });

    // Header nav links: prefix matching (e.g. /docs matches /docs/getting-started)
    var navLinks = document.querySelectorAll('header .nav-link[data-path]');
    navLinks.forEach(function(link) {
      var linkPath = link.getAttribute('data-path');
      if (linkPath && linkPath.length > 1 && linkPath.endsWith('/')) {
        linkPath = linkPath.slice(0, -1);
      }

      if (path === linkPath || path.startsWith(linkPath + '/')) {
        link.classList.add('active');
      } else {
        link.classList.remove('active');
      }
    });
  }

  // SPA navigation detection
  var _pushState = history.pushState;
  var _replaceState = history.replaceState;

  history.pushState = function() {
    _pushState.apply(history, arguments);
    window.dispatchEvent(new Event('docudart-navigate'));
  };

  history.replaceState = function() {
    _replaceState.apply(history, arguments);
    window.dispatchEvent(new Event('docudart-navigate'));
  };

  window.addEventListener('popstate', function() {
    setTimeout(function() {
      updateActiveLink();
      highlightCode();
    }, 50);
  });

  window.addEventListener('docudart-navigate', function() {
    setTimeout(function() {
      updateActiveLink();
      highlightCode();
    }, 50);
  });

  // MutationObserver: re-apply if Jaspr re-renders sidebar
  function startObserver() {
    var sidebar = document.querySelector('.sidebar');
    if (!sidebar) return;
    var observer = new MutationObserver(function() {
      initCollapse();
      updateActiveLink();
    });
    observer.observe(sidebar, { childList: true, subtree: true });
  }

  // Strip SSR indentation that Jaspr adds inside <pre> blocks.
  // The last line before </code> is whitespace-only SSR indent — use it
  // as the exact amount to strip from all subsequent lines.
  function normalizeCodeBlocks() {
    document.querySelectorAll('pre code').forEach(function(block) {
      if (block.getAttribute('data-normalized')) return;
      var text = block.textContent;
      var lines = text.split('\\n');
      // Detect SSR indent from the trailing whitespace-only line
      var indent = 0;
      if (lines.length > 1) {
        var last = lines[lines.length - 1];
        if (last.trim() === '') {
          indent = last.length;
        }
      }
      // Remove trailing empty lines
      while (lines.length && lines[lines.length - 1].trim() === '') lines.pop();
      if (lines.length === 0) { block.setAttribute('data-normalized', 'true'); return; }
      // Strip the detected SSR indent from lines 1+ (line 0 is on <code> tag line)
      if (indent > 0) {
        var re = new RegExp('^' + ' '.repeat(indent), '');
        for (var j = 1; j < lines.length; j++) {
          lines[j] = lines[j].replace(re, '');
        }
      }
      block.textContent = lines.join('\\n') + '\\n';
      block.setAttribute('data-normalized', 'true');
    });
  }

  // Syntax highlighting via highlight.js
  function highlightCode() {
    normalizeCodeBlocks();
    if (typeof hljs !== 'undefined') {
      document.querySelectorAll('pre code').forEach(function(block) {
        if (!block.getAttribute('data-highlighted')) {
          hljs.highlightElement(block);
        }
      });
    }
  }

  // Mobile sidebar drawer toggle
  function initMobileMenu() {
    document.addEventListener('click', function(e) {
      var btn = e.target.closest('.mobile-menu-btn');
      if (btn) {
        e.preventDefault();
        document.body.classList.toggle('sidebar-open');
        return;
      }

      var backdrop = e.target.closest('.sidebar-backdrop');
      if (backdrop) {
        document.body.classList.remove('sidebar-open');
        return;
      }

      // Close sidebar when a sidebar link is clicked (mobile navigation)
      if (document.body.classList.contains('sidebar-open')) {
        var link = e.target.closest('.sidebar-link');
        if (link) {
          document.body.classList.remove('sidebar-open');
        }
      }
    });
  }

  function init() {
    initCollapse();
    updateActiveLink();
    highlightCode();
    startObserver();
    initMobileMenu();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
''';
    await File(p.join(webDir, 'theme.js')).writeAsString(themeScript);
  }

  /// Generate live-reload.js in the given [webDir].
  Future<void> generateLiveReload(String webDir) async {
    // Write initial version file
    await bumpLiveReloadVersion();

    final script = '''
(function() {
  var currentVersion = null;
  var url = '/live-reload-version.txt';

  function poll() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url + '?t=' + Date.now(), true);
    xhr.timeout = 2000;
    xhr.onload = function() {
      if (xhr.status === 200) {
        var version = xhr.responseText.trim();
        if (currentVersion === null) {
          currentVersion = version;
        } else if (version !== currentVersion) {
          console.log('[docudart] Reloading...');
          location.reload();
        }
      }
    };
    xhr.send();
  }

  setInterval(poll, 1000);
})();
''';
    await File(p.join(webDir, 'live-reload.js')).writeAsString(script);
  }

  /// Writes a new version timestamp to the live-reload version file.
  /// Called after each regeneration during serve mode.
  Future<void> bumpLiveReloadVersion() async {
    final webDir = p.join(managedDir, 'web');
    await Directory(webDir).create(recursive: true);
    await File(
      p.join(webDir, 'live-reload-version.txt'),
    ).writeAsString(DateTime.now().millisecondsSinceEpoch.toString());
  }
}
