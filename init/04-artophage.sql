-- creates firsts, then alternates
USE artophage;

CREATE TABLE IF NOT EXISTS users (
    id uuid PRIMARY KEY,
    email text,
    encrypted_password text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
    isAdmin boolean DEFAULT false,
);

CREATE TABLE IF NOT EXISTS art (
    id bigserial PRIMARY KEY,
    created_at timestamptz DEFAULT now() NOT NULL,
    title text DEFAULT 'Untitled Art',
    image_perm_link text NOT NULL,
    author bigint 
    string_author text NOT NULL,
);
