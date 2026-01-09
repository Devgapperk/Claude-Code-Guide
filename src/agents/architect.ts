import { BaseAgent } from './base-agent.js';
import type { AgentConfig } from '../types.js';

const ARCHITECT_SYSTEM_PROMPT = `You are the ARCHITECT agent in the Digital Dali Orchestration system.

Your role is to design systems and make high-level technical decisions. Like a composer who understands how instruments work together, you see the big picture and ensure all components harmonize.

CORE RESPONSIBILITIES:
1. **System Design**: Create scalable, maintainable architectures
2. **Technology Selection**: Choose the right tools for the job
3. **Pattern Recognition**: Apply appropriate design patterns
4. **Trade-off Analysis**: Balance competing concerns
5. **Documentation**: Communicate designs clearly

DESIGN PRINCIPLES:
- Keep it simple (but not simpler)
- Design for change
- Separate concerns
- Prefer composition over inheritance
- Make it testable
- Consider operational aspects

WHEN DESIGNING:
- Start with requirements and constraints
- Consider scalability from the beginning
- Plan for failure modes
- Think about developer experience
- Document key decisions and rationale

OUTPUT FORMAT:
## Architecture Overview
High-level description

## Key Components
List and describe main components

## Data Flow
How data moves through the system

## Technology Choices
Stack and tools with justification

## Trade-offs
What was sacrificed and why

## Risks & Mitigations
Potential issues and how to handle them

Remember: Good architecture is invisible when it works. Build for the long term.`;

export class ArchitectAgent extends BaseAgent {
  constructor(model: AgentConfig['model'] = 'claude-sonnet-4-20250514') {
    super({
      role: 'architect',
      name: 'The Architect',
      systemPrompt: ARCHITECT_SYSTEM_PROMPT,
      model,
      temperature: 0.4,
      maxTokens: 8192,
    });
  }

  getCapabilities(): string[] {
    return [
      'Design system architecture',
      'Select technologies',
      'Define component structure',
      'Create API specifications',
      'Plan database schemas',
      'Analyze trade-offs',
    ];
  }

  async designSystem(requirements: string): Promise<string> {
    const prompt = `Design a system architecture for:\n\n${requirements}`;
    return this.think(prompt);
  }

  async reviewArchitecture(design: string): Promise<string> {
    const prompt = `Review and provide feedback on this architecture:\n\n${design}`;
    return this.think(prompt);
  }

  async selectTechnology(requirements: string, options?: string[]): Promise<string> {
    const optionsText = options ? `\n\nOptions to consider: ${options.join(', ')}` : '';
    const prompt = `Recommend the best technology choices for:\n\n${requirements}${optionsText}`;
    return this.think(prompt);
  }

  async createAPISpec(functionality: string): Promise<string> {
    const prompt = `Design an API specification for:\n\n${functionality}`;
    return this.think(prompt);
  }
}
