#!/usr/bin/env node

import { Command } from 'commander';
import { Orchestrator } from './orchestrator.js';
import { logger } from './utils/logger.js';
import 'dotenv/config';

const program = new Command();

program
  .name('dali')
  .description('Digital Dali Orchestration - AI Agent Symphony')
  .version('1.0.0');

program
  .command('orchestrate')
  .description('Start a full orchestration session')
  .argument('<objective>', 'The objective to accomplish')
  .option('-c, --context <context>', 'Additional context')
  .option('-v, --verbose', 'Verbose output', true)
  .action(async (objective: string, options: { context?: string; verbose?: boolean }) => {
    const orchestrator = new Orchestrator({ verbose: options.verbose });

    try {
      const session = await orchestrator.orchestrate({
        objective,
        context: options.context,
      });

      console.log('\n📋 Session Summary:');
      console.log(`   ID: ${session.id}`);
      console.log(`   Tasks Completed: ${session.tasks.filter((t) => t.status === 'completed').length}/${session.tasks.length}`);
      console.log(`   Duration: ${((session.completedAt!.getTime() - session.startedAt.getTime()) / 1000).toFixed(1)}s`);
    } catch (error) {
      logger.error(`Orchestration failed: ${error}`);
      process.exit(1);
    }
  });

program
  .command('code')
  .description('Quick access to the Coder agent')
  .argument('<request>', 'What to code')
  .action(async (request: string) => {
    logger.banner();
    const orchestrator = new Orchestrator();
    const result = await orchestrator.askCoder(request);
    console.log('\n' + result);
  });

program
  .command('review')
  .description('Quick access to the Reviewer agent')
  .argument('<request>', 'What to review')
  .action(async (request: string) => {
    logger.banner();
    const orchestrator = new Orchestrator();
    const result = await orchestrator.askReviewer(request);
    console.log('\n' + result);
  });

program
  .command('architect')
  .description('Quick access to the Architect agent')
  .argument('<request>', 'What to design')
  .action(async (request: string) => {
    logger.banner();
    const orchestrator = new Orchestrator();
    const result = await orchestrator.askArchitect(request);
    console.log('\n' + result);
  });

program
  .command('demo')
  .description('Run a demo orchestration')
  .action(async () => {
    logger.banner();
    logger.info('Running demo orchestration...\n');

    const orchestrator = new Orchestrator();

    try {
      await orchestrator.orchestrate({
        objective: 'Create a simple TypeScript function that validates email addresses with proper error handling',
        context: 'This will be used in a Node.js backend API',
      });
    } catch (error) {
      logger.error(`Demo failed: ${error}`);
    }
  });

// Interactive mode
program
  .command('interactive')
  .alias('i')
  .description('Start interactive orchestration mode')
  .action(async () => {
    logger.banner();
    logger.info('Interactive mode - Type your objective and press Enter');
    logger.info('Commands: /code, /review, /architect, /exit\n');

    const orchestrator = new Orchestrator();
    const readline = await import('readline');

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    const prompt = () => {
      rl.question('🎼 > ', async (input) => {
        const trimmed = input.trim();

        if (trimmed === '/exit' || trimmed === 'exit') {
          logger.success('Farewell, maestro! 🎵');
          rl.close();
          return;
        }

        if (trimmed.startsWith('/code ')) {
          const result = await orchestrator.askCoder(trimmed.slice(6));
          console.log('\n' + result + '\n');
        } else if (trimmed.startsWith('/review ')) {
          const result = await orchestrator.askReviewer(trimmed.slice(8));
          console.log('\n' + result + '\n');
        } else if (trimmed.startsWith('/architect ')) {
          const result = await orchestrator.askArchitect(trimmed.slice(11));
          console.log('\n' + result + '\n');
        } else if (trimmed.length > 0) {
          try {
            await orchestrator.orchestrate({ objective: trimmed });
          } catch (error) {
            logger.error(`${error}`);
          }
        }

        prompt();
      });
    };

    prompt();
  });

// Parse and execute
program.parse();

// Default to help if no command
if (!process.argv.slice(2).length) {
  program.outputHelp();
}
