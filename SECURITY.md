# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in DocuDart, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please email the maintainer directly or use [GitHub's private vulnerability reporting](https://github.com/Nikoro/docudart/security/advisories/new).

### What to include

- A description of the vulnerability
- Steps to reproduce the issue
- The potential impact
- Any suggested fixes (optional)

### Response timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 1 week
- **Fix or mitigation**: Dependent on severity and complexity

## Scope

The following are in scope for security reports:

- Template injection via user-provided values (project name, description, etc.)
- Path traversal in file operations
- Dependency confusion in package resolution
- Generated site accidentally exposing sensitive files

## Out of Scope

- Vulnerabilities in upstream dependencies (report these to the respective projects)
- Issues requiring physical access to the machine
- Social engineering attacks
