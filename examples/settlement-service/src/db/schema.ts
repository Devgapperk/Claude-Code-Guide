import { pgTable, uuid, varchar, decimal, timestamp, text, boolean, index } from 'drizzle-orm/pg-core';

/**
 * Settlement Service Database Schema
 *
 * Demonstrates enterprise patterns:
 * - Double-entry bookkeeping (ledger entries)
 * - Immutable audit trails
 * - Idempotent operations (idempotency keys)
 * - Soft deletes for compliance
 */

// Accounts table - holds balance information
export const accounts = pgTable('accounts', {
  id: uuid('id').primaryKey().defaultRandom(),
  accountNumber: varchar('account_number', { length: 34 }).notNull().unique(), // IBAN format
  accountType: varchar('account_type', { length: 20 }).notNull(), // 'checking', 'savings', 'settlement'
  currency: varchar('currency', { length: 3 }).notNull().default('EUR'),
  balance: decimal('balance', { precision: 18, scale: 2 }).notNull().default('0.00'),
  availableBalance: decimal('available_balance', { precision: 18, scale: 2 }).notNull().default('0.00'),
  status: varchar('status', { length: 20 }).notNull().default('active'), // 'active', 'frozen', 'closed'
  ownerId: uuid('owner_id').notNull(),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
}, (table) => [
  index('accounts_owner_idx').on(table.ownerId),
  index('accounts_status_idx').on(table.status),
]);

// Transactions table - payment instructions
export const transactions = pgTable('transactions', {
  id: uuid('id').primaryKey().defaultRandom(),
  idempotencyKey: varchar('idempotency_key', { length: 64 }).notNull().unique(),
  type: varchar('type', { length: 20 }).notNull(), // 'transfer', 'deposit', 'withdrawal', 'fee'
  status: varchar('status', { length: 20 }).notNull().default('pending'), // 'pending', 'processing', 'completed', 'failed', 'reversed'
  fromAccountId: uuid('from_account_id').references(() => accounts.id),
  toAccountId: uuid('to_account_id').references(() => accounts.id),
  amount: decimal('amount', { precision: 18, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 3 }).notNull(),
  description: text('description'),
  reference: varchar('reference', { length: 140 }), // SWIFT reference format
  valueDate: timestamp('value_date').notNull(),
  processedAt: timestamp('processed_at'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
}, (table) => [
  index('transactions_from_account_idx').on(table.fromAccountId),
  index('transactions_to_account_idx').on(table.toAccountId),
  index('transactions_status_idx').on(table.status),
  index('transactions_value_date_idx').on(table.valueDate),
]);

// Ledger entries - double-entry bookkeeping
export const ledgerEntries = pgTable('ledger_entries', {
  id: uuid('id').primaryKey().defaultRandom(),
  transactionId: uuid('transaction_id').notNull().references(() => transactions.id),
  accountId: uuid('account_id').notNull().references(() => accounts.id),
  entryType: varchar('entry_type', { length: 10 }).notNull(), // 'debit', 'credit'
  amount: decimal('amount', { precision: 18, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 3 }).notNull(),
  balanceAfter: decimal('balance_after', { precision: 18, scale: 2 }).notNull(),
  createdAt: timestamp('created_at').notNull().defaultNow(),
}, (table) => [
  index('ledger_account_idx').on(table.accountId),
  index('ledger_transaction_idx').on(table.transactionId),
  index('ledger_created_at_idx').on(table.createdAt),
]);

// Settlement batches - for T+1 processing
export const settlementBatches = pgTable('settlement_batches', {
  id: uuid('id').primaryKey().defaultRandom(),
  batchNumber: varchar('batch_number', { length: 20 }).notNull().unique(),
  status: varchar('status', { length: 20 }).notNull().default('pending'), // 'pending', 'processing', 'completed', 'failed'
  transactionCount: decimal('transaction_count', { precision: 10, scale: 0 }).notNull().default('0'),
  totalAmount: decimal('total_amount', { precision: 18, scale: 2 }).notNull().default('0.00'),
  currency: varchar('currency', { length: 3 }).notNull(),
  settlementDate: timestamp('settlement_date').notNull(),
  processedAt: timestamp('processed_at'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
}, (table) => [
  index('batch_status_idx').on(table.status),
  index('batch_settlement_date_idx').on(table.settlementDate),
]);

// Audit log - immutable, append-only
export const auditLog = pgTable('audit_log', {
  id: uuid('id').primaryKey().defaultRandom(),
  entityType: varchar('entity_type', { length: 50 }).notNull(), // 'transaction', 'account', 'batch'
  entityId: uuid('entity_id').notNull(),
  action: varchar('action', { length: 50 }).notNull(), // 'created', 'updated', 'status_changed'
  previousState: text('previous_state'), // JSON snapshot
  newState: text('new_state'), // JSON snapshot
  changedBy: uuid('changed_by'), // User or system ID
  changedByType: varchar('changed_by_type', { length: 20 }).notNull(), // 'user', 'system', 'batch'
  ipAddress: varchar('ip_address', { length: 45 }),
  userAgent: text('user_agent'),
  hmacSignature: varchar('hmac_signature', { length: 64 }).notNull(), // Tamper detection
  createdAt: timestamp('created_at').notNull().defaultNow(),
}, (table) => [
  index('audit_entity_idx').on(table.entityType, table.entityId),
  index('audit_created_at_idx').on(table.createdAt),
  index('audit_changed_by_idx').on(table.changedBy),
]);

// Type exports for use in services
export type Account = typeof accounts.$inferSelect;
export type NewAccount = typeof accounts.$inferInsert;
export type Transaction = typeof transactions.$inferSelect;
export type NewTransaction = typeof transactions.$inferInsert;
export type LedgerEntry = typeof ledgerEntries.$inferSelect;
export type AuditLogEntry = typeof auditLog.$inferSelect;
