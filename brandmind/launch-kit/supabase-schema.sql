-- ==========================================
-- BrandMind LLMO Intelligence - Supabase Schema
-- Backend for Wizard of Oz → Full Automation transition
-- ==========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- LEADS TABLE
-- Captures all scan requests + contact info
-- ==========================================
CREATE TABLE leads (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Contact Info
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    company TEXT,
    role TEXT,

    -- Scan Details
    brand_name TEXT NOT NULL,
    category TEXT NOT NULL,
    market TEXT NOT NULL,
    competitor TEXT,

    -- Results (populated after analysis)
    visibility_score INTEGER,
    scan_status TEXT DEFAULT 'pending' CHECK (scan_status IN ('pending', 'processing', 'complete', 'failed')),

    -- Tracking
    source TEXT DEFAULT 'llmo_tester',
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,

    -- Engagement
    full_report_requested BOOLEAN DEFAULT FALSE,
    full_report_sent_at TIMESTAMPTZ,
    demo_booked BOOLEAN DEFAULT FALSE,
    converted BOOLEAN DEFAULT FALSE
);

-- Index for email lookups
CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_brand ON leads(brand_name);
CREATE INDEX idx_leads_status ON leads(scan_status);

-- ==========================================
-- SCANS TABLE
-- Detailed scan results per platform
-- ==========================================
CREATE TABLE scans (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Scan Configuration
    brand_name TEXT NOT NULL,
    category TEXT NOT NULL,
    market TEXT NOT NULL,
    prompts_tested JSONB, -- Array of prompts used

    -- Overall Results
    visibility_score INTEGER CHECK (visibility_score >= 0 AND visibility_score <= 100),
    mention_rate DECIMAL(5,2), -- Percentage
    sentiment TEXT CHECK (sentiment IN ('positive', 'neutral', 'negative', 'mixed')),

    -- Platform Breakdown (JSONB for flexibility)
    platform_results JSONB,
    /*
    Example structure:
    {
        "chatgpt": {
            "mentioned": true,
            "position": "secondary",
            "prompts_mentioned": 2,
            "prompts_total": 5,
            "sentiment": "positive",
            "excerpts": ["..."]
        },
        "perplexity": {...},
        "claude": {...},
        "gemini": {...}
    }
    */

    -- Citation Analysis
    citation_sources JSONB,
    /*
    Example:
    {
        "wikipedia": {"present": false, "action": "Create page"},
        "reddit": {"present": true, "quality": "weak"},
        "youtube": {"present": false, "action": "Create content"}
    }
    */

    -- Competitor Comparison
    competitor_data JSONB,

    -- Recommendations
    recommendations JSONB,

    -- Processing metadata
    processing_time_ms INTEGER,
    model_used TEXT,
    raw_responses JSONB -- Store raw AI responses for debugging
);

CREATE INDEX idx_scans_lead ON scans(lead_id);
CREATE INDEX idx_scans_brand ON scans(brand_name);

-- ==========================================
-- PROMPTS TABLE
-- Library of test prompts by category
-- ==========================================
CREATE TABLE prompts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    category TEXT NOT NULL,
    prompt_type TEXT CHECK (prompt_type IN ('discovery', 'comparison', 'problem_solution', 'brand_specific')),
    prompt_template TEXT NOT NULL, -- Use {{BRAND}} and {{CATEGORY}} placeholders
    platforms TEXT[] DEFAULT ARRAY['chatgpt', 'perplexity', 'claude', 'gemini'],
    is_active BOOLEAN DEFAULT TRUE,
    success_rate DECIMAL(5,2) -- Track which prompts reveal brand mentions best
);

-- Seed initial prompts
INSERT INTO prompts (category, prompt_type, prompt_template) VALUES
    ('supplements', 'discovery', 'What are the best {{CATEGORY}} supplements?'),
    ('supplements', 'discovery', 'Which {{CATEGORY}} brands do you recommend?'),
    ('supplements', 'comparison', 'Compare {{BRAND}} vs other {{CATEGORY}} brands'),
    ('supplements', 'problem_solution', 'What helps with low energy and fatigue?'),
    ('supplements', 'brand_specific', 'What do you know about {{BRAND}}?'),
    ('skincare', 'discovery', 'Best {{CATEGORY}} products for anti-aging'),
    ('skincare', 'comparison', '{{BRAND}} vs The Ordinary - which is better?'),
    ('saas', 'discovery', 'What are the best {{CATEGORY}} tools in 2025?'),
    ('saas', 'comparison', 'Compare {{BRAND}} alternatives'),
    ('general', 'brand_specific', 'Is {{BRAND}} any good?');

