import chalk from 'chalk';
import type { AgentRole } from '../types.js';

const roleColors: Record<AgentRole, (text: string) => string> = {
  conductor: chalk.magenta.bold,
  coder: chalk.green,
  reviewer: chalk.yellow,
  architect: chalk.blue,
  researcher: chalk.cyan,
};

const roleEmojis: Record<AgentRole, string> = {
  conductor: '🎼',
  coder: '💻',
  reviewer: '🔍',
  architect: '🏗️',
  researcher: '📚',
};

export class Logger {
  private verbose: boolean;

  constructor(verbose = true) {
    this.verbose = verbose;
  }

  private timestamp(): string {
    return chalk.gray(`[${new Date().toLocaleTimeString()}]`);
  }

  agent(role: AgentRole, message: string): void {
    const color = roleColors[role];
    const emoji = roleEmojis[role];
    console.log(`${this.timestamp()} ${emoji} ${color(role.toUpperCase())}: ${message}`);
  }

  task(action: 'created' | 'started' | 'completed' | 'failed', title: string): void {
    const icons = {
      created: chalk.blue('◆'),
      started: chalk.yellow('▶'),
      completed: chalk.green('✓'),
      failed: chalk.red('✗'),
    };
    console.log(`${this.timestamp()} ${icons[action]} Task ${action}: ${title}`);
  }

  info(message: string): void {
    console.log(`${this.timestamp()} ${chalk.blue('ℹ')} ${message}`);
  }

  success(message: string): void {
    console.log(`${this.timestamp()} ${chalk.green('✓')} ${message}`);
  }

  warn(message: string): void {
    console.log(`${this.timestamp()} ${chalk.yellow('⚠')} ${message}`);
  }

  error(message: string): void {
    console.log(`${this.timestamp()} ${chalk.red('✗')} ${message}`);
  }

  debug(message: string): void {
    if (this.verbose) {
      console.log(`${this.timestamp()} ${chalk.gray('🔧')} ${chalk.gray(message)}`);
    }
  }

  divider(): void {
    console.log(chalk.gray('─'.repeat(60)));
  }

  banner(): void {
    console.log(chalk.magenta.bold(`
    ╔══════════════════════════════════════════════════════════╗
    ║         🎨 DIGITAL DALI ORCHESTRATION 🎼                ║
    ║         Making Code Flow Like Music                      ║
    ╚══════════════════════════════════════════════════════════╝
    `));
  }
}

export const logger = new Logger();
