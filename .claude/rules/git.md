---
description: "Git workflow and commit conventions"
---

# Git Rules

## Commit Messages

Use **Conventional Commits** format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | Use When |
|------|----------|
| `feat` | New feature for users |
| `fix` | Bug fix for users |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change, no behavior change |
| `test` | Adding/updating tests |
| `chore` | Build, tooling, dependencies |

### Examples

```
feat(auth): add OAuth2 login with Google
fix(api): handle null response from payment provider
docs: update README with new setup instructions
refactor(utils): extract date formatting to shared module
```

## Branch Strategy

- `main` - production-ready code
- `feature/*` - new features
- `fix/*` - bug fixes
- `claude/*` - AI agent branches

## Workflow

1. Create feature branch from `main`
2. Make atomic commits (one logical change per commit)
3. Run tests before pushing
4. Create PR with description
5. Squash merge to `main`

## Prohibited Actions

- **Never force push to main/master**
- **Never commit secrets** (pre-commit hook blocks this)
- **Never skip pre-commit hooks** without explicit permission
- **Never amend commits you didn't author**