-- ==========================================
-- REPORTS TABLE
-- Generated reports (for email delivery)
-- ==========================================
CREATE TABLE reports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
    scan_id UUID REFERENCES scans(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    report_type TEXT CHECK (report_type IN ('instant', 'full', 'competitive')),
    report_content JSONB, -- Structured report data
    report_html TEXT, -- Rendered HTML for email
    pdf_url TEXT, -- If we generate PDFs

    sent_at TIMESTAMPTZ,
    opened_at TIMESTAMPTZ,
    clicked_at TIMESTAMPTZ
);

CREATE INDEX idx_reports_lead ON reports(lead_id);

-- ==========================================
-- ASYNC FLAGS TABLE
-- Boris Fleet communication layer
-- ==========================================
CREATE TABLE async_flags (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '1 hour'),

    flag_type TEXT NOT NULL,
    /*
    Types: FLAG_SCAN_COMPLETE, FLAG_ANALYSIS_READY, FLAG_REPORT_GENERATED,
           FLAG_EMAIL_SENT, FLAG_BLOCKED, FLAG_ESCALATED
    */

    agent_id TEXT NOT NULL, -- e.g., 'fleet-02' (Scout)
    status TEXT DEFAULT 'PROCESSING' CHECK (status IN ('IDLE', 'CLAIMED', 'PROCESSING', 'BLOCKED', 'COMPLETE', 'FAILED', 'ESCALATED')),

    payload JSONB, -- Task-specific data
    result JSONB, -- Output data

    related_lead_id UUID REFERENCES leads(id),
    related_scan_id UUID REFERENCES scans(id),

    next_agents TEXT[], -- Which agents should pick up when complete
    error_message TEXT,
    retry_count INTEGER DEFAULT 0
);

CREATE INDEX idx_flags_type ON async_flags(flag_type);
CREATE INDEX idx_flags_status ON async_flags(status);
CREATE INDEX idx_flags_agent ON async_flags(agent_id);

-- Auto-cleanup expired flags
CREATE OR REPLACE FUNCTION cleanup_expired_flags()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM async_flags WHERE expires_at < NOW();
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- ROW LEVEL SECURITY
-- ==========================================
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Service role can do everything
CREATE POLICY "Service role full access" ON leads FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Service role full access" ON scans FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Service role full access" ON reports FOR ALL USING (auth.role() = 'service_role');

-- ==========================================
-- EDGE FUNCTION HOOKS (Comments for reference)
-- ==========================================
/*
Create these Supabase Edge Functions:

1. capture-lead
   - Triggered on new lead insert
   - Sends Slack/email notification
   - Creates initial async flag for processing

2. process-scan
   - Called by Scout agent
   - Queries AI platforms (or simulates in WoZ mode)
   - Updates scans table
   - Creates FLAG_SCAN_COMPLETE

3. generate-report
   - Called when scan complete
   - Compiles recommendations
   - Sends email via Resend/SendGrid
   - Updates FLAG_REPORT_GENERATED

4. webhook-receiver
   - Receives external events (email opens, clicks)
   - Updates engagement tracking
*/

-- ==========================================
-- VIEWS
-- ==========================================
CREATE VIEW lead_pipeline AS
SELECT
    l.id,
    l.name,
    l.email,
    l.company,
    l.brand_name,
    l.category,
    l.visibility_score,
    l.scan_status,
    l.full_report_requested,
    l.demo_booked,
    l.converted,
    l.created_at,
    COUNT(s.id) as scan_count,
    MAX(s.created_at) as last_scan_at
FROM leads l
LEFT JOIN scans s ON s.lead_id = l.id
GROUP BY l.id;

-- Daily metrics view
CREATE VIEW daily_metrics AS
SELECT
    DATE(created_at) as date,
    COUNT(*) as leads,
    COUNT(*) FILTER (WHERE full_report_requested) as reports_requested,
    COUNT(*) FILTER (WHERE demo_booked) as demos_booked,
    COUNT(*) FILTER (WHERE converted) as conversions,
    AVG(visibility_score) as avg_score
FROM leads
GROUP BY DATE(created_at)
ORDER BY date DESC;
