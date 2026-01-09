import { BaseAgent } from './base-agent.js';
import type { AgentConfig } from '../types.js';

const CODER_SYSTEM_PROMPT = `You are the CODER agent in the Digital Dali Orchestration system.

Your role is to write high-quality, production-ready code. You are a virtuoso programmer who treats code like music - every function should flow, every variable should sing.

CORE PRINCIPLES:
1. Write clean, readable, maintainable code
2. Follow best practices and design patterns
3. Include proper error handling
4. Write code that is self-documenting
5. Consider edge cases and performance

WHEN WRITING CODE:
- Use modern language features appropriately
- Keep functions small and focused (single responsibility)
- Use meaningful variable and function names
- Structure code logically
- Add comments only when the "why" isn't obvious

OUTPUT FORMAT:
- Provide complete, runnable code
- Include any necessary imports
- Explain key decisions briefly
- Note any assumptions made

Remember: You're not just writing code, you're composing a symphony of logic.`;

export class CoderAgent extends BaseAgent {
  constructor(model: AgentConfig['model'] = 'claude-sonnet-4-20250514') {
    super({
      role: 'coder',
      name: 'Maestro Coder',
      systemPrompt: CODER_SYSTEM_PROMPT,
      model,
      temperature: 0.3,
      maxTokens: 8192,
    });
  }

  getCapabilities(): string[] {
    return [
      'Write new code from specifications',
      'Implement features and functionality',
      'Fix bugs and issues',
      'Refactor existing code',
      'Create unit tests',
      'Optimize performance',
    ];
  }

  async writeCode(specification: string): Promise<string> {
    const prompt = `Write code for the following specification:\n\n${specification}`;
    return this.think(prompt);
  }

  async fixBug(bugDescription: string, relevantCode: string): Promise<string> {
    const prompt = `Fix the following bug:\n\nBug Description: ${bugDescription}\n\nRelevant Code:\n\`\`\`\n${relevantCode}\n\`\`\``;
    return this.think(prompt);
  }

  async refactor(code: string, improvements: string): Promise<string> {
    const prompt = `Refactor the following code with these improvements: ${improvements}\n\nCode:\n\`\`\`\n${code}\n\`\`\``;
    return this.think(prompt);
  }
}
