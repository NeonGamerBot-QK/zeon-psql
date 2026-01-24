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
