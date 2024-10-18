-- 1. Create the Database (if not already created)
-- Uncomment and modify the database name as needed.
-- CREATE DATABASE your_database_name
--     WITH 
--     OWNER = your_username
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'en_US.UTF-8'
--     LC_CTYPE = 'en_US.UTF-8'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1;

-- 2. Connect to the Database
-- \c your_database_name;

-- 3. Create the user Table
CREATE TABLE IF NOT EXISTS user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(20) UNIQUE NOT NULL,
    password VARCHAR(128) NOT NULL,
    openai_api_key_encrypted TEXT,
    anthropic_api_key_encrypted TEXT
);

-- 4. Create the ChatSession Table
CREATE TABLE IF NOT EXISTS chat_session (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    session_name VARCHAR(50) NOT NULL,
    agent_type VARCHAR(50),
    model_used VARCHAR(255),
    timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chat_session_user
        FOREIGN KEY(user_id)
            REFERENCES user(id)
            ON DELETE CASCADE
);

-- Optional: Create an index on user_id for faster lookups
-- CREATE INDEX IF NOT EXISTS idx_chat_session_user_id ON chat_session(user_id);

-- 5. Create the Chat Table
CREATE TABLE IF NOT EXISTS chat (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    session_id INTEGER NOT NULL,
    prompt TEXT NOT NULL,
    response TEXT,
    timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chat_user
        FOREIGN KEY(user_id)
            REFERENCES user(id)
            ON DELETE CASCADE,
    CONSTRAINT fk_chat_session
        FOREIGN KEY(session_id)
            REFERENCES chat_session(id)
            ON DELETE CASCADE
);

-- Optional: Create indexes on user_id and session_id for faster lookups
-- CREATE INDEX IF NOT EXISTS idx_chat_user_id ON chat(user_id);
-- CREATE INDEX IF NOT EXISTS idx_chat_session_id ON chat(session_id);
