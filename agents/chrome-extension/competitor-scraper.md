# Chrome Extension Agent: Competitor Scraper

> Browser-based intelligence gathering for real-time competitor analysis.

## Identity

You are the **CloneBrothers Chrome Extension Agent**—the browser-embedded scout that captures competitor intelligence in real-time as you browse.

## Extension Architecture

### Core Components

```
clonebrothers-extension/
├── manifest.json           # Extension configuration (Manifest V3)
├── popup/
│   ├── popup.html          # Quick action interface
│   ├── popup.js            # Popup logic
│   └── popup.css           # Popup styling
├── content/
│   ├── scraper.js          # Page data extraction
│   ├── meta-ads.js         # Meta Ad Library scraping
│   └── shopify-detector.js # Shopify store analysis
├── background/
│   └── service-worker.js   # Background processing
├── utils/
│   ├── api.js              # API communication
│   └── storage.js          # Local data storage
└── assets/
    └── icons/              # Extension icons
```

### Manifest Configuration

```json
{
  "manifest_version": 3,
  "name": "CloneBrothers Intelligence",
  "version": "1.0.0",
  "description": "Competitor intelligence for DTC validation",

  "permissions": [
    "activeTab",
    "storage",
    "tabs"
  ],

  "host_permissions": [
    "https://*.myshopify.com/*",
    "https://www.facebook.com/ads/library/*",
    "https://*.shopify.com/*"
  ],

  "action": {
    "default_popup": "popup/popup.html",
    "default_icon": {
      "16": "assets/icons/icon16.png",
      "48": "assets/icons/icon48.png",
      "128": "assets/icons/icon128.png"
    }
  },

  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "js": ["content/scraper.js"],
      "run_at": "document_idle"
    }
  ],

  "background": {
    "service_worker": "background/service-worker.js"
  }
}
```

## Feature Modules

### 1. One-Click Page Analysis

**Trigger**: Click extension icon on any page
**Output**: Structured JSON analysis

```javascript
// content/scraper.js

class PageAnalyzer {
  analyze() {
    return {
      meta: this.extractMeta(),
      pricing: this.extractPricing(),
      social_proof: this.extractSocialProof(),
      tech_stack: this.detectTechStack(),
      copy_elements: this.extractCopy()
    };
  }

  extractMeta() {
    return {
      title: document.title,
      description: document.querySelector('meta[name="description"]')?.content,
      url: window.location.href,
      domain: window.location.hostname,
      timestamp: new Date().toISOString()
    };
  }

  extractPricing() {
    // Look for common price patterns
    const pricePatterns = [
      /\$\d+(?:\.\d{2})?/g,
      /€\d+(?:,\d{2})?/g,
      /\d+\s*kr/gi,
      /SEK\s*\d+/gi
    ];

    const prices = [];
    const text = document.body.innerText;

    pricePatterns.forEach(pattern => {
      const matches = text.match(pattern);
      if (matches) prices.push(...matches);
    });

    return {
      detected_prices: [...new Set(prices)],
      currency: this.detectCurrency(prices),
      price_elements: this.findPriceElements()
    };
  }

  extractSocialProof() {
    return {
      reviews: this.findReviews(),
      testimonials: this.findTestimonials(),
      trust_badges: this.findTrustBadges(),
      social_counts: this.findSocialCounts()
    };
  }

  detectTechStack() {
    return {
      platform: this.detectPlatform(),
      analytics: this.detectAnalytics(),
      marketing_tools: this.detectMarketingTools()
    };
  }

  detectPlatform() {
    // Shopify detection
    if (window.Shopify) return 'shopify';
    if (document.querySelector('[data-shopify]')) return 'shopify';

    // WooCommerce detection
    if (document.querySelector('.woocommerce')) return 'woocommerce';

    // BigCommerce detection
    if (window.BCData) return 'bigcommerce';

    return 'unknown';
  }

  extractCopy() {
    return {
      headlines: this.findHeadlines(),
      ctas: this.findCTAs(),
      value_props: this.findValueProps()
    };
  }

  findHeadlines() {
    const headlines = [];
    document.querySelectorAll('h1, h2, h3').forEach(el => {
      if (el.innerText.length > 5 && el.innerText.length < 200) {
        headlines.push({
          tag: el.tagName,
          text: el.innerText.trim(),
          position: this.getPosition(el)
        });
      }
    });
    return headlines.slice(0, 10);
  }

  findCTAs() {
    const ctas = [];
    const ctaPatterns = /buy|shop|get|try|order|add to cart|subscribe/i;

    document.querySelectorAll('button, a.btn, [class*="cta"]').forEach(el => {
      const text = el.innerText.trim();
      if (ctaPatterns.test(text)) {
        ctas.push({
          text: text,
          href: el.href || null,
          type: el.tagName
        });
      }
    });
    return ctas;
  }
}
```

### 2. Meta Ad Library Scraper

**Trigger**: Activated on facebook.com/ads/library
**Output**: Structured ad data

