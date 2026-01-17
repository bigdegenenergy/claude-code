#!/usr/bin/env node
/**
 * UserPromptSubmit Hook - Skill Activation
 *
 * Automatically injects relevant skill context based on the user's prompt.
 * This eliminates the need to manually activate skills - they auto-trigger
 * based on keywords and patterns in what you're asking Claude to do.
 *
 * Skills are loaded from .claude/skills/<skill>/SKILL.md and provide
 * domain expertise without bloating the main context.
 */

import { readFileSync, readdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Read user prompt from stdin
let input = '';
try {
  input = readFileSync(0, 'utf-8');
} catch (e) {
  process.exit(0);
}

let promptData;
try {
  promptData = JSON.parse(input);
} catch (e) {
  process.exit(0);
}

const userPrompt = (promptData.prompt || promptData.user_prompt || '').toLowerCase();

if (!userPrompt) {
  process.exit(0);
}

// Skill definitions with trigger patterns
const skillTriggers = {
  'tdd': {
    patterns: [
      /\btest.?first\b/,
      /\btdd\b/,
      /\bred.?green.?refactor\b/,
      /\bwrite.*test.*before/,
      /\btest.?driven/,
      /\bfailing.*test.*first/,
    ],
    priority: 1
  },
  'security-review': {
    patterns: [
      /\bsecurity\b/,
      /\bvulnerab/,
      /\bowasp\b/,
      /\bauth(entication|orization)?\b/,
      /\bxss\b/,
      /\bsql.?injection\b/,
      /\binput.?valid(ation|ate)\b/,
      /\bsanitiz/,
      /\bcredential/,
      /\bsecret/,
      /\bencrypt/,
    ],
    priority: 1
  },
  'api-design': {
    patterns: [
      /\bapi\b/,
      /\bendpoint/,
      /\brest(ful)?\b/,
      /\bgraphql\b/,
      /\broute/,
      /\bhttp.*method/,
      /\brequest.*response/,
      /\bpayload/,
      /\bschema.*design/,
    ],
    priority: 2
  },
  'async-patterns': {
    patterns: [
      /\basync\b/,
      /\bawait\b/,
      /\bpromise/,
      /\bconcurren/,
      /\bparallel/,
      /\brace.?condition/,
      /\bevent.?loop/,
      /\bcallback/,
      /\bdeadlock/,
    ],
    priority: 2
  },
  'debugging': {
    patterns: [
      /\bdebug/,
      /\bbug\b/,
      /\berror\b/,
      /\bfix\b/,
      /\bstack.?trace/,
      /\bexception/,
      /\bissue\b/,
      /\bbroken\b/,
      /\bfailing\b/,
      /\bcrash/,
      /\bnot.?work/,
      /\bwhy.*doesn.?t/,
      /\bwhat.?s.*wrong/,
      /\binvestigat/,
      /\btroubleshoot/,
    ],
    priority: 1
  },
  'refactoring': {
    patterns: [
      /\brefactor/,
      /\bclean.?up/,
      /\bsimplif/,
      /\bimprove.*code/,
      /\breduce.*complex/,
      /\bcode.?smell/,
      /\btechnical.?debt/,
      /\bextract.*method/,
      /\bextract.*function/,
      /\brename\b/,
    ],
    priority: 2
  },
  'testing-patterns': {
    patterns: [
      /\btest/,
      /\bunit\b/,
      /\bintegration\b/,
      /\be2e\b/,
      /\bend.?to.?end/,
      /\bmock/,
      /\bstub\b/,
      /\bfixture/,
      /\bcoverage/,
      /\bassert/,
      /\bjest\b/,
      /\bpytest\b/,
      /\bmocha\b/,
      /\bplaywright\b/,
      /\bcypress\b/,
    ],
    priority: 2
  },
  'k8s-operations': {
    patterns: [
      /\bkubernetes\b/,
      /\bk8s\b/,
      /\bkubectl\b/,
      /\bhelm\b/,
      /\bpod\b/,
      /\bdeployment\b/,
      /\bservice\b.*\b(mesh|type)/,
      /\bingress\b/,
      /\bconfigmap\b/,
      /\bnamespace\b/,
      /\bargo\b/,
      /\bflux\b/,
    ],
    priority: 2
  },
  'cicd-automation': {
    patterns: [
      /\bci\/?cd\b/,
      /\bpipeline/,
      /\bgithub.?action/,
      /\bworkflow/,
      /\bdeploy/,
      /\bbuild.*automat/,
      /\bjenkins\b/,
      /\bcircle.?ci\b/,
      /\btravis\b/,
      /\bgitlab.?ci\b/,
    ],
    priority: 2
  },
  'observability': {
    patterns: [
      /\blog(ging|s)?\b/,
      /\bmetric/,
      /\btrac(ing|e)\b/,
      /\bmonitor/,
      /\balert/,
      /\bdashboard/,
      /\bgrafana\b/,
      /\bprometheus\b/,
      /\bdatadog\b/,
      /\bopentelemetry\b/,
      /\bspan\b/,
    ],
    priority: 2
  }
};

// Find matching skills
const matchedSkills = [];

for (const [skillName, config] of Object.entries(skillTriggers)) {
  for (const pattern of config.patterns) {
    if (pattern.test(userPrompt)) {
      matchedSkills.push({
        name: skillName,
        priority: config.priority
      });
      break; // Only match each skill once
    }
  }
}

// Sort by priority (lower = higher priority)
matchedSkills.sort((a, b) => a.priority - b.priority);

// Limit to top 2 skills to avoid context bloat
const activeSkills = matchedSkills.slice(0, 2);

if (activeSkills.length === 0) {
  process.exit(0);
}

// Load skill content
const skillsDir = join(__dirname, '..', '..', 'skills');
let output = '';

for (const skill of activeSkills) {
  const skillPath = join(skillsDir, skill.name, 'SKILL.md');

  if (existsSync(skillPath)) {
    try {
      const content = readFileSync(skillPath, 'utf-8');
      // Remove frontmatter
      const cleanContent = content.replace(/^---[\s\S]*?---\n*/, '');
      output += `\n## Activated Skill: ${skill.name}\n`;
      output += cleanContent + '\n';
    } catch (e) {
      // Silently skip unreadable skills
    }
  }
}

if (output) {
  console.log('\n--- SKILL CONTEXT (Auto-activated based on your prompt) ---');
  console.log(output);
  console.log('--- END SKILL CONTEXT ---\n');
}
