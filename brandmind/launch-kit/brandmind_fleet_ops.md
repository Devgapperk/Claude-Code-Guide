# BrandMind Fleet Operations
## Boris Fleet Protocols & LLMO Intelligence PRD

> "One conductor. Many performers. Zero blocking calls."

---

## The Boris Fleet Philosophy

The Boris Fleet is not a team—it's an **orchestra of autonomous agents** executing in parallel, coordinated by async flags rather than synchronous handoffs.

### Core Principles

1. **Non-Blocking Architecture**: Every agent operates independently. No agent waits for another.
2. **Async Flag Communication**: Agents signal state changes via flags, not direct calls.
3. **Eventual Consistency**: Results converge; they don't synchronize.
4. **Graceful Degradation**: If one agent fails, others continue. The show goes on.

---

## Fleet Composition

### Primary Fleet (Active Agents)

| Agent ID | Codename | Role | Model | Async Flag |
|----------|----------|------|-------|------------|
| `fleet-01` | **Conductor** | Orchestration, routing, conflict resolution | Opus | `FLAG_CONDUCTOR_READY` |
| `fleet-02` | **Scout** | LLMO monitoring, visibility scanning | Sonnet | `FLAG_SCAN_COMPLETE` |
| `fleet-03` | **Analyst** | Data synthesis, competitive intelligence | Sonnet | `FLAG_ANALYSIS_READY` |
| `fleet-04` | **Wordsmith** | Content generation, copy optimization | Sonnet | `FLAG_CONTENT_GENERATED` |
| `fleet-05` | **Validator** | Compliance checking, quality gates | Opus | `FLAG_VALIDATED` |
| `fleet-06` | **Builder** | Frontend/backend implementation | Sonnet | `FLAG_BUILD_COMPLETE` |
| `fleet-07` | **Scribe** | Documentation, logging, reporting | Haiku | `FLAG_DOCUMENTED` |

### Reserve Fleet (On-Demand)

| Agent ID | Codename | Specialty | Trigger |
|----------|----------|-----------|---------|
| `fleet-r1` | **Firefighter** | Critical bug fixes, emergency patches | `FLAG_CRITICAL_ISSUE` |
| `fleet-r2` | **Diplomat** | Client communication drafts | `FLAG_CLIENT_FACING` |
| `fleet-r3` | **Auditor** | Security review, penetration testing | `FLAG_SECURITY_SCAN` |

---

## Async Flag Protocol

### Flag States

```
IDLE        → Agent waiting for work
CLAIMED     → Agent has picked up task
PROCESSING  → Agent actively working
BLOCKED     → Agent waiting on external dependency
COMPLETE    → Task finished, results available
FAILED      → Task failed, error logged
ESCALATED   → Requires human or Opus intervention
```

### Flag Communication Flow

```
┌─────────────┐     FLAG_TASK_AVAILABLE      ┌─────────────┐
│  Conductor  │ ─────────────────────────────▶│    Scout    │
└─────────────┘                               └─────────────┘
                                                     │
                                              FLAG_SCAN_COMPLETE
                                                     │
                                                     ▼
┌─────────────┐     FLAG_ANALYSIS_READY      ┌─────────────┐
│  Wordsmith  │ ◀─────────────────────────────│   Analyst   │
└─────────────┘                               └─────────────┘
       │
FLAG_CONTENT_GENERATED
       │
       ▼
┌─────────────┐     FLAG_VALIDATED           ┌─────────────┐
│  Validator  │ ─────────────────────────────▶│   Builder   │
└─────────────┘                               └─────────────┘
```

### Flag File Format

```json
{
  "flag_id": "FLAG_SCAN_COMPLETE_20250109_143022",
  "agent": "fleet-02",
  "status": "COMPLETE",
  "timestamp": "2025-01-09T14:30:22Z",
  "payload": {
    "task_id": "llmo-scan-nordvpn",
    "results_path": "/outputs/scans/nordvpn_visibility.json",
    "summary": "12 platforms scanned, 3 citations found"
  },
  "next_agents": ["fleet-03", "fleet-04"],
  "ttl_seconds": 3600
}
```

---

## The Wizard of Oz Strategy

### Purpose

Validate market demand **before** building complex infrastructure. The frontend appears fully functional while backend operations are manually orchestrated or simulated.

