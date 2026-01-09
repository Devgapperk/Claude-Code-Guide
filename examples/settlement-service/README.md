# Settlement Service Example

> A real-world microservice demonstrating Claude Code orchestration patterns for enterprise financial systems.

## What This Demonstrates

This example shows how 6 parallel Claude Code agents can build a production-grade settlement service in 24-48 hours—a system that traditionally takes 2-3 months with a team of engineers.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway                            │
│                   (REST + GraphQL)                          │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
┌───────────┐  ┌───────────┐  ┌───────────┐
│Transaction│  │  Account  │  │  Audit    │
│  Service  │  │  Service  │  │  Service  │
└─────┬─────┘  └─────┬─────┘  └─────┬─────┘
      │              │              │
      └──────────────┼──────────────┘
                     │
              ┌──────┴──────┐
              │  PostgreSQL │
              │   (Ledger)  │
              └─────────────┘
```

## Agent Task Distribution

| Agent | Responsibility | Files |
|-------|---------------|-------|
| 1 | Database schema + migrations | `src/db/` |
| 2 | Transaction service | `src/services/transaction.ts` |
| 3 | Account service | `src/services/account.ts` |
| 4 | REST API + auth | `src/api/` |
| 5 | Audit logging | `src/services/audit.ts` |
| 6 | Integration tests | `tests/` |

## Key Patterns

### Double-Entry Bookkeeping
Every transaction creates two ledger entries (debit + credit) that must balance.

### Idempotent Operations
Batch processing uses idempotency keys to prevent duplicate settlements.

### Audit Trail
Append-only audit log with HMAC signatures for tamper detection.

### Event-Driven
Transaction events published to message queue for downstream consumers.

## Quick Start

```bash
# Install dependencies
npm install

# Set up database
docker-compose up -d postgres
npm run db:migrate

# Run tests
npm test

# Start service
npm run dev
```

## Files Structure

```
examples/settlement-service/
├── src/
│   ├── db/
│   │   ├── schema.ts          # Drizzle schema definitions
│   │   └── migrations/        # Database migrations
│   ├── services/
│   │   ├── transaction.ts     # Transaction processing
│   │   ├── account.ts         # Account management
│   │   └── audit.ts           # Audit logging
│   ├── api/
│   │   ├── routes.ts          # API endpoint definitions
│   │   └── middleware.ts      # Auth, validation, logging
│   └── index.ts               # Application entry point
├── tests/
│   ├── transaction.test.ts
│   ├── account.test.ts
│   └── integration.test.ts
├── docker-compose.yml
├── package.json
└── README.md
```

## Enterprise Considerations

This example demonstrates patterns applicable to:
- **Payment processing** (T+1 settlement batches)
- **Interbank transfers** (ISO 20022 / MT message compatibility)
- **Regulatory compliance** (immutable audit trails)
- **Multi-currency** (extensible for FX settlement)

The same orchestration pattern scales to 50+ agents for full enterprise platforms including compliance modules, multi-region deployment, and 99.99% uptime requirements.
