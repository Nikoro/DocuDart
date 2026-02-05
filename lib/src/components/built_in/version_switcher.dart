/// CSS styles for the VersionSwitcher component.
const versionSwitcherStyles = '''
/* Version Switcher Component */
.version-switcher {
  position: relative;
  display: inline-block;
}

.version-switcher-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 0.375rem;
  cursor: pointer;
  transition: all 0.15s;
}

.version-switcher-button:hover {
  background-color: var(--color-background);
  border-color: var(--color-primary);
}

.version-switcher-button svg {
  width: 1rem;
  height: 1rem;
  transition: transform 0.2s;
}

.version-switcher.open .version-switcher-button svg {
  transform: rotate(180deg);
}

.version-switcher-dropdown {
  position: absolute;
  top: calc(100% + 0.25rem);
  right: 0;
  min-width: 180px;
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 0.5rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  opacity: 0;
  visibility: hidden;
  transform: translateY(-0.5rem);
  transition: all 0.2s;
  z-index: 50;
}

.version-switcher.open .version-switcher-dropdown {
  opacity: 1;
  visibility: visible;
  transform: translateY(0);
}

.version-switcher-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.625rem 1rem;
  font-size: 0.875rem;
  color: var(--color-text);
  text-decoration: none;
  transition: background-color 0.15s;
}

.version-switcher-item:first-child {
  border-radius: 0.5rem 0.5rem 0 0;
}

.version-switcher-item:last-child {
  border-radius: 0 0 0.5rem 0.5rem;
}

.version-switcher-item:hover {
  background-color: var(--color-background);
}

.version-switcher-item.active {
  color: var(--color-primary);
  font-weight: 500;
}

.version-switcher-item .badge {
  display: inline-flex;
  padding: 0.125rem 0.5rem;
  font-size: 0.625rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-radius: 9999px;
}

.version-switcher-item .badge-latest {
  color: #059669;
  background-color: #d1fae5;
}

.version-switcher-item .badge-default {
  color: #0284c7;
  background-color: #e0f2fe;
}

/* Dark mode badge colors */
@media (prefers-color-scheme: dark) {
  .version-switcher-item .badge-latest {
    color: #34d399;
    background-color: rgba(52, 211, 153, 0.15);
  }

  .version-switcher-item .badge-default {
    color: #38bdf8;
    background-color: rgba(56, 189, 248, 0.15);
  }
}

/* Version banner for non-latest versions */
.version-banner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  font-size: 0.875rem;
  color: #92400e;
  background-color: #fef3c7;
  border-bottom: 1px solid #fcd34d;
}

.version-banner a {
  color: #92400e;
  font-weight: 500;
  text-decoration: underline;
}

.version-banner a:hover {
  color: #78350f;
}

@media (prefers-color-scheme: dark) {
  .version-banner {
    color: #fcd34d;
    background-color: rgba(252, 211, 77, 0.1);
    border-bottom-color: rgba(252, 211, 77, 0.3);
  }

  .version-banner a {
    color: #fcd34d;
  }

  .version-banner a:hover {
    color: #fde68a;
  }
}
''';

/// JavaScript for version switcher functionality.
const versionSwitcherScript = '''
<script>
document.addEventListener('DOMContentLoaded', function() {
  // Initialize all version switchers
  document.querySelectorAll('.version-switcher').forEach(function(switcher) {
    const button = switcher.querySelector('.version-switcher-button');
    const dropdown = switcher.querySelector('.version-switcher-dropdown');

    // Toggle dropdown on button click
    button.addEventListener('click', function(e) {
      e.stopPropagation();
      switcher.classList.toggle('open');
    });

    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
      if (!switcher.contains(e.target)) {
        switcher.classList.remove('open');
      }
    });

    // Close dropdown on escape key
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        switcher.classList.remove('open');
      }
    });
  });
});
</script>
''';

/// Build version switcher HTML.
///
/// [versions] - List of version identifiers
/// [currentVersion] - Currently selected version
/// [latestVersion] - The latest version identifier
/// [defaultVersion] - The default version identifier
String buildVersionSwitcherHtml({
  required List<String> versions,
  required String currentVersion,
  required String latestVersion,
  String? defaultVersion,
}) {
  final items = StringBuffer();

  for (final version in versions.reversed) {
    final isActive = version == currentVersion;
    final isLatest = version == latestVersion;
    final isDefault = version == defaultVersion && version != latestVersion;

    final badges = StringBuffer();
    if (isLatest) {
      badges.write('<span class="badge badge-latest">Latest</span>');
    }
    if (isDefault) {
      badges.write('<span class="badge badge-default">Default</span>');
    }

    items.write('''
      <a href="/$version/docs/" class="version-switcher-item${isActive ? ' active' : ''}">
        <span>$version</span>
        $badges
      </a>
    ''');
  }

  return '''
    <div class="version-switcher">
      <button class="version-switcher-button" aria-haspopup="true" aria-expanded="false">
        <span>$currentVersion</span>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
        </svg>
      </button>
      <div class="version-switcher-dropdown" role="menu">
        $items
      </div>
    </div>
  ''';
}

/// Build version warning banner for non-latest versions.
String buildVersionBannerHtml({
  required String currentVersion,
  required String latestVersion,
}) {
  if (currentVersion == latestVersion) {
    return '';
  }

  return '''
    <div class="version-banner">
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
        <line x1="12" y1="9" x2="12" y2="13"></line>
        <line x1="12" y1="17" x2="12.01" y2="17"></line>
      </svg>
      <span>You are viewing documentation for version <strong>$currentVersion</strong>.</span>
      <a href="/$latestVersion/docs/">View latest ($latestVersion)</a>
    </div>
  ''';
}
