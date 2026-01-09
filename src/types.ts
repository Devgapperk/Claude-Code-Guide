import { z } from 'zod';

// Agent roles in the orchestration
export type AgentRole = 'conductor' | 'coder' | 'reviewer' | 'architect' | 'researcher';

// Task priority levels
export type Priority = 'critical' | 'high' | 'medium' | 'low';

// Task status
export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'failed' | 'blocked';

// Message between agents
export interface AgentMessage {
  id: string;
  from: AgentRole;
  to: AgentRole | 'broadcast';
  type: 'task' | 'result' | 'query' | 'feedback';
  content: string;
  metadata?: Record<string, unknown>;
  timestamp: Date;
}

// Task definition
export interface Task {
  id: string;
  title: string;
  description: string;
  assignedTo: AgentRole;
  status: TaskStatus;
  priority: Priority;
  dependencies: string[];
  result?: string;
  createdAt: Date;
  completedAt?: Date;
}

// Agent configuration
export interface AgentConfig {
  role: AgentRole;
  name: string;
  systemPrompt: string;
  model: 'claude-sonnet-4-20250514' | 'claude-opus-4-20250514' | 'claude-3-5-haiku-20241022';
  temperature?: number;
  maxTokens?: number;
}

// Orchestration session
export interface Session {
  id: string;
  objective: string;
  tasks: Task[];
  messages: AgentMessage[];
  status: 'active' | 'paused' | 'completed';
  startedAt: Date;
  completedAt?: Date;
}

// Orchestrator configuration
export interface OrchestratorConfig {
  maxConcurrentTasks: number;
  defaultModel: AgentConfig['model'];
  verbose: boolean;
  autoRetry: boolean;
  maxRetries: number;
}

// Schema for validating task input
export const TaskInputSchema = z.object({
  objective: z.string().min(1, 'Objective is required'),
  context: z.string().optional(),
  constraints: z.array(z.string()).optional(),
  preferredAgents: z.array(z.enum(['coder', 'reviewer', 'architect', 'researcher'])).optional(),
});

export type TaskInput = z.infer<typeof TaskInputSchema>;
