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
