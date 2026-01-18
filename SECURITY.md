# Security Policy

## Supported Versions

The following table shows which versions of this project are currently being supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

We take the security of this project seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Please Do

- **Report vulnerabilities privately** by emailing [@bigdegenenergyx on X](https://x.com/bigdegenenergyx) or by using [GitHub's private vulnerability reporting](https://github.com/bigdegenenergy/ai-dev-toolkit/security/advisories/new).
- Provide sufficient information to reproduce the issue, so we can resolve it quickly.
- Allow reasonable time for us to address the issue before any public disclosure.

### Please Do Not

- Open a public GitHub issue for security vulnerabilities.
- Disclose the vulnerability publicly before we have had a chance to address it.
- Access, modify, or delete data belonging to others while researching vulnerabilities.

## What to Include in Your Report

To help us triage and respond to your report quickly, please include:

- **Description**: A clear description of the vulnerability.
- **Impact**: What could an attacker achieve by exploiting this vulnerability?
- **Steps to Reproduce**: Detailed steps to reproduce the issue.
- **Affected Versions**: Which versions of the project are affected?
- **Potential Fix**: If you have suggestions for how to fix the issue, please include them.
- **Your Contact Information**: So we can reach out for clarification if needed.

## Response Timeline

- **Acknowledgment**: We will acknowledge receipt of your report within **48 hours**.
- **Initial Assessment**: We will provide an initial assessment within **7 days**.
- **Resolution**: We aim to resolve critical vulnerabilities within **30 days**, depending on complexity.

## Disclosure Policy

- We follow a coordinated disclosure process.
- Once a fix is available, we will publish a security advisory and credit the reporter (unless they prefer to remain anonymous).
- We request that you do not disclose the vulnerability until we have released a fix and notified affected users.

## Security Best Practices for Contributors

When contributing to this project, please:

1. **Never commit secrets**: API keys, passwords, tokens, or other credentials should never be committed to the repository.
2. **Use environment variables**: Store sensitive configuration in environment variables, not in code.
3. **Validate inputs**: Always validate and sanitize user inputs to prevent injection attacks.
4. **Keep dependencies updated**: Regularly update dependencies to patch known vulnerabilities.
5. **Follow least privilege**: Request only the minimum permissions necessary for functionality.

## Security-Related Configuration

This repository includes security-focused tooling:

- **PII Scanning**: Automated scanning for personally identifiable information
- **Secret Detection**: Pre-commit hooks and CI checks for leaked credentials
- **Dependency Scanning**: Automated vulnerability scanning for dependencies

## Contact

For security concerns, please contact: [@bigdegenenergyx on X](https://x.com/bigdegenenergyx)

For general questions about this security policy, you can open a discussion in the repository.

---

Thank you for helping keep this project and its users safe!
