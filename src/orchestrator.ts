import Anthropic from '@anthropic-ai/sdk';
import { CoderAgent, ReviewerAgent, ArchitectAgent, BaseAgent } from './agents/index.js';
import type { AgentRole, Task, Session, OrchestratorConfig, AgentMessage, TaskInput } from './types.js';
import { TaskInputSchema } from './types.js';
import { logger } from './utils/logger.js';

const CONDUCTOR_SYSTEM_PROMPT = `You are the CONDUCTOR of the Digital Dali Orchestration system.

Like a symphony conductor, you coordinate multiple specialized AI agents to accomplish complex software engineering tasks. Each agent is a virtuoso in their domain:

- **CODER**: Writes production-quality code
- **REVIEWER**: Reviews code for quality, security, and best practices
- **ARCHITECT**: Designs systems and makes technical decisions

YOUR RESPONSIBILITIES:
1. Analyze incoming objectives and break them into tasks
2. Assign tasks to the most suitable agent
3. Coordinate the flow of work between agents
4. Synthesize results into coherent deliverables
5. Ensure quality through proper review cycles

ORCHESTRATION RULES:
- Complex features: ARCHITECT -> CODER -> REVIEWER
- Bug fixes: CODER (fix) -> REVIEWER (verify)
- New systems: ARCHITECT (design) -> CODER (implement) -> REVIEWER (quality check)
- Always route through REVIEWER before finalizing code

OUTPUT FORMAT for task decomposition:
{
  "analysis": "Brief analysis of the objective",
  "tasks": [
    {
      "title": "Task title",
      "description": "What needs to be done",
      "assignTo": "coder|reviewer|architect",
      "dependencies": ["task-id if any"],
      "priority": "critical|high|medium|low"
    }
  ],
  "workflow": "Explanation of how tasks connect"
}

Remember: A great conductor brings out the best in each musician. Orchestrate for excellence.`;

export class Orchestrator {
  private client: Anthropic;
  private agents: Map<AgentRole, BaseAgent>;
  private config: OrchestratorConfig;
  private currentSession: Session | null = null;
  private conversationHistory: Array<{ role: 'user' | 'assistant'; content: string }> = [];

