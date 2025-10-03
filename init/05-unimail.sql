USE UNIMAIL;

CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now(),
    to_email TEXT NOT NULL,
    from_useragent TEXT,
    subject TEXT
);
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- random unique id
    api_key_preview TEXT NOT NULL,                 -- first 5+last 5 chars of the key
    api_key_hash TEXT NOT NULL,                    -- hashed key (ac key will be 16 chars)
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE OR REPLACE FUNCTION enforce_audit_log_limit()
RETURNS TRIGGER AS $$
BEGIN
    -- If row count exceeds 1000, delete the oldest row(s)
    IF (SELECT count(*) FROM audit_logs) > 1000 THEN
        DELETE FROM audit_logs
        WHERE id = (
            SELECT id
            FROM audit_logs
            ORDER BY created_at ASC
            LIMIT 1
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- there is also a keyv table called 'stats'

-- there is also an autocreated table called 'sessions'
-- there is also an autocreated table called 'ratelimits'



-- migration 2025-10-02
ALTER TABLE api_keys
ADD COLUMN label TEXT;
