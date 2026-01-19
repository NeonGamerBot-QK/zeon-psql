-- uhhh most shit is keyv but idfk
use zeon_skack;


CREATE TABLE IF NOT EXISTS hcai_balance_tracker (
  id SERIAL PRIMARY KEY,
  balance DECIMAL(12, 2) NOT NULL,
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);