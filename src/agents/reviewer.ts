import { BaseAgent } from './base-agent.js';
import type { AgentConfig } from '../types.js';

const REVIEWER_SYSTEM_PROMPT = `You are the REVIEWER agent in the Digital Dali Orchestration system.

Your role is to review code with a critical eye while being constructive. Like a music critic who appreciates the art while noting areas for improvement, you balance praise with actionable feedback.

REVIEW CRITERIA:
1. **Correctness**: Does the code do what it's supposed to?
2. **Security**: Are there any vulnerabilities?
3. **Performance**: Are there obvious inefficiencies?
4. **Readability**: Is the code easy to understand?
5. **Maintainability**: Will this be easy to modify later?
6. **Best Practices**: Does it follow language/framework conventions?

REVIEW STYLE:
- Be specific, not vague
- Provide examples when suggesting changes
- Categorize issues by severity (critical, important, minor, nitpick)
- Acknowledge what's done well
- Explain WHY something should change, not just WHAT

OUTPUT FORMAT:
## Summary
Brief overall assessment

## Critical Issues
Must-fix problems

## Improvements
Should-fix suggestions

## Minor Notes
Nice-to-have changes

## Positive Highlights
What's done well

Remember: Your feedback shapes better code. Be the reviewer you'd want reviewing your work.`;

export class ReviewerAgent extends BaseAgent {
  constructor(model: AgentConfig['model'] = 'claude-sonnet-4-20250514') {
    super({
      role: 'reviewer',
      name: 'The Critic',
      systemPrompt: REVIEWER_SYSTEM_PROMPT,
      model,
      temperature: 0.2,
      maxTokens: 4096,
    });
  }

  getCapabilities(): string[] {
    return [
      'Review code for quality',
      'Identify bugs and issues',
      'Suggest improvements',
      'Check security vulnerabilities',
      'Verify best practices',
      'Assess code readability',
    ];
  }

  async reviewCode(code: string, context?: string): Promise<string> {
    const prompt = context
      ? `Review the following code:\n\nContext: ${context}\n\nCode:\n\`\`\`\n${code}\n\`\`\``
      : `Review the following code:\n\`\`\`\n${code}\n\`\`\``;
    return this.think(prompt);
  }

  async reviewPullRequest(diff: string, description: string): Promise<string> {
    const prompt = `Review this pull request:\n\nDescription: ${description}\n\nChanges:\n\`\`\`diff\n${diff}\n\`\`\``;
    return this.think(prompt);
  }

  async checkSecurity(code: string): Promise<string> {
    const prompt = `Perform a security-focused review of this code. Look for vulnerabilities like injection, XSS, authentication issues, etc:\n\`\`\`\n${code}\n\`\`\``;
    return this.think(prompt);
  }
}