### Implementation Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT-FACING LAYER                       │
│         (Beautiful UI, instant feedback, magic feel)         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    ILLUSION LAYER                            │
│    Simulated delays, progress animations, "AI thinking"      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAPTURE LAYER                             │
│          Lead data → Supabase/Firebase → Notification        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    MANUAL EXECUTION                          │
│     Human/Claude generates real analysis within 24h          │
└─────────────────────────────────────────────────────────────┘
```

### Wizard of Oz Checklist

- [ ] UI feels instantaneous and premium
- [ ] "Processing" states create anticipation (2-5 second delays)
- [ ] Lead capture happens BEFORE showing results
- [ ] Results appear "AI-generated" even if manual
- [ ] Email follow-up triggers within 1 hour
- [ ] Full analysis delivered within 24 hours

### Transition to Full Automation

| Phase | Frontend | Backend | Delivery |
|-------|----------|---------|----------|
| **Phase 1: Wizard** | Live prototype | Manual/simulated | Human-generated |
| **Phase 2: Hybrid** | Production app | Partial automation | Mixed |
| **Phase 3: Full** | Production app | Full AI pipeline | Automated |

---

## LLMO Intelligence Tool PRD

### Product Overview

**Name**: BrandMind LLMO Intelligence Monitor
**Tagline**: "See how AI sees your brand"
**Target User**: Marketing leaders, brand managers, SEO professionals
**Value Proposition**: Real-time visibility into how ChatGPT, Perplexity, Claude, and other AI platforms perceive and recommend your brand.

### The Problem

- 200M+ weekly ChatGPT users making purchase decisions
- 34% CTR decline for traditional SEO as AI Overviews dominate
- Brands have ZERO visibility into AI recommendations
- First-mover advantage window: 12-18 months

### Core Features (MVP)

#### 1. Brand Visibility Scan
**User Action**: Enter brand name + category
**Output**: Visibility score (0-100) across AI platforms

```json
{
  "brand": "Harmoni Balanse",
  "category": "supplements",
  "visibility_score": 42,
  "platform_breakdown": {
    "chatgpt": {"mentioned": false, "competitor_visible": true},
    "perplexity": {"mentioned": true, "position": 4},
    "claude": {"mentioned": false, "competitor_visible": true},
    "gemini": {"mentioned": false, "competitor_visible": false}
  },
  "recommendation": "Critical gap in ChatGPT visibility. Competitor 'Nordic Naturals' dominates."
}
```

#### 2. Competitive Benchmark
**User Action**: Enter up to 3 competitors
**Output**: Side-by-side AI visibility comparison

#### 3. Citation Source Analysis
**User Action**: Run scan
**Output**: Which sources AI platforms cite when discussing the category

```json
{
  "citation_sources": {
    "wikipedia": {"weight": "47.9%", "our_presence": "absent"},
    "reddit": {"weight": "46.7%", "our_presence": "weak"},
    "youtube": {"weight": "13.9%", "our_presence": "none"}
  },
  "action_items": [
    "Create Wikipedia page (if notability criteria met)",
    "Build Reddit presence in r/supplements",
    "Launch YouTube educational series"
  ]
}
```

#### 4. Prompt Library Testing
**User Action**: Select category
**Output**: Pre-built prompts that reveal AI perception

### User Journey

```
1. LAND     → Homepage with clear value prop
2. TEST     → Free "quick scan" (email-gated after results preview)
3. CAPTURE  → Lead form with brand + email + company
4. DELIVER  → Instant preliminary score + "Full report in 24h" promise
5. FOLLOW   → Email with full analysis + call-to-action
6. CONVERT  → Paid tier or consultation booking
```

### Pricing Model (Future)

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0 | 1 scan/month, basic visibility score |
| **Growth** | $99/mo | 10 scans/month, competitor tracking |
| **Enterprise** | $499/mo | Unlimited scans, API access, weekly reports |

### Technical Requirements

#### Frontend
- React/Next.js or vanilla HTML/CSS/JS (prototype)
- Dark mode, premium aesthetic (Digital Dali brand)
- Mobile responsive
- Real-time progress indicators

#### Backend (Phase 2+)
- Supabase for lead storage + auth
- Edge functions for AI platform queries
- Queue system for async processing
- Caching layer for repeated queries

#### Integrations
- Anthropic API (Claude queries)
- OpenAI API (ChatGPT simulation)
- Perplexity API (when available)
- SendGrid/Resend for transactional email

### Success Metrics

| Metric | Target (30 days) |
|--------|------------------|
| Landing page visitors | 1,000 |
| Scans initiated | 300 |
| Leads captured | 150 (50% conversion) |
| Full reports delivered | 150 |
| Demo calls booked | 15 (10% of leads) |
| Paid conversions | 5 (33% of demos) |

---

## Fleet Deployment: LLMO Tool Build

### Task Distribution

```yaml
CONDUCTOR (fleet-01):
  - Route incoming feature requests
  - Monitor flag status
  - Resolve conflicts between agents
  - Escalate blockers to human

