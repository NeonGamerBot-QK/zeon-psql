-- uhhh most shit is keyv but idfk
use zeon_skack;

CREATE TABLE IF NOT EXISTS hcai_balance_tracker (
  id SERIAL PRIMARY KEY,
  balance DECIMAL(12, 2) NOT NULL,
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

 CREATE TABLE IF NOT EXISTS lapse_tracker (
      id VARCHAR(100) PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      description TEXT,
      playback_url TEXT,
      thumbnail_url TEXT,
      duration INTEGER,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
