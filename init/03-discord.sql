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
