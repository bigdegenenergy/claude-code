# Startup Strategy: Let Claude Code Interview You

> Based on the approach from ["Before You Vibe Code, Let Claude Code Interview You"](https://medium.com/coding-nexus/before-you-vibe-code-let-claude-code-interview-you-7f157bdc5da4) by Code Coup, popularized by developer [Thariq](https://gist.github.com/robzolkos/40b70ed2dd045603149c6b3eed4649ad).

## The Problem

We "vibe code"—ship fast, iterate rapidly—but only later realize we never agreed on fundamentals. Buried assumptions surface during code review when they're expensive to fix.

## The Solution

**Let an AI interview you until your idea is complete.**

Before writing a single line of code, have Claude Code conduct an in-depth interview about your project. This surfaces design decisions, tradeoffs, and edge cases _before_ they become costly mistakes.

## The Strategy

### Step 1: Create a Basic Spec

Create a `spec.md` file with your initial project idea. It can be as simple as:

```markdown
# Project Spec

Accounting software for YouTube creators
```

### Step 2: Launch Claude Code

Open your terminal in the same directory as your spec file and run:

```bash
claude --model opus
```

### Step 3: Request the Interview

Use this prompt (or create it as a custom command):

```
Read the spec.md file and interview me in detail using the AskUserQuestionTool
about literally anything: technical implementation, UI & UX, concerns, tradeoffs,
etc. but make sure the questions are not obvious. Be very in-depth and continue
interviewing me continually until it's complete, then write the output spec to the file.
```

### Step 4: Answer Thoughtfully

Claude will ask multi-choice questions that probe deep into your project:

- **Technical implementation**: "Should this API fail fast or retry with backoff?"
- **UI/UX decisions**: "Should the dashboard prioritize data density or visual clarity?"
- **Architecture tradeoffs**: "Monolith for simplicity or microservices for scale?"
- **Edge cases**: "What happens when a user has multiple YouTube channels?"

Each question is a fork in the road. Each answer narrows the solution space.

### Step 5: Iterate (2-3 Rounds Max)

**Continue interviewing if:**

- You find yourself saying "I never thought about that"
- New considerations emerge that affect core architecture
- You're still uncertain about key decisions

**Stop and start building when:**

- Responses shift to "that's down the line" thinking
- You're hitting diminishing returns
- The spec feels comprehensive

### Step 6: Optional - Cross-Check with Other LLMs

Test your refined spec against other models (GPT-4, Gemini) to challenge assumptions and strengthen your specifications.

## Why This Works

1. **Tradeoffs become explicit** - Design decisions surface before they're buried in code
2. **Cheap to change** - Confronting decisions early when iteration costs nothing
3. **Decision tree navigation** - By the time coding starts, you've already navigated the major forks
4. **Shared understanding** - Both you and the AI have aligned mental models

## Custom Command Setup

Add this to your `.claude/commands/interview.md`:

```markdown
---
description: Interview me about the plan
model: opus
argument: plan
---

Read this plan file $1 and interview me in detail using the AskUserQuestionTool
about literally anything: technical implementation, UI & UX, concerns, tradeoffs,
etc. but make sure the questions are not obvious. Be very in-depth and continue
interviewing me continually until it's complete, then write the output spec to the file.
```

Then run:

```bash
claude /interview spec.md
```

## Key Insight

> "When Claude asks 'Should this API fail fast or retry with backoff?' before writing a single line of code, tradeoffs become explicit. Instead of discovering buried assumptions during code review, you confront design decisions upfront, when they're cheap to change."

This creates a **choose-your-own-adventure pathway** through product development. By the time Claude starts coding, you've already navigated the decision tree together.

---

## Sources

- [Before You Vibe Code, Let Claude Code Interview You](https://medium.com/coding-nexus/before-you-vibe-code-let-claude-code-interview-you-7f157bdc5da4) - Code Coup (Coding Nexus)
- [Claude Code Interview Command](https://gist.github.com/robzolkos/40b70ed2dd045603149c6b3eed4649ad) - Thariq's Gist
- [Before you vibe code, be interviewed by AI](https://justinmitchel.com/posts/vibe-interview/) - Justin Mitchel
