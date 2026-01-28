-- sql sql sql
use zeon_discord;

CREATE TABLE IF NOT EXISTS irl_updates (
  id SERIAL PRIMARY KEY,
  lat DOUBLE PRECISION NOT NULL,
  long DOUBLE PRECISION NOT NULL,
  addr TEXT NOT NULL,
  city TEXT NOT NULL,
  name TEXT NOT NULL,
  clipboard TEXT NOT NULL,
  focus TEXT NOT NULL,
  battery INT NOT NULL,
  weather TEXT NOT NULL,
  created_at BIGINT NOT NULL,
  type TEXT
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  amount NUMERIC(12, 2) NOT NULL,
  card TEXT,
  name TEXT,
  type TEXT,
  created_at TIMESTAMP,
  node JSONB,
  merchent TEXT,
  receipt_url TEXT, -- link to uploaded receipt
  is_lost_or_no_receipt BOOLEAN, -- true if marked lost / no receipt
  receipt_added_at TIMESTAMP, -- when the receipt was added
  ai_summary TEXT, -- AI-generated summary of transaction
  ai_analysis_out JSONB -- AI output / analysis JSON
);

ALTER TABLE transactions
ADD COLUMN ai_receipt_summary text;

CREATE TABLE IF NOT EXISTS system_stats (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW (),
  hostname VARCHAR(255),
  -- CPU metrics
  cpu_usage_percent DECIMAL(5, 2),
  cpu_count INTEGER,
  load_avg_1m DECIMAL(6, 2),
  load_avg_5m DECIMAL(6, 2),
  load_avg_15m DECIMAL(6, 2),
  -- Memory metrics (in bytes)
  memory_total BIGINT,
  memory_used BIGINT,
  memory_free BIGINT,
  memory_usage_percent DECIMAL(5, 2),
  -- Swap metrics (in bytes)
  swap_total BIGINT,
  swap_used BIGINT,
  swap_free BIGINT,
  swap_usage_percent DECIMAL(5, 2),
  -- Storage metrics (in bytes)
  disk_total BIGINT,
  disk_used BIGINT,
  disk_free BIGINT,
  disk_usage_percent DECIMAL(5, 2),
  -- Process metrics
  process_count INTEGER,
  uptime_seconds BIGINT,
  -- Node.js process metrics
  node_heap_used BIGINT,
  node_heap_total BIGINT,
  node_external BIGINT,
  node_rss BIGINT,
  -- Network I/O (cumulative since boot)
  network_rx_bytes BIGINT,
  network_tx_bytes BIGINT
);

