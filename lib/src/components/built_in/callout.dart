/// Callout types for different styles.
enum CalloutType {
  info,
  tip,
  warning,
  danger,
  note,
}

/// CSS styles for the Callout component.
const calloutStyles = '''
/* Callout Component */
.callout {
  padding: 1rem 1.25rem;
  margin: 1rem 0;
  border-radius: 0.5rem;
  border-left: 4px solid;
}

.callout-icon {
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
}

.callout-title {
  font-weight: 600;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.callout-content p:last-child {
  margin-bottom: 0;
}

/* Callout Types */
.callout-info {
  background-color: rgba(59, 130, 246, 0.1);
  border-color: #3b82f6;
}

.callout-tip {
  background-color: rgba(34, 197, 94, 0.1);
  border-color: #22c55e;
}

.callout-warning {
  background-color: rgba(234, 179, 8, 0.1);
  border-color: #eab308;
}

.callout-danger {
  background-color: rgba(239, 68, 68, 0.1);
  border-color: #ef4444;
}

.callout-note {
  background-color: rgba(107, 114, 128, 0.1);
  border-color: #6b7280;
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  .callout-info {
    background-color: rgba(59, 130, 246, 0.15);
  }

  .callout-tip {
    background-color: rgba(34, 197, 94, 0.15);
  }

  .callout-warning {
    background-color: rgba(234, 179, 8, 0.15);
  }

  .callout-danger {
    background-color: rgba(239, 68, 68, 0.15);
  }

  .callout-note {
    background-color: rgba(107, 114, 128, 0.2);
  }
}
''';