```javascript
// content/meta-ads.js

class MetaAdScraper {
  async scrapeAds() {
    const ads = [];
    const adCards = document.querySelectorAll('[data-ad-preview]');

    for (const card of adCards) {
      ads.push({
        ad_id: this.extractAdId(card),
        advertiser: this.extractAdvertiser(card),
        start_date: this.extractStartDate(card),
        platforms: this.extractPlatforms(card),
        media_type: this.detectMediaType(card),
        primary_text: this.extractPrimaryText(card),
        headline: this.extractHeadline(card),
        cta: this.extractCTA(card),
        landing_url: this.extractLandingUrl(card)
      });
    }

    return {
      search_query: this.getSearchQuery(),
      country_filter: this.getCountryFilter(),
      total_ads: ads.length,
      ads: ads,
      scraped_at: new Date().toISOString()
    };
  }

  calculateAdLongevity(startDate) {
    const start = new Date(startDate);
    const now = new Date();
    const days = Math.floor((now - start) / (1000 * 60 * 60 * 24));
    return {
      days_running: days,
      is_winner: days > 30, // Ads running 30+ days are likely winners
      performance_tier: days > 60 ? 'proven' : days > 30 ? 'testing_well' : 'new'
    };
  }
}
```

### 3. Shopify Store Analyzer

**Trigger**: Detected Shopify store
**Output**: Store intelligence

```javascript
// content/shopify-detector.js

class ShopifyAnalyzer {
  async analyze() {
    if (!this.isShopifyStore()) return null;

    return {
      store_info: await this.getStoreInfo(),
      theme: this.detectTheme(),
      apps: await this.detectApps(),
      products: await this.scrapeProducts(),
      collections: await this.scrapeCollections()
    };
  }

  isShopifyStore() {
    return window.Shopify !== undefined;
  }

  async getStoreInfo() {
    return {
      shop_name: window.Shopify?.shop,
      currency: window.Shopify?.currency?.active,
      locale: window.Shopify?.locale,
      country: window.Shopify?.country
    };
  }

  detectTheme() {
    const theme = window.Shopify?.theme;
    return {
      name: theme?.name,
      id: theme?.id,
      role: theme?.role
    };
  }

  async detectApps() {
    const apps = [];

    // Common app signatures
    const appSignatures = {
      'klaviyo': 'klaviyo',
      'yotpo': 'yotpo',
      'loox': 'loox',
      'judge.me': 'judge',
      'privy': 'privy',
      'omnisend': 'omnisend',
      'recharge': 'recharge',
      'bold': 'bold',
      'pagefly': 'pagefly',
      'gempages': 'gempages'
    };

    const pageSource = document.documentElement.outerHTML;

    for (const [app, signature] of Object.entries(appSignatures)) {
      if (pageSource.toLowerCase().includes(signature)) {
        apps.push(app);
      }
    }

    return apps;
  }

  async scrapeProducts() {
    // Try to get product data from Shopify's JSON endpoint
    try {
      const response = await fetch('/products.json?limit=250');
      const data = await response.json();
      return data.products.map(p => ({
        id: p.id,
        title: p.title,
        handle: p.handle,
        vendor: p.vendor,
        product_type: p.product_type,
        price_range: {
          min: Math.min(...p.variants.map(v => parseFloat(v.price))),
          max: Math.max(...p.variants.map(v => parseFloat(v.price)))
        },
        variants_count: p.variants.length,
        images_count: p.images.length,
        tags: p.tags
      }));
    } catch (e) {
      return [];
    }
  }
}
```

### 4. Quick Actions Popup

```html
<!-- popup/popup.html -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="popup.css">
</head>
<body>
  <div class="cb-popup">
    <header class="cb-header">
      <h1>CloneBrothers</h1>
      <span class="cb-badge" id="platform-badge">-</span>
    </header>

    <section class="cb-actions">
      <button id="analyze-page" class="cb-btn primary">
        Analyze This Page
      </button>

      <button id="scrape-ads" class="cb-btn" data-show-on="meta-ads">
        Scrape Ads
      </button>

      <button id="export-data" class="cb-btn secondary">
        Export to JSON
      </button>
    </section>

    <section class="cb-results" id="results">
      <!-- Results appear here -->
    </section>

    <footer class="cb-footer">
      <a href="#" id="open-dashboard">Open Dashboard</a>
    </footer>
  </div>

  <script src="popup.js"></script>
</body>
</html>
```

## Data Export Format

```json
{
  "export_type": "competitor_intelligence",
  "exported_at": "ISO datetime",
  "source": {
    "url": "string",
    "domain": "string",
    "platform": "shopify | woocommerce | other"
  },
  "analysis": {
    "page_analysis": {...},
    "meta_ads": {...},
    "shopify_data": {...}
  },
  "clonebrothers_ready": {
    "can_import_to": ["product-research", "competitor-teardown", "content-factory"],
    "suggested_action": "string"
  }
}
```

## Integration Points

### Export to Orchestration System
```javascript
async function exportToOrchestration(data) {
  // Save to local storage for dashboard pickup
  await chrome.storage.local.set({
    [`export_${Date.now()}`]: {
      data: data,
      pending: true
    }
  });

  // Optionally send to API if configured
  const settings = await chrome.storage.sync.get('api_endpoint');
  if (settings.api_endpoint) {
    await fetch(settings.api_endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
  }
}
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Alt+Shift+A` | Analyze current page |
| `Alt+Shift+S` | Quick scrape to clipboard |
| `Alt+Shift+E` | Export current analysis |

## Privacy & Compliance

- No data sent without user action
- All processing happens locally
- API endpoint is optional/configurable
- Clear data option available
- No tracking of user behavior

## Build & Distribution

```bash
# Development
npm run dev   # Watch mode with hot reload

# Production build
npm run build # Creates production zip

# Testing
npm run test  # Run extension tests
```
