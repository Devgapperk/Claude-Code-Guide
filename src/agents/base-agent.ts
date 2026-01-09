import Anthropic from '@anthropic-ai/sdk';
import type { AgentConfig, AgentMessage, AgentRole } from '../types.js';
import { logger } from '../utils/logger.js';

export abstract class BaseAgent {
  protected client: Anthropic;
  protected config: AgentConfig;
  protected conversationHistory: Array<{ role: 'user' | 'assistant'; content: string }> = [];

  constructor(config: AgentConfig) {
    this.config = config;
    this.client = new Anthropic();
  }

  get role(): AgentRole {
    return this.config.role;
  }

  get name(): string {
    return this.config.name;
  }

  async think(input: string): Promise<string> {
    logger.agent(this.role, `Processing: "${input.substring(0, 50)}..."`);

    this.conversationHistory.push({ role: 'user', content: input });

    try {
      const response = await this.client.messages.create({
        model: this.config.model,
        max_tokens: this.config.maxTokens ?? 4096,
        system: this.config.systemPrompt,
        messages: this.conversationHistory,
      });

      const assistantMessage = response.content[0].type === 'text'
        ? response.content[0].text
        : '';

      this.conversationHistory.push({ role: 'assistant', content: assistantMessage });

      logger.debug(`${this.name} responded with ${assistantMessage.length} characters`);

      return assistantMessage;
    } catch (error) {
      logger.error(`${this.name} failed: ${error}`);
      throw error;
    }
  }

  async receiveMessage(message: AgentMessage): Promise<string> {
    const formattedInput = this.formatMessage(message);
    return this.think(formattedInput);
  }

  protected formatMessage(message: AgentMessage): string {
    return `[From ${message.from.toUpperCase()}] ${message.content}`;
  }

  clearHistory(): void {
    this.conversationHistory = [];
    logger.debug(`${this.name} conversation history cleared`);
  }

  abstract getCapabilities(): string[];
}