SCOUT (fleet-02):
  - Build AI platform query modules
  - Test prompt effectiveness
  - Gather competitive intelligence

ANALYST (fleet-03):
  - Design scoring algorithm
  - Create benchmark calculations
  - Build citation source parser

WORDSMITH (fleet-04):
  - Write UI copy
  - Generate report templates
  - Create email sequences

VALIDATOR (fleet-05):
  - Review AI output accuracy
  - Test edge cases
  - Ensure data privacy compliance

BUILDER (fleet-06):
  - Implement frontend prototype
  - Set up Supabase schema
  - Build API endpoints

SCRIBE (fleet-07):
  - Document all decisions
  - Update CHANGELOG
  - Generate user documentation
```

### Sprint Timeline (Wizard of Oz Phase)

| Day | Focus | Deliverable |
|-----|-------|-------------|
| 1 | Frontend prototype | `brandmind_llmo_tester.html` |
| 2 | Lead capture backend | Supabase tables + edge function |
| 3 | Email automation | Instant + 24h follow-up sequences |
| 4 | Manual analysis process | SOP for generating reports |
| 5 | Testing + soft launch | 10 beta users |

---

## Quality Gates

### Before Launch

- [ ] UI loads in < 2 seconds
- [ ] Mobile experience flawless
- [ ] Lead capture working (test with 5 emails)
- [ ] Email sequences triggered correctly
- [ ] Manual analysis process documented
- [ ] Error states handled gracefully
- [ ] Privacy policy + terms in place

### Post-Launch Monitoring

- [ ] Daily: Lead count, bounce rate
- [ ] Weekly: Conversion rates, user feedback
- [ ] Monthly: CAC, LTV projections

---

## Escalation Protocol

### When to Escalate to Human

1. **Security concern**: Any data breach suspicion
2. **Brand risk**: Output that could damage reputation
3. **Technical blocker**: > 2 hours stuck on issue
4. **Compliance question**: GDPR, legal uncertainty
5. **Budget decision**: > $50 spend required

### Escalation Format

```
ESCALATION: [CATEGORY]
Agent: [CODENAME]
Flag: [CURRENT_FLAG]
Issue: [DESCRIPTION]
Options: [A / B / C]
Recommendation: [AGENT'S PREFERRED OPTION]
Urgency: [LOW / MEDIUM / HIGH / CRITICAL]
```

---

## Appendix: Async Flag Reference

| Flag | Meaning | Next Action |
|------|---------|-------------|
| `FLAG_CONDUCTOR_READY` | Orchestrator online | Accept task queue |
| `FLAG_TASK_AVAILABLE` | New work queued | Agent claims task |
| `FLAG_SCAN_COMPLETE` | Visibility scan done | Trigger analysis |
| `FLAG_ANALYSIS_READY` | Data synthesized | Generate content |
| `FLAG_CONTENT_GENERATED` | Copy ready | Validate compliance |
| `FLAG_VALIDATED` | Quality gate passed | Deploy/deliver |
| `FLAG_BUILD_COMPLETE` | Code shipped | Run tests |
| `FLAG_DOCUMENTED` | Docs updated | Close task |
| `FLAG_CRITICAL_ISSUE` | Emergency detected | Firefighter claims |
| `FLAG_CLIENT_FACING` | External comms needed | Diplomat claims |
| `FLAG_BLOCKED` | Agent stuck | Conductor intervenes |
| `FLAG_ESCALATED` | Human needed | Pause and notify |

---

*This document is the source of truth for Boris Fleet operations. All agents reference this file before execution.*

**Version**: 1.0.0
**Last Updated**: 2025-01-09
**Maintained By**: Digital Dali Orchestration System
