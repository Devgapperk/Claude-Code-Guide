#!/bin/bash
#
# DevOps Agent Setup Script
# Configures all credentials for autonomous infrastructure management
#
# Usage: ./scripts/setup-devops-agent.sh
#

set -e

SECRETS_DIR="$(dirname "$0")/../secrets"
ENV_FILE="$SECRETS_DIR/devops.env"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           DEVOPS AGENT CREDENTIAL SETUP                      ║"
echo "║                                                              ║"
echo "║  This script configures the DevOps agent with access to:    ║"
echo "║  • Supabase (database, edge functions)                      ║"
echo "║  • Vercel (deployments, domains)                            ║"
echo "║  • GitHub (repos, secrets, workflows)                       ║"
echo "║                                                              ║"
echo "║  All credentials are stored locally and never committed.    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Create secrets directory if it doesn't exist
mkdir -p "$SECRETS_DIR"

# Function to prompt for credential
prompt_credential() {
    local name=$1
    local description=$2
    local url=$3
    local current_value=""

    # Check if already set
    if [ -f "$ENV_FILE" ]; then
        current_value=$(grep "^$name=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2-)
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$description"
    echo "Get it here: $url"
    echo ""

    if [ -n "$current_value" ]; then
        echo "Current: ${current_value:0:20}... (press Enter to keep)"
    fi

    read -p "$name: " new_value

    if [ -n "$new_value" ]; then
        echo "$new_value"
    elif [ -n "$current_value" ]; then
        echo "$current_value"
    else
        echo ""
    fi
}

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "                      SUPABASE"
echo "══════════════════════════════════════════════════════════════"

SUPABASE_ACCESS_TOKEN=$(prompt_credential \
    "SUPABASE_ACCESS_TOKEN" \
    "Supabase Access Token (for creating projects)" \
    "https://supabase.com/dashboard/account/tokens")

SUPABASE_ORG_ID=$(prompt_credential \
    "SUPABASE_ORG_ID" \
    "Supabase Organization ID" \
    "https://supabase.com/dashboard/org/_/settings → Organization ID")

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "                      VERCEL"
echo "══════════════════════════════════════════════════════════════"

VERCEL_TOKEN=$(prompt_credential \
    "VERCEL_TOKEN" \
    "Vercel Access Token" \
    "https://vercel.com/account/tokens")

VERCEL_ORG_ID=$(prompt_credential \
    "VERCEL_ORG_ID" \
    "Vercel Team/Org ID (optional, for team deployments)" \
    "https://vercel.com/teams → Settings → General")

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "                      GITHUB"
echo "══════════════════════════════════════════════════════════════"

GITHUB_TOKEN=$(prompt_credential \
    "GITHUB_TOKEN" \
    "GitHub Personal Access Token (scopes: repo, workflow)" \
    "https://github.com/settings/tokens/new")

GITHUB_ORG=$(prompt_credential \
    "GITHUB_ORG" \
    "GitHub Organization/Username" \
    "Your GitHub username or org name")

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "                   OPTIONAL SERVICES"
echo "══════════════════════════════════════════════════════════════"

read -p "Configure Anthropic API key? (y/N): " configure_anthropic
if [[ "$configure_anthropic" =~ ^[Yy]$ ]]; then
    ANTHROPIC_API_KEY=$(prompt_credential \
        "ANTHROPIC_API_KEY" \
        "Anthropic API Key" \
        "https://console.anthropic.com/settings/keys")
fi

read -p "Configure Resend (email)? (y/N): " configure_resend
if [[ "$configure_resend" =~ ^[Yy]$ ]]; then
    RESEND_API_KEY=$(prompt_credential \
        "RESEND_API_KEY" \
        "Resend API Key" \
        "https://resend.com/api-keys")
fi

read -p "Configure Cloudflare (DNS)? (y/N): " configure_cloudflare
if [[ "$configure_cloudflare" =~ ^[Yy]$ ]]; then
    CLOUDFLARE_API_TOKEN=$(prompt_credential \
        "CLOUDFLARE_API_TOKEN" \
        "Cloudflare API Token" \
        "https://dash.cloudflare.com/profile/api-tokens")
    CLOUDFLARE_ACCOUNT_ID=$(prompt_credential \
        "CLOUDFLARE_ACCOUNT_ID" \
        "Cloudflare Account ID" \
        "https://dash.cloudflare.com → Account ID in sidebar")
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "                   SAVING CREDENTIALS"
echo "══════════════════════════════════════════════════════════════"

# Write to env file
cat > "$ENV_FILE" << EOF
# DevOps Agent Credentials
# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# DO NOT COMMIT THIS FILE

# Supabase
SUPABASE_ACCESS_TOKEN=$SUPABASE_ACCESS_TOKEN
SUPABASE_ORG_ID=$SUPABASE_ORG_ID

# Vercel
VERCEL_TOKEN=$VERCEL_TOKEN
VERCEL_ORG_ID=$VERCEL_ORG_ID

# GitHub
GITHUB_TOKEN=$GITHUB_TOKEN
GITHUB_ORG=$GITHUB_ORG

# Anthropic
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}

# Resend
RESEND_API_KEY=${RESEND_API_KEY:-}

# Cloudflare
CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN:-}
CLOUDFLARE_ACCOUNT_ID=${CLOUDFLARE_ACCOUNT_ID:-}
EOF

echo "✓ Credentials saved to: $ENV_FILE"

# Verify gitignore
if ! grep -q "secrets/" .gitignore 2>/dev/null; then
    echo "secrets/" >> .gitignore
    echo "✓ Added secrets/ to .gitignore"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "                   TESTING CONNECTIONS"
echo "══════════════════════════════════════════════════════════════"

# Source the env file
source "$ENV_FILE"

# Test Supabase
if [ -n "$SUPABASE_ACCESS_TOKEN" ]; then
    echo -n "Testing Supabase... "
    if supabase projects list --experimental 2>/dev/null | head -1 > /dev/null; then
        echo "✓ Connected"
    else
        echo "✗ Failed (token may be invalid)"
    fi
fi

# Test Vercel
if [ -n "$VERCEL_TOKEN" ]; then
    echo -n "Testing Vercel... "
    if VERCEL_TOKEN=$VERCEL_TOKEN vercel whoami 2>/dev/null > /dev/null; then
        echo "✓ Connected"
    else
        echo "✗ Failed (token may be invalid)"
    fi
fi

# Test GitHub
if [ -n "$GITHUB_TOKEN" ]; then
    echo -n "Testing GitHub... "
    if gh auth status 2>/dev/null > /dev/null || GITHUB_TOKEN=$GITHUB_TOKEN gh auth status 2>/dev/null > /dev/null; then
        echo "✓ Connected"
    else
        echo "✗ Failed (token may be invalid)"
    fi
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "                      SETUP COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "DevOps agent is now configured. Use it with:"
echo ""
echo "  # Load credentials"
echo "  source secrets/devops.env"
echo ""
echo "  # Create new Supabase project"
echo "  supabase projects create my-project --org-id \$SUPABASE_ORG_ID"
echo ""
echo "  # Deploy to Vercel"
echo "  vercel --prod"
echo ""
echo "  # Or use the conductor"
echo "  ./scripts/conductor.sh assign fleet-devops \"Create Supabase: my-project\""
echo ""
