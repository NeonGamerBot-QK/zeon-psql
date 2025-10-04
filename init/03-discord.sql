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
  amount NUMERIC(12,2) NOT NULL,
  card TEXT,
  name TEXT,
  type TEXT,
  created_at TIMESTAMP,
  node JSONB,
  merchent TEXT,
  receipt_url TEXT,                -- link to uploaded receipt
  is_lost_or_no_receipt BOOLEAN,   -- true if marked lost / no receipt
  receipt_added_at TIMESTAMP,      -- when the receipt was added
  ai_summary TEXT,                 -- AI-generated summary of transaction
  ai_analysis_out JSONB            -- AI output / analysis JSON
);