-- Indexes for efficient Metabase queries
CREATE INDEX IF NOT EXISTS idx_system_stats_timestamp ON system_stats (timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_system_stats_hostname ON system_stats (hostname);

CREATE INDEX IF NOT EXISTS idx_system_stats_timestamp_hostname ON system_stats (timestamp DESC, hostname);

--- uhh more stuff ^.^
ALTER TABLE system_stats
ADD COLUMN IF NOT EXISTS node_env VARCHAR(50),
ADD COLUMN IF NOT EXISTS server_ip VARCHAR(45),
ADD COLUMN IF NOT EXISTS platform VARCHAR(50),
ADD COLUMN IF NOT EXISTS arch VARCHAR(20),
ADD COLUMN IF NOT EXISTS p_server_uuid VARCHAR(100);

-- 1. Processed SimpleFin transactions (rocket.json replacement)
CREATE TABLE IF NOT EXISTS processed_simplefin_transactions (
  transaction_id VARCHAR(255) PRIMARY KEY,
  processed_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 2. Processed Google Calendar events (google-cache.json replacement)
CREATE TABLE IF NOT EXISTS processed_calendar_events (
  event_uid VARCHAR(512) PRIMARY KEY,
  processed_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 3. Notified manga chapters (manga-cache.json replacement)
CREATE TABLE IF NOT EXISTS notified_manga_chapters (
  chapter_id VARCHAR(255) PRIMARY KEY,
  notified_at TIMESTAMPTZ DEFAULT NOW ()
);



CREATE TABLE IF NOT EXISTS groupme_thread_mapping (
    discord_thread_id VARCHAR(64) PRIMARY KEY,
    groupme_id VARCHAR(64) NOT NULL,
    is_dm BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS groupme_last_message (
    groupme_id VARCHAR(64) PRIMARY KEY,
    last_message_id VARCHAR(64) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS discord_datamining_commits (
    id BIGINT PRIMARY KEY,                    -- comment id (also _id)
    title TEXT NOT NULL,                      -- commit message
    build_number VARCHAR(50),                 -- parsed build number
    timestamp TIMESTAMPTZ NOT NULL,           -- created_at ISO string
    url TEXT NOT NULL,                        -- html_url
    description TEXT,                         -- comment body (can be long)
    user_username VARCHAR(255),               -- user.username
    user_id BIGINT,                           -- user.id
    user_avatar_url TEXT,                     -- user.avatarURL
    user_url TEXT,                            -- user.url
    images TEXT[],                            -- array of image URLs (can be empty)
    comments JSONB DEFAULT '[]'::jsonb,       -- sub-comments (same structure, stored as JSONB)
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- Index for querying by build number
CREATE INDEX IF NOT EXISTS idx_datamining_build_number ON discord_datamining_commits(build_number);

-- Track sent notifications (replaces db_cache_sent_* keys)
CREATE TABLE IF NOT EXISTS discord_datamining_sent (
    commit_id BIGINT PRIMARY KEY,
    discord_message_id VARCHAR(64),           -- the message ID returned from Discord
    sent_at TIMESTAMPTZ DEFAULT NOW()
);


-- random stuff amp did
-- geo_checklists module
CREATE TABLE IF NOT EXISTS geo_checklists (
    id SERIAL PRIMARY KEY,
    geofence_id VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    lat DECIMAL(10, 8),
    long DECIMAL(11, 8),
    radius INTEGER DEFAULT 100,
    keywords TEXT[],
    triggers TEXT[] DEFAULT ARRAY['arrive'],
    checklist JSONB NOT NULL DEFAULT '[]',
    depart_checklist JSONB DEFAULT '[]',
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS geo_checklist_completions (
    id SERIAL PRIMARY KEY,
    geofence_id VARCHAR(100) NOT NULL,
    item_id VARCHAR(100) NOT NULL,
    completed_at TIMESTAMP DEFAULT NOW(),
    location_update_id INTEGER
);

CREATE INDEX IF NOT EXISTS idx_geo_checklists_geofence ON geo_checklists(geofence_id);
CREATE INDEX IF NOT EXISTS idx_geo_completions_date ON geo_checklist_completions(completed_at);

-- relationship_crm module
CREATE TABLE IF NOT EXISTS relationships (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    discord_id VARCHAR(100),
    telegram_id VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(255),
    slack_id VARCHAR(100),
    groupme_id VARCHAR(100),
    notes TEXT,
    reminder_days INTEGER DEFAULT 30,
    priority VARCHAR(20) DEFAULT 'normal',
    tags TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS relationship_contacts (
    id SERIAL PRIMARY KEY,
    relationship_id INTEGER REFERENCES relationships(id) ON DELETE CASCADE,
    platform VARCHAR(50) NOT NULL,
    direction VARCHAR(10) NOT NULL,
    message_preview TEXT,
    contacted_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_relationships_name ON relationships(name);
CREATE INDEX IF NOT EXISTS idx_contacts_relationship ON relationship_contacts(relationship_id);
CREATE INDEX IF NOT EXISTS idx_contacts_date ON relationship_contacts(contacted_at DESC);



-- errors table (error_formatter.js)
CREATE TABLE IF NOT EXISTS errors (
    id SERIAL PRIMARY KEY,
    error_name VARCHAR(255) NOT NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    location VARCHAR(500),
    file_path VARCHAR(500),
    line_number INTEGER,
    column_number INTEGER,
    context JSONB,
    module VARCHAR(255),
    function_name VARCHAR(255),
    user_id VARCHAR(100),
    guild_id VARCHAR(100),
    channel_id VARCHAR(100),
    command VARCHAR(255),
    severity VARCHAR(20) DEFAULT 'error',
    environment VARCHAR(50),
    node_version VARCHAR(20),
    hostname VARCHAR(255),
    resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMP,
    resolved_by VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_errors_created ON errors(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_errors_name ON errors(error_name);
CREATE INDEX IF NOT EXISTS idx_errors_module ON errors(module);
CREATE INDEX IF NOT EXISTS idx_errors_resolved ON errors(resolved);
CREATE INDEX IF NOT EXISTS idx_errors_severity ON errors(severity);

-- neons_mail module (processed_emails)
CREATE TABLE IF NOT EXISTS processed_emails (
    id SERIAL PRIMARY KEY,
    message_id VARCHAR(500) UNIQUE,
    from_address VARCHAR(255),
    from_name VARCHAR(255),
    to_address VARCHAR(255),
    subject TEXT,
    body_text TEXT,
    body_html TEXT,
    received_at TIMESTAMP,
    processed_at TIMESTAMP DEFAULT NOW(),
    
    -- AI Analysis
    summary TEXT,
    category VARCHAR(50),
    priority INTEGER DEFAULT 3,
    sentiment VARCHAR(50),
    
    -- Extracted Data
    is_2fa BOOLEAN DEFAULT false,
    two_fa_code VARCHAR(50),
    action_items JSONB DEFAULT '[]',
    calendar_event JSONB,
    receipt JSONB,
    tracking_numbers TEXT[],
    extracted_contacts JSONB DEFAULT '[]',
    suggested_reply TEXT,
    
    -- Linking
    transaction_id INTEGER,
    relationship_id INTEGER,
    
    -- Status
    read BOOLEAN DEFAULT false,
    archived BOOLEAN DEFAULT false,
    starred BOOLEAN DEFAULT false,
    labels TEXT[],
    
    -- Raw data
    raw_email JSONB,
    attachments JSONB DEFAULT '[]'
);

CREATE INDEX IF NOT EXISTS idx_emails_message_id ON processed_emails(message_id);
CREATE INDEX IF NOT EXISTS idx_emails_from ON processed_emails(from_address);
CREATE INDEX IF NOT EXISTS idx_emails_category ON processed_emails(category);
CREATE INDEX IF NOT EXISTS idx_emails_priority ON processed_emails(priority DESC);
CREATE INDEX IF NOT EXISTS idx_emails_received ON processed_emails(received_at DESC);
CREATE INDEX IF NOT EXISTS idx_emails_is_2fa ON processed_emails(is_2fa);

-- 
-- 
--- BIG SQL CHANGE BELOW
-- 
-- 


-- Basic transaction fields
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS external_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS memo TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS payee VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS posted BIGINT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS balance VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS currency VARCHAR(10);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS account_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS account_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS balance_date BIGINT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS transacted_at BIGINT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS available_balance VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS date VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS pending BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS plaid_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS typename VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS is_recurring BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS needs_review BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS review_status VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS hide_from_reports BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS is_split_transaction BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS data_provider_description TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS long_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS short_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS ignored_from VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS tax_deductible BOOLEAN;

-- Array/JSONB fields (stored as JSONB since they're complex)
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS tags JSONB;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS attachments JSONB;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS rewards JSONB;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS transaction_rule_node_ids JSONB;

-- ============================================================================
-- ORG (nested object)
-- ============================================================================

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS org_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS org_url VARCHAR(500);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS org_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS org_domain VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS org_sfin_url VARCHAR(500);

-- ============================================================================
-- ACCOUNT (nested object)
-- ============================================================================

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS account_icon VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS account_logo_url VARCHAR(500);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS account_typename VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS account_display_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS account_source VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS account_is_issued_card BOOLEAN;

-- ============================================================================
-- CATEGORY (nested object)
-- ============================================================================

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_icon VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_typename VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_type VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_label VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_icon_key VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_category_type VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_tax_deductible BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_include_in_earnings BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_include_in_spending BOOLEAN;

-- Category colors (nested)
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_color_base VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_color_faded VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_color_light VARCHAR(50);

-- Category group (nested)
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_group_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_group_type VARCHAR(100);

-- ============================================================================
-- MERCHANT (nested object)
-- ============================================================================

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS merchant_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS merchant_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS merchant_logo_url VARCHAR(500);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS merchant_typename VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS merchant_transactions_count INTEGER;

-- Merchant recurring stream (nested)
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS merchant_recurring_is_active BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS merchant_recurring_frequency VARCHAR(50);

-- ============================================================================
-- SERVICE (nested object)
-- ============================================================================

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS service_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS service_internal_id INTEGER;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS service_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS service_slug VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS service_typename VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS service_square_logo VARCHAR(500);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS service_color_base VARCHAR(50);

-- ============================================================================
-- SUBSCRIPTION (nested object)
-- ============================================================================

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_internal_id INTEGER;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_active BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_amount VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_manual BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_end_date VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_group_key VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_is_income BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_frequency INTEGER;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_typename VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_custom_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_service_type VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_is_cancellable BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_expected_next_bill_date VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_should_offer_bill_negotiation BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_is_eligible_for_bill_negotiation BOOLEAN;

-- Subscription service (nested)
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_service_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_service_internal_id INTEGER;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_service_name VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_service_slug VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_service_typename VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_service_square_logo VARCHAR(500);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_service_color_base VARCHAR(50);

-- Subscription next charge (nested)
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_next_charge_max_amount DECIMAL(12, 2);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_next_charge_min_amount DECIMAL(12, 2);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_next_charge_date VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_next_charge_amount DECIMAL(12, 2);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_next_charge_fluctuates BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_next_charge_is_estimate BOOLEAN;

-- Subscription transaction category (nested)
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_id VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_type VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_label VARCHAR(255);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_icon_key VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_typename VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_category_type VARCHAR(100);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_tax_deductible BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_include_in_earnings BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_include_in_spending BOOLEAN;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_color_base VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_color_faded VARCHAR(50);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS subscription_category_color_light VARCHAR(50);
-- 
--
-- end big sql change
-- 
-- 

ALTER TABLE transactions ALTER COLUMN balance TYPE DECIMAL(14, 2) USING balance::DECIMAL(14, 2);
ALTER TABLE transactions ALTER COLUMN available_balance TYPE DECIMAL(14, 2) USING available_balance::DECIMAL(14, 2);



-- simplefin req logger
-- someone complains if i fetch sm
-- ============================================================================
-- SIMPLEFIN FETCH LOG TABLE
-- Captures full API response data from SimpleFIN fetches
-- ============================================================================

CREATE TABLE IF NOT EXISTS simplefin_fetch_log (
    id SERIAL PRIMARY KEY,
    fetch_id UUID DEFAULT gen_random_uuid(),
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Request details
    start_date BIGINT,
    end_date BIGINT,
    
    -- Response metadata
    success BOOLEAN NOT NULL,
    error_message TEXT,
    http_status INTEGER,
    response_time_ms INTEGER,
    
    -- API errors array from response
    api_errors JSONB,
    
    -- Stats
    accounts_returned INTEGER,
    transactions_returned INTEGER,
    new_transactions_inserted INTEGER,
    transactions_updated INTEGER,
    
    -- Full raw response (includes all account/transaction data)
    raw_response JSONB,
    
    -- Trigger source
    triggered_by VARCHAR(100),
    notes TEXT
);

-- ============================================================================
-- SIMPLEFIN ACCOUNT SNAPSHOTS
-- Captures account state at each fetch (balance, available-balance, etc.)
-- ============================================================================

CREATE TABLE IF NOT EXISTS simplefin_account_snapshots (
    id SERIAL PRIMARY KEY,
    fetch_log_id INTEGER REFERENCES simplefin_fetch_log(id) ON DELETE CASCADE,
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Account identifiers
    account_id VARCHAR(255) NOT NULL,
    account_name VARCHAR(255),
    
    -- Org info
    org_domain VARCHAR(255),
    org_sfin_url VARCHAR(500),
    
    -- Account data
    currency VARCHAR(10),
    balance DECIMAL(14, 2),
    available_balance DECIMAL(14, 2),
    balance_date BIGINT,
    
    -- Extra fields
    account_open_date BIGINT,
    extra JSONB,
    
    -- Transaction count for this account in this fetch
    transaction_count INTEGER
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_simplefin_fetch_log_fetched_at ON simplefin_fetch_log(fetched_at DESC);
CREATE INDEX IF NOT EXISTS idx_simplefin_fetch_log_success ON simplefin_fetch_log(success);
CREATE INDEX IF NOT EXISTS idx_simplefin_account_snapshots_fetch_log_id ON simplefin_account_snapshots(fetch_log_id);
CREATE INDEX IF NOT EXISTS idx_simplefin_account_snapshots_account_id ON simplefin_account_snapshots(account_id);
CREATE INDEX IF NOT EXISTS idx_simplefin_account_snapshots_captured_at ON simplefin_account_snapshots(captured_at DESC);
