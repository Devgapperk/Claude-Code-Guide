# BrandMind LLMO Intelligence Launch Kit

> Wizard of Oz prototype for AI visibility monitoring. See how AI sees your brand.

## Quick Start

### Step 1: View the Prototype

```bash
open brandmind_llmo_tester.html
```

Or drag the HTML file into your browser. The prototype is fully self-contained.

### Step 2: Read Fleet Operations

Review `brandmind_fleet_ops.md` for:
- Boris Fleet agent protocols
- Async flag communication patterns
- LLMO PRD and success metrics
- Wizard of Oz → Full Automation transition plan

### Step 3: Set Up Backend (Phase 2)

```bash
# Initialize Supabase project
supabase init

# Run schema migration
supabase db push < supabase-schema.sql

# Deploy edge functions (coming soon)
supabase functions deploy capture-lead
supabase functions deploy process-scan
supabase functions deploy generate-report
```

## Files

| File | Purpose |
|------|---------|
| `brandmind_fleet_ops.md` | Boris Fleet protocols, LLMO PRD, async flag spec |
| `brandmind_llmo_tester.html` | Complete Wizard of Oz prototype (single file) |
| `supabase-schema.sql` | Database schema for leads, scans, reports, flags |

## Wizard of Oz Mode

The current prototype simulates AI analysis while capturing real leads:

1. **Frontend**: Beautiful, instant, feels like magic
2. **Capture**: All lead data stored in localStorage (or Supabase when connected)
3. **Delivery**: Manual analysis within 24 hours
4. **Tracking**: `viewLeads()` in browser console to see captured data

## Transition to Full Automation

| Phase | Frontend | Backend | Analysis |
|-------|----------|---------|----------|
| **1: WoZ** | Live | localStorage | Manual |
| **2: Hybrid** | Live | Supabase | Manual + AI assist |
| **3: Full** | Production | Supabase + Edge | Fully automated |

## Fleet Deployment

To spin up the Boris Fleet for this project:

```bash
# From orchestration root
./scripts/spawn-agents.sh brandmind-llmo

# Assign tasks via conductor
./scripts/conductor.sh assign fleet-06 "Connect HTML to Supabase"
./scripts/conductor.sh assign fleet-02 "Build AI platform query modules"
```

## Success Metrics (30-day targets)

- 1,000 landing page visitors
- 300 scans initiated
- 150 leads captured (50% conversion)
- 15 demo calls booked (10% of leads)
- 5 paid conversions (33% of demos)

---

**Version**: 1.0.0
**Last Updated**: 2025-01-09
**Maintained By**: Digital Dali Orchestration / Boris Fleet