  constructor(config?: Partial<OrchestratorConfig>) {
    this.config = {
      maxConcurrentTasks: 3,
      defaultModel: 'claude-sonnet-4-20250514',
      verbose: true,
      autoRetry: true,
      maxRetries: 2,
      ...config,
    };

    this.client = new Anthropic();
    this.agents = new Map();

    // Initialize agents
    this.agents.set('coder', new CoderAgent(this.config.defaultModel));
    this.agents.set('reviewer', new ReviewerAgent(this.config.defaultModel));
    this.agents.set('architect', new ArchitectAgent(this.config.defaultModel));

    logger.info('Orchestrator initialized with agents: Coder, Reviewer, Architect');
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  async orchestrate(input: TaskInput): Promise<Session> {
    // Validate input
    const validatedInput = TaskInputSchema.parse(input);

    logger.banner();
    logger.divider();
    logger.info(`Starting orchestration for: ${validatedInput.objective}`);
    logger.divider();

    // Create session
    this.currentSession = {
      id: this.generateId(),
      objective: validatedInput.objective,
      tasks: [],
      messages: [],
      status: 'active',
      startedAt: new Date(),
    };

    try {
      // Step 1: Analyze and decompose the objective
      logger.agent('conductor', 'Analyzing objective and creating task plan...');
      const taskPlan = await this.analyzeObjective(validatedInput);

      // Step 2: Create tasks from the plan
      const tasks = this.createTasksFromPlan(taskPlan);
      this.currentSession.tasks = tasks;

      // Step 3: Execute tasks in order (respecting dependencies)
      await this.executeTasks(tasks);

      // Step 4: Synthesize final result
      logger.agent('conductor', 'Synthesizing final deliverable...');
      const finalResult = await this.synthesizeResult();

      this.currentSession.status = 'completed';
      this.currentSession.completedAt = new Date();

      logger.divider();
      logger.success('Orchestration completed successfully!');
      logger.divider();

      return this.currentSession;
    } catch (error) {
      logger.error(`Orchestration failed: ${error}`);
      if (this.currentSession) {
        this.currentSession.status = 'completed';
      }
      throw error;
    }
  }

  private async analyzeObjective(input: TaskInput): Promise<string> {
    const prompt = `Analyze this objective and create a task plan:

OBJECTIVE: ${input.objective}
${input.context ? `CONTEXT: ${input.context}` : ''}
${input.constraints ? `CONSTRAINTS: ${input.constraints.join(', ')}` : ''}
${input.preferredAgents ? `PREFERRED AGENTS: ${input.preferredAgents.join(', ')}` : ''}

Respond with a JSON task plan following the format specified.`;

    this.conversationHistory.push({ role: 'user', content: prompt });

    const response = await this.client.messages.create({
      model: this.config.defaultModel,
      max_tokens: 4096,
      system: CONDUCTOR_SYSTEM_PROMPT,
      messages: this.conversationHistory,
    });

    const responseText = response.content[0].type === 'text' ? response.content[0].text : '';
    this.conversationHistory.push({ role: 'assistant', content: responseText });

    return responseText;
  }

  private createTasksFromPlan(planJson: string): Task[] {
    try {
      // Extract JSON from response (handle markdown code blocks)
      const jsonMatch = planJson.match(/```(?:json)?\s*([\s\S]*?)```/) || [null, planJson];
      const jsonStr = jsonMatch[1] || planJson;

      const plan = JSON.parse(jsonStr);

      return (plan.tasks || []).map((task: { title: string; description: string; assignTo: AgentRole; dependencies?: string[]; priority?: string }, index: number) => ({
        id: `task-${index + 1}`,
        title: task.title,
        description: task.description,
        assignedTo: task.assignTo as AgentRole,
        status: 'pending' as const,
        priority: (task.priority || 'medium') as Task['priority'],
        dependencies: task.dependencies || [],
        createdAt: new Date(),
      }));
    } catch {
      logger.warn('Could not parse task plan JSON, creating default task');
      return [{
        id: 'task-1',
        title: 'Complete objective',
        description: this.currentSession?.objective || '',
        assignedTo: 'coder',
        status: 'pending',
        priority: 'high',
        dependencies: [],
        createdAt: new Date(),
      }];
    }
  }

  private async executeTasks(tasks: Task[]): Promise<void> {
    const completed = new Set<string>();

    while (completed.size < tasks.length) {
      // Find tasks that are ready (dependencies met)
      const readyTasks = tasks.filter(
        (t) =>
          t.status === 'pending' &&
          t.dependencies.every((dep) => completed.has(dep))
      );

      if (readyTasks.length === 0) {
        logger.error('No ready tasks but not all completed - possible circular dependency');
        break;
      }

      // Execute ready tasks (could be parallelized up to maxConcurrentTasks)
      for (const task of readyTasks.slice(0, this.config.maxConcurrentTasks)) {
        await this.executeTask(task);
        completed.add(task.id);
      }
    }
  }

  private async executeTask(task: Task): Promise<void> {
    task.status = 'in_progress';
    logger.task('started', task.title);

    const agent = this.agents.get(task.assignedTo);
    if (!agent) {
      logger.error(`No agent found for role: ${task.assignedTo}`);
      task.status = 'failed';
      return;
    }

    try {
      // Get context from previous tasks
      const context = this.getTaskContext(task);
      const input = context
        ? `${task.description}\n\nContext from previous tasks:\n${context}`
        : task.description;

      const result = await agent.think(input);

      task.result = result;
      task.status = 'completed';
      task.completedAt = new Date();

      // Log the message
      const message: AgentMessage = {
        id: this.generateId(),
        from: task.assignedTo,
        to: 'conductor',
        type: 'result',
        content: result,
        timestamp: new Date(),
      };
      this.currentSession?.messages.push(message);

      logger.task('completed', task.title);
    } catch (error) {
      task.status = 'failed';
      logger.task('failed', task.title);

      if (this.config.autoRetry) {
        logger.info(`Retrying task: ${task.title}`);
        task.status = 'pending';
        await this.executeTask(task);
      }
    }
  }

  private getTaskContext(task: Task): string {
    const completedTasks = this.currentSession?.tasks.filter(
      (t) => t.status === 'completed' && task.dependencies.includes(t.id)
    );

    if (!completedTasks || completedTasks.length === 0) return '';

    return completedTasks
      .map((t) => `[${t.title}]:\n${t.result}`)
      .join('\n\n');
  }

  private async synthesizeResult(): Promise<string> {
    const taskResults = this.currentSession?.tasks
      .filter((t) => t.status === 'completed')
      .map((t) => `### ${t.title}\n${t.result}`)
      .join('\n\n');

    const prompt = `Synthesize these task results into a coherent final deliverable:

${taskResults}

Provide a summary and any final recommendations.`;

    const response = await this.client.messages.create({
      model: this.config.defaultModel,
      max_tokens: 4096,
      system: 'You are synthesizing results from multiple AI agents. Create a coherent summary.',
      messages: [{ role: 'user', content: prompt }],
    });

    return response.content[0].type === 'text' ? response.content[0].text : '';
  }

  // Direct agent access for simple tasks
  async askCoder(request: string): Promise<string> {
    const coder = this.agents.get('coder');
    if (!coder) throw new Error('Coder agent not initialized');
    return coder.think(request);
  }

  async askReviewer(request: string): Promise<string> {
    const reviewer = this.agents.get('reviewer');
    if (!reviewer) throw new Error('Reviewer agent not initialized');
    return reviewer.think(request);
  }

  async askArchitect(request: string): Promise<string> {
    const architect = this.agents.get('architect');
    if (!architect) throw new Error('Architect agent not initialized');
    return architect.think(request);
  }

  getSession(): Session | null {
    return this.currentSession;
  }
}
