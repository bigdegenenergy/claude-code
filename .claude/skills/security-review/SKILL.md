---
name: security-review
description: "Use when the user asks for a security audit, vulnerability scan, security review, or to check for security issues. This skill performs comprehensive security analysis."
allowed-tools: Read,Grep,Glob,Bash
version: 1.0.0
---

# Security Review

## Purpose

Perform comprehensive security audits to identify vulnerabilities, insecure practices, and potential attack vectors.

## When to Use

- User asks for "security audit"
- User wants to "check for vulnerabilities"
- User asks about "security issues"
- Before deploying to production
- After adding authentication/authorization features

## OWASP Top 10 Checklist

### A01: Broken Access Control
- [ ] Authorization checked on every request
- [ ] No IDOR (Insecure Direct Object References)
- [ ] Role-based access properly enforced
- [ ] CORS configured correctly

### A02: Cryptographic Failures
- [ ] Passwords hashed with strong algorithm (bcrypt, argon2)
- [ ] Sensitive data encrypted at rest
- [ ] TLS used for data in transit
- [ ] No weak cryptographic algorithms

### A03: Injection
- [ ] SQL queries parameterized
- [ ] User input sanitized before use
- [ ] Command injection prevented
- [ ] LDAP injection prevented

### A04: Insecure Design
- [ ] Input validation on all user data
- [ ] Rate limiting implemented
- [ ] Secure defaults used
- [ ] Defense in depth applied

### A05: Security Misconfiguration
- [ ] Debug mode disabled in production
- [ ] Default credentials changed
- [ ] Error messages don't leak info
- [ ] Security headers configured

### A06: Vulnerable Components
- [ ] Dependencies up to date
- [ ] No known vulnerable packages
- [ ] Minimal dependencies used
- [ ] Components from trusted sources

### A07: Authentication Failures
- [ ] Strong password requirements
- [ ] Account lockout after failed attempts
- [ ] Secure session management
- [ ] MFA available for sensitive operations

### A08: Data Integrity Failures
- [ ] CI/CD pipeline secured
- [ ] Package integrity verified
- [ ] Signed updates used
- [ ] Deserialization is safe

### A09: Logging & Monitoring
- [ ] Security events logged
- [ ] Logs don't contain sensitive data
- [ ] Alerting configured
- [ ] Audit trail maintained

### A10: Server-Side Request Forgery
- [ ] URL validation on server-side requests
- [ ] Allowlist for external requests
- [ ] Network segmentation in place

## Quick Scan Commands

```bash
# Check for hardcoded secrets
grep -rn "password\s*=\s*['\"]" --include="*.py" --include="*.js" --include="*.ts"
grep -rn "api[_-]?key\s*=\s*['\"]" --include="*.py" --include="*.js" --include="*.ts"

# Check for SQL injection patterns
grep -rn "execute.*%s" --include="*.py"
grep -rn '\$\{.*\}' --include="*.sql"

# Check npm vulnerabilities
npm audit

# Check Python vulnerabilities
pip audit  # or safety check
```

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| 🔴 Critical | Immediate exploitation possible | Stop and fix now |
| 🟠 High | Exploitation likely with effort | Fix before release |
| 🟡 Medium | Limited impact or unlikely | Fix soon |
| 🟢 Low | Minimal impact | Fix when convenient |

## Report Format

```markdown
## Security Findings

### [CRITICAL] SQL Injection in user search
- **Location**: src/api/users.ts:45
- **Issue**: User input directly concatenated into SQL query
- **Impact**: Full database access
- **Fix**: Use parameterized queries

### [HIGH] Missing authentication on admin endpoint
- **Location**: src/routes/admin.ts:12
- **Issue**: /admin/users endpoint has no auth middleware
- **Impact**: Unauthorized access to user data
- **Fix**: Add requireAuth middleware
```

## Commands

- For security audit: Use `@security-auditor` agent
- Quick vulnerability scan: `npm audit` or `pip audit`
