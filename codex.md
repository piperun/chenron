# Privacy and Anonymization

- Never commit or publish real sensitive-content domains, URLs, tags,
  usernames, search terms, screenshots, page text, or identifying examples.
- Reproduce provider-specific behavior with reserved `.example` domains,
  synthetic metadata, local fixtures, and scripted HTTP clients.
- Automated tests must be deterministic and must not call live third-party
  sites.
- Keep any real identifier needed for local manual testing in ignored local
  configuration. Do not include it in source, fixtures, documentation, logs,
  commit messages, branch names, pull requests, or release notes.
- Before committing, scan the working tree, staged diff, and commit message
  for sensitive identifiers. Before publishing, scan reachable history too.
- If sensitive data is supplied while debugging, treat it as confidential:
  describe it abstractly and redact it from durable project artifacts.
