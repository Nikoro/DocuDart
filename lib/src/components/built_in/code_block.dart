/// CSS styles for the CodeBlock component.
const codeBlockStyles = '''
/* CodeBlock Component */
.code-block {
  position: relative;
  margin: 1rem 0;
  border-radius: 0.5rem;
  overflow: hidden;
  background-color: var(--color-code-background);
}

.code-block-title {
  padding: 0.5rem 1rem;
  font-size: 0.75rem;
  font-weight: 500;
  color: var(--color-text-muted);
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
}

.code-block pre {
  margin: 0;
  padding: 1rem;
  overflow-x: auto;
}

.code-block code {
  font-family: var(--font-family-mono);
  font-size: 0.875rem;
  line-height: 1.5;
}

.code-block .copy-button {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  padding: 0.375rem 0.75rem;
  font-size: 0.75rem;
  font-weight: 500;
  color: var(--color-text-muted);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 0.25rem;
  cursor: pointer;
  opacity: 0;
  transition: opacity 0.15s, background-color 0.15s;
}

.code-block:hover .copy-button {
  opacity: 1;
}

.code-block .copy-button:hover {
  background-color: var(--color-background);
  color: var(--color-text);
}

.code-block .copy-button.copied {
  color: #22c55e;
}

/* Line numbers */
.code-block.line-numbers pre {
  padding-left: 3.5rem;
}

.code-block.line-numbers code {
  counter-reset: line;
}

.code-block.line-numbers code .line::before {
  counter-increment: line;
  content: counter(line);
  display: inline-block;
  width: 2rem;
  margin-left: -3rem;
  margin-right: 1rem;
  text-align: right;
  color: var(--color-text-muted);
  opacity: 0.5;
}
''';

/// JavaScript for copy functionality.
const codeBlockScript = '''
<script>
document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.code-block .copy-button').forEach(function(button) {
    button.addEventListener('click', async function() {
      const codeBlock = button.closest('.code-block');
      const code = codeBlock.querySelector('code').textContent;

      try {
        await navigator.clipboard.writeText(code);
        button.textContent = 'Copied!';
        button.classList.add('copied');

        setTimeout(function() {
          button.textContent = 'Copy';
          button.classList.remove('copied');
        }, 2000);
      } catch (err) {
        button.textContent = 'Failed';
        setTimeout(function() {
          button.textContent = 'Copy';
        }, 2000);
      }
    });
  });
});
</script>
''';
