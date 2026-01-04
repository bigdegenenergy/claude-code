---
description: "Security requirements and vulnerability prevention"
---

# Security Rules

## Input Validation

1. **Validate all external input** - never trust user data
2. **Use allowlists over denylists** - specify what's allowed, not what's blocked
3. **Sanitize before rendering** - prevent XSS
4. **Parameterize queries** - prevent SQL injection

## Authentication & Authorization

- **Hash passwords with bcrypt/argon2** - never store plaintext
- **Use secure session tokens** - cryptographically random, sufficient length
- **Check permissions on every request** - don't trust client-side auth
- **Implement rate limiting** - prevent brute force attacks

## Secrets Management

- **Never commit secrets** - pre-commit hook blocks this
- **Use environment variables** - not hardcoded values
- **Rotate credentials regularly** - assume breach
- **Minimum necessary permissions** - principle of least privilege

## OWASP Top 10 Awareness

| Vulnerability | Prevention |
|---------------|------------|
| Injection | Parameterized queries, input validation |
| Broken Auth | Strong passwords, MFA, secure sessions |
| XSS | Output encoding, CSP headers |
| IDOR | Authorization checks on every resource |
| Security Misconfiguration | Secure defaults, remove debug |
| Sensitive Data Exposure | Encryption at rest and in transit |

## Code Review Checklist

- [ ] No hardcoded secrets or credentials
- [ ] All user input validated and sanitized
- [ ] SQL queries use parameterization
- [ ] Error messages don't leak sensitive info
- [ ] Authentication required on protected routes
