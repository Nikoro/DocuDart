/// CSS styles for the Tabs component.
const tabsStyles = '''
/* Tabs Component */
.tabs-container {
  margin: 1.5rem 0;
  border: 1px solid var(--color-border);
  border-radius: 0.5rem;
  overflow: hidden;
}

.tabs-list {
  display: flex;
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  overflow-x: auto;
}

.tab-button {
  padding: 0.75rem 1.25rem;
  border: none;
  background: none;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text-muted);
  cursor: pointer;
  border-bottom: 2px solid transparent;
  white-space: nowrap;
  transition: all 0.15s;
}

.tab-button:hover {
  color: var(--color-text);
  background-color: var(--color-background);
}

.tab-button.active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
}

.tabs-content {
  padding: 1rem;
}

.tab-panel {
  display: none;
}

.tab-panel.active {
  display: block;
}

/* Tab animations */
.tab-panel {
  animation: fadeIn 0.2s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-4px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
''';

/// JavaScript for tab switching functionality.
const tabsScript = '''
<script>
document.addEventListener('DOMContentLoaded', function() {
  // Initialize all tab containers
  document.querySelectorAll('.tabs-container').forEach(function(container) {
    const tabsList = container.querySelector('.tabs-list');
    const panels = container.querySelectorAll('.tab-panel');

    // Create tab buttons from panels
    panels.forEach(function(panel, index) {
      const label = panel.dataset.tabLabel || 'Tab ' + (index + 1);
      const tabId = panel.dataset.tabId;

      const button = document.createElement('button');
      button.className = 'tab-button' + (index === 0 ? ' active' : '');
      button.textContent = label;
      button.setAttribute('role', 'tab');
      button.setAttribute('aria-selected', index === 0 ? 'true' : 'false');
      button.dataset.tabTarget = tabId;

      button.addEventListener('click', function() {
        // Update buttons
        tabsList.querySelectorAll('.tab-button').forEach(function(btn) {
          btn.classList.remove('active');
          btn.setAttribute('aria-selected', 'false');
        });
        button.classList.add('active');
        button.setAttribute('aria-selected', 'true');

        // Update panels
        panels.forEach(function(p) {
          p.classList.remove('active');
        });
        panel.classList.add('active');
      });

      tabsList.appendChild(button);

      // Show first panel
      if (index === 0) {
        panel.classList.add('active');
      }
    });
  });
});
</script>
''';
